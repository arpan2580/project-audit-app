import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/chat_controller.dart';
import 'package:jnk_app/views/screens/image_view_screen.dart';

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
    return GestureDetector(
      onLongPress: () {
        // Toggle the visibility of chat reactions
        chatController.toggleChatReaction(msg['id']);
      },
      child: Stack(
        clipBehavior: Clip.none,

        alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              msg['isMe']
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 4.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: msg['profilePic'],
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            placeholder: (context, url) =>
                                Image.asset(AppConstants.profilePlaceholder),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error, size: 40),
                          ),
                        ),
                      ),
                    ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: msg['isMe']
                        ? const Color(0xFFD9FDD3) // light green
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: msg['isMe']
                          ? const Radius.circular(12)
                          : Radius.zero,
                      topRight: const Radius.circular(12),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: msg['isMe']
                          ? Radius.zero
                          : const Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: (msg['isMe'])
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      (msg['isMe'])
                          ?
                            // Text(
                            // BaseController.user.value!.name,
                            // style: const TextStyle(
                            //   fontSize: 14,
                            //   fontWeight: FontWeight.w500,
                            // ),
                            // )
                            SizedBox()
                          : Text(
                              msg['author'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      (msg['isMe'])
                          ? const SizedBox(height: 0)
                          : const SizedBox(height: 4),
                      (msg['isMedia'] == true && msg['text'] == '')
                          ? SizedBox(
                              width: 200,
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            )
                          : (msg['isMedia'] == true && msg['text'] != '')
                          ? GestureDetector(
                              onTap: () {
                                if (msg['isLocal']) {
                                  Get.to(
                                    () => ImageViewScreen(
                                      imageUrl: msg['text'],
                                      isLocal: true,
                                      showDownloadButton: true,
                                    ),
                                  );
                                } else {
                                  Get.to(
                                    () => ImageViewScreen(
                                      imageUrl: msg['text'],
                                      isLocal: false,
                                      showDownloadButton: true,
                                    ),
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (msg['isLocal'])
                                    ? Image.file(
                                        File(msg['text']),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        msg['text'],
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(Icons.error);
                                            },
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            )
                          : Text(
                              msg['text'],
                              style: const TextStyle(fontSize: 16),
                            ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          // if (msg['isMe']) ...[
                          //   const SizedBox(width: 4),
                          //   const Icon(Icons.done_all, size: 16, color: Colors.grey),
                          // ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () =>
                chatController.showChatReactions.value &&
                    chatController.selectedChat.value == msg['id']
                ? Positioned(
                    top: -25.0,
                    child: buildReactChatWidget(
                      msg['id'],
                      msg['sid'],
                      msg['isMe'],
                      context,
                      chatController,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

Widget buildReactChatWidget(
  int messageId,
  String sid,
  bool isMe,
  BuildContext context,
  ChatController chatController,
) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      // height: 40.0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
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
              isSelected: chatController.starredMessages.contains(sid),
              selectedIcon: const Icon(
                Icons.star,
                color: AppConstants.logoBlueColor,
                size: 28.0,
              ),
              onPressed: () {
                chatController.toggleStarredMessage(messageId, sid);
              },
            ),
            (isMe)
                ? IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 28.0,
                    ),
                    onPressed: () {
                      chatController.hideChatReactions();
                      chatController.msgController.deleteMessageBySid(sid);
                      print('Deleted message $messageId - $sid');
                    },
                  )
                : SizedBox(),
          ],
        ),
      ),
    ),
  );
}
