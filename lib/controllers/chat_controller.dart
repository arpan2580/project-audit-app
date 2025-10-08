import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/controllers/conversations_controller.dart';
import 'package:jnk_app/controllers/messages_controller.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/widgets/chat_widget.dart';

class ChatController extends GetxController {
  final ConversationsController controller = Get.put(ConversationsController());
  RxBool isLoading = true.obs;
  late MessagesController msgController;
  RxBool showChatReactions = false.obs;
  RxInt selectedChat = (-1).obs; // -1 to indicate none selected
  RxSet<int> starredMessages = <int>{}.obs;
  RxBool showOnlyStarred = false.obs;
  final RxList<Widget> chatWidgets = <Widget>[].obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    ever(messages, (_) {
      buildChatWidgets();
    });
    // controller.getMyConversations().then((onValue) {
    if (controller.conversations.isNotEmpty && controller.client != null) {
      // final MessagesController
      msgController = Get.put(
        MessagesController(
          controller.conversations[0],
          controller.client!,
          this,
        ),
        permanent: true,
      );
      msgController.loadConversation();
      isLoading.value = false;
    } else {
      Get.back();
      DialogHelper.showErrorToast(description: "No conversations found.");
    }
  }

  final RxList<Map<String, Object>> messages = <Map<String, Object>>[].obs;

  // Sort messages by time (if not already sorted)
  List<Map<String, dynamic>> get sortedMessages {
    final msgs = List<Map<String, dynamic>>.from(messages);
    msgs.sort(
      (a, b) => DateTime.parse(a['time']).compareTo(DateTime.parse(b['time'])),
    );
    return msgs;
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) return "Today";
    if (msgDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String? lastDateGroup;

  void toggleChatReaction(int id) {
    if (selectedChat.value == id && showChatReactions.value) {
      showChatReactions.value = false;
      selectedChat.value = -1;
    } else {
      selectedChat.value = id;
      showChatReactions.value = true;
    }
  }

  void hideChatReactions() {
    showChatReactions.value = false;
    selectedChat.value = -1;
  }

  void buildChatWidgets({List<Map<String, dynamic>>? customMessages}) {
    chatWidgets.clear();
    lastDateGroup = null;
    final List<Map<String, dynamic>> displayMessages =
        customMessages ?? sortedMessages;

    for (var msg in displayMessages) {
      final dateTime = DateTime.parse(msg['time']);
      final timeStr = DateFormat('h:mm a').format(dateTime);
      final currentDateGroup = formatDate(dateTime);
      // Add date group if it's a new day
      if (currentDateGroup != lastDateGroup) {
        chatWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentDateGroup,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
        lastDateGroup = currentDateGroup;
      }

      chatWidgets.add(
        ChatWidget(msg: msg, timeStr: timeStr, chatController: this),
      );
    }
  }

  void toggleStarredMessage(int messageId, String sid) {
    print("Channel SID: ${controller.conversations.single.sid}");
    controller.toggleStar(controller.conversations.single.sid, sid);
    if (starredMessages.contains(messageId)) {
      starredMessages.remove(messageId);
    } else {
      starredMessages.add(messageId);
    }
  }

  void toggleShowOnlyStarred() {
    showOnlyStarred.value = !showOnlyStarred.value;
  }

  List<Map<String, dynamic>> get filteredMessages {
    if (showOnlyStarred.value) {
      return sortedMessages
          .where((msg) => starredMessages.contains(msg['id']))
          .toList();
    } else {
      return sortedMessages;
    }
  }

  void msgControllerDispose() {
    if (Get.isRegistered<MessagesController>()) {
      final MessagesController msgController = Get.find<MessagesController>();
      msgController.dispose();
      Get.delete<MessagesController>();
    } else {}
  }
}
