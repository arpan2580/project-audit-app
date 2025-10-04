import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_twilio_chat_conversations/twilio_conversations.dart';
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class ConversationsController extends GetxController {
  final plugin = TwilioConversations();
  ConversationClient? client;

  /// Reactive fields
  var isClientInitialized = false.obs;
  var identity = ''.obs;
  var friendlyName = ''.obs;
  TextEditingController identityController = TextEditingController();

  var conversations = <Conversation>[].obs;
  var unreadMessageCounts = <String, int>{}.obs;

  final subscriptions = <StreamSubscription>[];

  /// Update identity
  void updateIdentity(String id) {
    identity.value = id;
  }

  /// Initialize client
  Future<void> create({required String jwtToken}) async {
    await TwilioConversations.debug(dart: true, native: true, sdk: false);

    print('debug logging set, creating client...');
    client = await plugin.create(jwtToken: jwtToken);

    print('Client initialized');
    print('Your Identity: ${client?.myIdentity}');

    final uClient = client;
    if (uClient != null) {
      isClientInitialized.value = true;
      await updateFriendlyName();

      subscriptions.add(
        uClient.onConversationAdded.listen((event) {
          getMyConversations();
        }),
      );

      subscriptions.add(
        uClient.onConversationUpdated.listen((event) {
          getMyConversations();
        }),
      );

      subscriptions.add(
        uClient.onConversationDeleted.listen((event) {
          getMyConversations();
        }),
      );

      subscriptions.add(
        uClient.onTokenAboutToExpire.listen((_) async {
          print("Token about to expire — refreshing...");
          await fetchAccessToken().then((value) async {
            print("{TWILIO TOKEN: $value}");
            await updateToken(jwtToken: value!);
            // await create(jwtToken: value!).then((onValue) {
            //   getMyConversations();
            //   BaseController.isChatInitialized.value = true;
            // });
          });
        }),
      );

      subscriptions.add(
        uClient.onTokenExpired.listen((_) async {
          print("Token expired — refreshing...");
          await fetchAccessToken().then((value) async {
            print("{TWILIO TOKEN: $value}");
          });
        }),
      );
    }
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

  Future<void> markRead(Conversation conversation) async {
    await conversation.setAllMessagesRead();
    await getMyConversations();
  }

  Future<void> markUnread(Conversation conversation) async {
    await conversation.setAllMessagesUnread();
    await getMyConversations();
  }

  Future<void> join(Conversation conversation) async {
    await conversation.join();
    await getMyConversations();
  }

  Future<void> leave(Conversation conversation) async {
    await conversation.leave();
    await getMyConversations();
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

  Future<Conversation?> createConversation({
    String friendlyName = 'Test Conversation',
  }) async {
    var result = await TwilioConversations.conversationClient
        ?.createConversation(friendlyName: friendlyName);
    print('Conversation successfully created: ${result?.friendlyName}');
    return result;
  }

  Future<void> getMyConversations() async {
    final myConversations = await TwilioConversations.conversationClient
        ?.getMyConversations();

    if (myConversations != null) {
      conversations.assignAll(myConversations);

      for (var conversation in conversations) {
        late int unreadMessages;
        try {
          unreadMessages = await conversation.getUnreadMessagesCount();
        } on PlatformException {
          unreadMessages = 0;
        }

        if (unreadMessages == 0) {
          // If unreadMessages comes back as `null`, no last read message index set
          final messagesCount = await conversation.getMessagesCount();
          if (messagesCount != null && messagesCount > 0) {
            await conversation.setLastReadMessageIndex(0);
          }
          var totalMessages = await conversation.getMessagesCount();
          unreadMessageCounts[conversation.sid] = totalMessages ?? 0;
        } else {
          unreadMessageCounts[conversation.sid] = unreadMessages;
        }
      }

      unreadMessageCounts.refresh();
      BaseController.unreadMessages.value =
          unreadMessageCounts[BaseController
              .user
              .value
              ?.twilioConversationSid] ??
          0;
    }
  }

  Future<void> registerForNotification() async {
    String? token;
    if (Platform.isAndroid) {
      // token = await FirebaseMessaging.instance.getToken();
    }
    await client?.registerForNotification(token);
  }

  Future<void> unregisterForNotification() async {
    String? token;
    if (Platform.isAndroid) {
      // token = await FirebaseMessaging.instance.getToken();
    }
    await client?.unregisterForNotification(token);
  }

  @override
  void onClose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }

  // Fetch access token from backend
  Future<String?> fetchAccessToken() async {
    var response = await BaseClient().dioPost('/chat/token/', null);
    if (response != null) {
      print("{TWILIO TOKEN: ${response.toString()}}");
      if (response['token'] != null) {
        return response['token'];
      } else {
        DialogHelper.showErrorToast(description: 'Failed to fetch chat.');
      }
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to initialize chat functionality.",
      );
    }
    return null;
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
      if (response['status']) {
        DialogHelper.showErrorToast(description: response['message']);
      } else {
        DialogHelper.showErrorToast(description: response['message']);
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
}
