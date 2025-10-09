import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_twilio_chat_conversations/twilio_conversations.dart';
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class ConversationsController extends GetxController {
  final plugin = TwilioConversations();
  ConversationClient? client;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  var isClientInitialized = false.obs;
  var identity = ''.obs;
  var friendlyName = ''.obs;
  TextEditingController identityController = TextEditingController();
  var conversations = <Conversation>[].obs;
  var unreadMessageCounts = <String, int>{}.obs;
  // Subscriptions and listeners
  final subscriptions = <StreamSubscription>[];
  final Map<String, StreamSubscription> _messageListeners = {};

  // Initialize Twilio client
  Future<void> create({required String jwtToken}) async {
    await TwilioConversations.debug(dart: true, native: true, sdk: false);
    print('Initializing Twilio Conversations client...');

    client = await plugin.create(jwtToken: jwtToken);
    print('Twilio client initialized as ${client?.myIdentity}');
    final uClient = client;

    if (uClient == null) return;

    isClientInitialized.value = true;
    await updateFriendlyName();

    // Core event listeners for client-level updates
    subscriptions.add(
      uClient.onConversationAdded.listen((event) async {
        await refreshConversationList();
      }),
    );

    subscriptions.add(
      uClient.onConversationUpdated.listen((event) async {
        await refreshConversationList();
      }),
    );

    subscriptions.add(
      uClient.onConversationDeleted.listen((event) async {
        await refreshConversationList();
      }),
    );

    subscriptions.add(
      uClient.onTokenAboutToExpire.listen((_) async {
        print("Token about to expire — refreshing...");
        final newToken = await fetchAccessToken();
        if (newToken != null) await updateToken(jwtToken: newToken);
      }),
    );

    subscriptions.add(
      uClient.onTokenExpired.listen((_) async {
        print("Token expired — refreshing...");
        final newToken = await fetchAccessToken();
        if (newToken != null) {
          await updateToken(jwtToken: newToken);
          await refreshConversationList();
        }
      }),
    );

    await refreshConversationList();
  }

  Future<void> updateToken({required String jwtToken}) async {
    await client?.updateToken(jwtToken);
  }

  Future<void> shutdown() async {
    final client = TwilioConversations.conversationClient;
    if (client != null) {
      await client.shutdown();
      isClientInitialized.value = false;
    }
  }

  Future<void> refreshConversationList() async {
    try {
      final myConversations = await TwilioConversations.conversationClient
          ?.getMyConversations();

      if (myConversations != null) {
        conversations.assignAll(myConversations);

        for (var conversation in myConversations) {
          int unreadMessages = 0;
          try {
            final totalMessages = await conversation.getMessagesCount() ?? 0;
            final lastReadIndex = conversation.lastReadMessageIndex;
            unreadMessages = (lastReadIndex != null && lastReadIndex >= 0)
                ? ((totalMessages - 1) - lastReadIndex)
                : totalMessages;
          } catch (_) {
            unreadMessages = 0;
          }

          unreadMessageCounts[conversation.sid] = unreadMessages;
          attachMessageListeners(conversation);
        }

        unreadMessageCounts.refresh();

        final activeSid = BaseController.user.value?.twilioConversationSid;
        if (activeSid != null) {
          BaseController.unreadMessages.value =
              unreadMessageCounts[activeSid] ?? 0;
        }
      }
    } catch (e) {
      print("Error refreshing conversations: $e");
    }
  }

  Future<Conversation?> getOrJoinConversation(String conversationSid) async {
    Conversation? conversation;

    try {
      final client = TwilioConversations.conversationClient;
      if (client == null) {
        print('Twilio client not initialized');
        BaseController.hideLoading();
        return null;
      }

      try {
        conversation = await client.getConversation(conversationSid);
      } catch (e) {
        print("getConversation failed: $e");

        if (e.toString().contains('50400')) {
          print('User not a member — joining via backend...');
          await joinConversation(conversationSid);
          conversation = await client.getConversation(conversationSid);
        } else {
          rethrow;
        }
      }

      if (conversation == null) {
        print('Conversation not found for SID: $conversationSid');
        BaseController.hideLoading();
        return null;
      }

      if (conversation.status != ConversationStatus.JOINED) {
        try {
          print('Joining conversation $conversationSid...');
          await conversation.join();
          print('Joined successfully.');
        } catch (e) {
          print('Error joining conversation: $e');
        }
      }

      // Wait for synchronization
      int retries = 0;
      while (conversation.synchronizationStatus !=
              ConversationSynchronizationStatus.ALL &&
          retries < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retries++;
      }

      print('Conversation synchronized.');

      // Attach real-time message listeners
      attachMessageListeners(conversation);

      // Refresh conversation list once
      await refreshConversationList();

      BaseController.hideLoading();
      return conversation;
    } catch (e) {
      BaseController.hideLoading();
      print('getOrJoinConversation() error: $e');
      return null;
    }
  }

  // Real-time Listeners
  void attachMessageListeners(Conversation conversation) {
    if (_messageListeners.containsKey(conversation.sid)) {
      return;
    }

    print('Attaching message listeners for ${conversation.sid}');

    final sub = conversation.onMessageAdded.listen((event) async {
      print('New message in ${conversation.sid}');
      // Update unread count for this conversation only
      try {
        final totalMessages = await conversation.getMessagesCount() ?? 0;
        final lastReadIndex = conversation.lastReadMessageIndex;
        final unread = (lastReadIndex != null && lastReadIndex >= 0)
            ? ((totalMessages - 1) - lastReadIndex)
            : totalMessages;
        unreadMessageCounts[conversation.sid] = unread;
        unreadMessageCounts.refresh();
      } catch (e) {
        print('Unread update error: $e');
      }
    });

    _messageListeners[conversation.sid] = sub;

    conversation.onMessageUpdated.listen((event) {
      print('Message updated in ${conversation.sid}');
    });

    conversation.onMessageDeleted.listen((event) {
      print('Message deleted in ${conversation.sid}');
    });
  }

  // Read/Unread Handling
  Future<void> markRead(Conversation conversation) async {
    try {
      final count = await conversation.getMessagesCount();
      if (count != null && count > 0) {
        await conversation.setLastReadMessageIndex(count - 1);
        print('Marked all messages as read for ${conversation.sid}');
      }
      await refreshConversationList();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Backend Apis's
  Future<String?> fetchAccessToken() async {
    try {
      var response = await BaseClient().dioPost('/chat/token/', null);
      if (response != null && response['token'] != null) {
        await storage.write(key: 'twilio_token', value: response['token']);
        return response['token'];
      }
    } catch (e) {
      print("Token fetch failed: $e");
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
      print("Join conversation failed: $e");
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
      print("{STAR TOGGLE: ${response.toString()}}");
      if (response['starred']) {
        DialogHelper.showErrorToast(description: 'Message marked as starred.');
      } else {
        DialogHelper.showErrorToast(description: 'Message unstarred.');
      }
    } else {
      DialogHelper.showErrorToast(description: "Failed! Please try later.");
    }
  }

  // Get starred messages
  Future<List<dynamic>> getStarredMessages() async {
    var response = await BaseClient().dioPost('/chat/star-list/', null);
    if (response != null) {
      print("{STAR MESSAGES: ${response.toString()}}");
      if (response['status']) {
        DialogHelper.showErrorToast(description: response['message']);
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(description: "Failed! Please try later.");
    }
    return [];
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

  @override
  void onClose() {
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
