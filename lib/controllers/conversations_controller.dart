import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_twilio_chat_conversations/twilio_conversations.dart';
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class ConversationsController extends GetxController {
  final plugin = TwilioConversations();
  ConversationClient? client;
  var isClientInitialized = false.obs;
  var identity = ''.obs;
  var friendlyName = ''.obs;
  TextEditingController identityController = TextEditingController();
  var conversations = <Conversation>[].obs;
  var unreadMessageCounts = <String, int>{}.obs;
  // Subscriptions and listeners
  final subscriptions = <StreamSubscription>[];
  final Map<String, StreamSubscription> _messageListeners = {};

  // Refresh coalescing. Twilio fires onConversationAdded once per existing
  // conversation while the client syncs, so an un-guarded refresh-per-event
  // costs N refreshes x N unread lookups. These keep it to a single pass.
  Timer? _refreshDebounce;
  Future<void>? _activeRefresh;
  bool _refreshAgain = false;

  // Initialize Twilio client
  Future<void> create({required String jwtToken}) async {
    await TwilioConversations.debug(dart: true, native: true, sdk: false);

    client = await plugin.create(jwtToken: jwtToken);
    final uClient = client;

    if (uClient == null) return;

    isClientInitialized.value = true;
    await updateFriendlyName();

    // Core event listeners for client-level updates. These use the debounced
    // refresh: during initial sync the client emits one onConversationAdded per
    // conversation, and refreshing on every one of them is quadratic.
    subscriptions.add(
      uClient.onConversationAdded.listen((event) => _scheduleRefresh()),
    );

    subscriptions.add(
      uClient.onConversationUpdated.listen((event) => _scheduleRefresh()),
    );

    subscriptions.add(
      uClient.onConversationDeleted.listen((event) => _scheduleRefresh()),
    );

    // Token renewal runs on the SDK's schedule, often while the app is
    // backgrounded and the socket has dropped. Any throw inside these async
    // listener bodies is an unhandled async error, which Crashlytics records
    // as a fatal, so both are fully guarded.
    subscriptions.add(
      uClient.onTokenAboutToExpire.listen((_) async {
        try {
          final newToken = await fetchAccessToken();
          if (newToken != null) await updateToken(jwtToken: newToken);
        } catch (_) {
          // Renewal will be retried when the SDK emits onTokenExpired.
        }
      }),
    );

    subscriptions.add(
      uClient.onTokenExpired.listen((_) async {
        try {
          final newToken = await fetchAccessToken();
          if (newToken != null) {
            await updateToken(jwtToken: newToken);
            await refreshConversationList();
          }
        } catch (_) {}
      }),
    );

    await refreshConversationList();
  }

  /// Returns whether the token was accepted.
  ///
  /// The native SDK throws (e.g. "Twilsock has disconnected") when the
  /// transport is down at renewal time. That is recoverable — the client
  /// reconnects and re-emits its token callbacks — so it must not propagate.
  Future<bool> updateToken({required String jwtToken}) async {
    try {
      await client?.updateToken(jwtToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> shutdown() async {
    final client = TwilioConversations.conversationClient;
    if (client != null) {
      await client.shutdown();
      isClientInitialized.value = false;
    }
  }

  /// Tears down everything tied to the signed-in user so the next login starts
  /// from a clean client. This controller is a Get singleton and outlives a
  /// logout, so without it the previous user's listeners, cached conversations
  /// and unread counts leak into the next session. It matters in particular
  /// because a manager and an agent share conversation SIDs, which would make
  /// attachMessageListeners() skip re-attaching for the new client.
  Future<void> resetSession() async {
    _refreshDebounce?.cancel();
    _refreshDebounce = null;

    for (final sub in subscriptions) {
      try {
        await sub.cancel();
      } catch (_) {}
    }
    subscriptions.clear();

    for (final sub in _messageListeners.values) {
      try {
        await sub.cancel();
      } catch (_) {}
    }
    _messageListeners.clear();

    conversations.clear();
    unreadMessageCounts.clear();
    friendlyName.value = '';

    try {
      await shutdown();
    } catch (_) {}

    client = null;
    isClientInitialized.value = false;
  }

  /// Refreshes the conversation list, coalescing concurrent callers.
  ///
  /// If a refresh is already running, this does not start a second pass; it
  /// flags the running one to repeat once at the end and awaits it. That keeps
  /// a burst of client events from multiplying into N overlapping refreshes.
  Future<void> refreshConversationList() {
    final active = _activeRefresh;
    if (active != null) {
      _refreshAgain = true;
      return active;
    }
    final future = _runRefreshLoop();
    _activeRefresh = future;
    return future;
  }

  /// Debounced refresh for high-frequency client events. Collapses the storm of
  /// onConversationAdded callbacks emitted during initial sync into one pass.
  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(
      const Duration(milliseconds: 400),
      refreshConversationList,
    );
  }

  Future<void> _runRefreshLoop() async {
    try {
      do {
        _refreshAgain = false;
        await _refreshConversationListOnce();
      } while (_refreshAgain);
    } finally {
      _activeRefresh = null;
    }
  }

  Future<void> _refreshConversationListOnce() async {
    try {
      final myConversations = await TwilioConversations.conversationClient
          ?.getMyConversations();

      if (myConversations != null) {
        conversations.assignAll(myConversations);

        // Fetch unread counts concurrently. Doing this sequentially cost one
        // round-trip per conversation, which is what pushed managers with many
        // agents past the chat-initialization timeout.
        final unreadCounts = await Future.wait(
          myConversations.map((conversation) async {
            try {
              return await conversation.getUnreadMessagesCount();
            } catch (_) {
              return 0;
            }
          }),
        );

        for (var i = 0; i < myConversations.length; i++) {
          final conversation = myConversations[i];
          unreadMessageCounts[conversation.sid] = unreadCounts[i];
          attachMessageListeners(conversation);
        }

        unreadMessageCounts.refresh();
        updateTotalUnreadCount();
      }
    } catch (e) {}
  }

  Future<Conversation?> getOrJoinConversation(String conversationSid) async {
    Conversation? conversation;
    try {
      final client = TwilioConversations.conversationClient;
      if (client == null) {
        BaseController.hideLoading();
        return null;
      }
      try {
        conversation = await client.getConversation(conversationSid);
      } catch (e) {
        if (e.toString().contains('50400')) {
          await joinConversation(conversationSid);
          conversation = await client.getConversation(conversationSid);
        } else {
          rethrow;
        }
      }
      if (conversation == null) {
        BaseController.hideLoading();
        return null;
      }
      if (conversation.status != ConversationStatus.JOINED) {
        try {
          await conversation.join();
        } catch (e) {}
      }
      // Wait for synchronization
      int retries = 0;
      while (conversation.synchronizationStatus !=
              ConversationSynchronizationStatus.ALL &&
          retries < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retries++;
      }
      // print('Conversation synchronized.');
      // Attach real-time message listeners
      attachMessageListeners(conversation);

      // Refresh conversation list once
      await refreshConversationList();

      BaseController.hideLoading();
      return conversation;
    } catch (e) {
      BaseController.hideLoading();
      // print('getOrJoinConversation() error: $e');
      return null;
    }
  }

  // Real-time Listeners
  void attachMessageListeners(Conversation conversation) {
    if (_messageListeners.containsKey(conversation.sid)) {
      return;
    }

    final sub = conversation.onMessageAdded.listen((event) async {
      // print('New message in ${conversation.sid}');
      // Update unread count for this conversation only
      try {
        int unread = 0;
        final unreadFromSdk = await conversation.getUnreadMessagesCount();
        unread = unreadFromSdk;

        unreadMessageCounts[conversation.sid] = unread;
        unreadMessageCounts.refresh();
        updateTotalUnreadCount();
      } catch (e) {
        // print('Unread update error: $e');
      }
    });

    _messageListeners[conversation.sid] = sub;

    conversation.onMessageUpdated.listen((event) {
      // print('Message updated in ${conversation.sid}');
    });

    conversation.onMessageDeleted.listen((event) {
      // print('Message deleted in ${conversation.sid}');
    });
  }

  // Read/Unread Handling
  Future<void> markRead(Conversation conversation) async {
    try {
      final count = await conversation.getMessagesCount();
      if (count != null && count > 0) {
        await conversation.setLastReadMessageIndex(count - 1);
        // print('Marked all messages as read for ${conversation.sid}');
      }
      await refreshConversationList();
    } catch (e) {
      // print('Error marking as read: $e');
    }
  }

  // Backend Apis's
  Future<String?> fetchAccessToken() async {
    try {
      var response = await BaseClient().dioPost('/chat/token/', null);
      if (response != null && response['token'] != null) {
        BaseController.storeToken.write('twilio_token', response['token']);
        return response['token'];
      }
    } catch (e) {
      // print("Token fetch failed: $e");
    }
    DialogHelper.showErrorToast(description: "Failed to fetch Twilio token.");
    return null;
  }

  Future<void> joinConversation(String convSid) async {
    try {
      var response = await BaseClient().dioPost(
        '/chat/join-conversation/',
        json.encode({"conversation_sid": convSid}),
      );
      if (response == null || response['joined'] != true) {
        DialogHelper.showErrorToast(
          description: "Failed to join conversation.",
        );
      }
    } catch (e) {
      // print("Join conversation failed: $e");
    }
  }

  // Star / Unstar message
  Future<void> toggleStar(String conversationSid, String messageSid) async {
    var response = await BaseClient().dioPost(
      '/chat/star-toggle/',
      json.encode({
        "conversation_sid": conversationSid,
        "message_sid": messageSid,
      }),
    );
    if (response != null) {
      // print("{STAR TOGGLE: ${response.toString()}}");
      if (response['starred']) {
        // DialogHelper.showSuccessToast(description: 'Message marked as starred.');
      } else {
        DialogHelper.showErrorToast(description: 'Message unstarred.');
      }
    } else {
      DialogHelper.showErrorToast(description: "Failed! Please try later.");
    }
  }

  Future<void> setFriendlyName(String name) async {
    final myUser = await TwilioConversations.conversationClient?.getMyUser();
    await myUser?.setFriendlyName(name);
    await updateFriendlyName();
  }

  Future<void> updateFriendlyName() async {
    final myUser = await TwilioConversations.conversationClient?.getMyUser();
    friendlyName.value = myUser?.friendlyName ?? '';
  }

  void updateTotalUnreadCount() {
    final user = BaseController.user.value;
    if (user == null) return;

    int totalUnread = 0;

    if (user.role == 'agnt') {
      // Single conversation SID
      final sid = user.twilioConversationSid;
      if (unreadMessageCounts.containsKey(sid)) {
        totalUnread = unreadMessageCounts[sid] ?? 0;
      }
    } else if (user.role == 'mngr') {
      // For manager, collect all assigned conversation SIDs
      final managerConversationSid = user.twilioConversationSid;
      final agentConversations = [
        ...?user.managersUsers?.map((u) => u.twilioConversationSid),
        ...?user.adminUsers?.map((u) => u.twilioConversationSid),
      ].whereType<String>();

      final allSids = {managerConversationSid, ...agentConversations};

      for (final sid in allSids) {
        totalUnread += unreadMessageCounts[sid] ?? 0;
      }
    }

    BaseController.unreadMessages.value = totalUnread;

    // print("Recalculating unread for role: ${user.role}");
    // print("Unread Map Snapshot: $unreadMessageCounts");
    // print("Calculated Total Unread = $totalUnread");
  }

  @override
  void onClose() {
    _refreshDebounce?.cancel();
    for (var sub in subscriptions) {
      sub.cancel();
    }
    for (var sub in _messageListeners.values) {
      sub.cancel();
    }
    _messageListeners.clear();
    super.onClose();
  }
}
