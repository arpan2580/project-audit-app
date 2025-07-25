import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/chat_controller.dart';

class ChatWidget extends StatelessWidget {
  final Map<String, dynamic> msg;
  final String timeStr;
  final ChatController chatController;
  const ChatWidget({
    super.key,
    required this.msg,
    required this.timeStr,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    // final ChatController chatController = Get.put(ChatController());
    return GestureDetector(
      onLongPress: () {
        // Toggle the visibility of chat reactions
        chatController.toggleChatReaction(msg['id']);
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: msg['isMe']
                  ? const Color(0xFFD9FDD3) // light green
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: msg['isMe']
                    ? const Radius.circular(12)
                    : Radius.zero,
                bottomRight: msg['isMe']
                    ? Radius.zero
                    : const Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(msg['text'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      // msg['time'],
                      timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (msg['isMe']) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Obx(
            () =>
                chatController.showChatReactions.value &&
                    chatController.selectedChat.value == msg['id']
                ? Positioned(
                    top: -10.0,
                    child: buildReactChatWidget(
                      msg['id'],
                      context,
                      chatController,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
    // );

    // return chatWidgets.isNotEmpty
    //     ? Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: chatWidgets,
    //       )
    //     : const SizedBox.shrink();
  }
}

Widget buildReactChatWidget(
  int messageId,
  BuildContext context,
  ChatController chatController,
) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      // height: 40.0,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.star_border_outlined,
                color: AppConstants.secondaryColor,
                size: 28.0,
              ),
              isSelected: chatController.starredMessages.contains(messageId),
              selectedIcon: const Icon(
                Icons.star,
                color: AppConstants.logoBlueColor,
                size: 28.0,
              ),
              onPressed: () {
                // chatController.hideChatReactions();
                chatController.toggleStarredMessage(messageId);
                print(messageId);
                // Handle star reaction
                print('Starred message $messageId');
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outlined,
                color: Colors.red,
                size: 28.0,
              ),
              onPressed: () {
                chatController.hideChatReactions();
                print('Deleted message $messageId');
              },
            ),
          ],
        ),
      ),
    ),
  );
}
