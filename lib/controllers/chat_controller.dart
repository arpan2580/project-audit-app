import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/views/widgets/chat_widget.dart';

class ChatController extends GetxController {
  RxBool showChatReactions = false.obs;
  RxInt selectedChat = (-1).obs; // -1 to indicate none selected

  RxSet<int> starredMessages = <int>{}.obs;
  RxBool showOnlyStarred = false.obs;
  RxList<Widget> chatWidgets = <Widget>[].obs;

  final List<Map<String, dynamic>> messages = const [
    {'id': 1, 'text': 'Hey', 'time': '2025-07-11 17:09:00', 'isMe': false},
    {
      'id': 102,
      'text': 'At what time are we going to the movies?',
      'time': '2025-07-11 17:10:00',
      'isMe': false,
    },
    {
      'id': 11,
      'text': '8PM I think ...',
      'time': '2025-07-11 17:34:00',
      'isMe': true,
    },
    {
      'id': 105,
      'text': 'Testing visual challenge',
      'time': '2025-07-10 17:35:00',
      'isMe': false,
    },
    {'id': 110, 'text': '123', 'time': '2025-07-10 17:35:00', 'isMe': false},
    {'id': 120, 'text': 'Cool :)', 'time': '2025-07-10 17:35:00', 'isMe': true},
    {
      'id': 130,
      'text': 'Testing 1..2...3',
      'time': '2025-07-10 17:35:00',
      'isMe': true,
    },
    {
      'id': 19,
      'text': 'Abcefg............',
      'time': '2025-07-10 17:36:00',
      'isMe': false,
    },
    {
      'id': 12,
      'text': 'Qwertyuiop',
      'time': '2025-07-10 17:36:00',
      'isMe': false,
    },
    {
      'id': 13,
      'text': 'Qwertyuu :)',
      'time': '2025-07-10 17:36:00',
      'isMe': true,
    },
    {
      'id': 14,
      'text': 'I\'m hungry',
      'time': '2025-07-10 17:36:00',
      'isMe': true,
    },
    {
      'id': 15,
      'text': 'I want pizza',
      'time': '2025-07-09 17:36:00',
      'isMe': true,
    },
    {
      'id': 23,
      'text': 'Pizza is awesome!',
      'time': '2025-07-08 16:30:00',
      'isMe': false,
    },
    {
      'id': 24,
      'text': 'I want pizza now, lets meet at dominos near the parking.',
      'time': '2025-07-10 18:01:00',
      'isMe': true,
    },
    {
      'id': 29,
      'text': 'Sure. I\'ll be there in 10 minutes.',
      'time': '2025-07-10 18:05:00',
      'isMe': false,
    },
    {
      'id': 27,
      'text': 'Ok. I have reached. Where are you?',
      'time': '2025-07-10 18:17:00',
      'isMe': true,
    },
  ].obs;

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

  void toggleStarredMessage(int messageId) {
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

  @override
  void onInit() {
    super.onInit();
    filteredMessages;
    buildChatWidgets();
  }
}
