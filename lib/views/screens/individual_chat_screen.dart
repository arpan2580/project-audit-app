import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twilio_chat_conversations/twilio_conversations.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/chat_controller.dart';
import 'package:jnk_app/controllers/messages_controller.dart';
import 'package:jnk_app/views/widgets/chat_input_widget.dart';

class IndividualChatScreen extends StatefulWidget {
  final String name;
  final String profilePicUrl;
  final Conversation conversation;
  const IndividualChatScreen({
    super.key,
    required this.name,
    required this.profilePicUrl,
    required this.conversation,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  late final ChatController chatController;
  late final MessagesController msgController;
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ChatController>()) {
      chatController = Get.put(ChatController(), permanent: true);
    } else {
      chatController = Get.find<ChatController>();
    }
    msgController = Get.find<MessagesController>();
    msgController.initConversation(widget.conversation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Close reactions when tapped outside
        chatController.hideChatReactions();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          actions: [
            Obx(
              () => IconButton(
                icon: Icon(
                  chatController.showOnlyStarred.value
                      ? Icons.star
                      : Icons.star_border_outlined,
                  size: 30.0,
                ),
                tooltip: chatController.showOnlyStarred.value
                    ? 'Show All Messages'
                    : 'Show Starred Only',
                onPressed: () {
                  chatController.toggleShowOnlyStarred();
                  chatController.buildChatWidgets(
                    customMessages: chatController.filteredMessages,
                  );
                },
              ),
            ),
          ],
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                // backgroundImage: AssetImage(AppConstants.profilePlaceholder),
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.profilePicUrl,
                    fit: BoxFit.cover,
                    width: 160, // 2 * radius
                    height: 160,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 40),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Text(widget.name),
            ],
          ),
          titleSpacing: 0,
          // backgroundColor: AppConstants.logoBlueColor,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConstants.dashboardCardBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  AppConstants.primaryColor.withValues(alpha: 0.5),
                  AppConstants.backgroundColor.withValues(alpha: 0.5),
                  AppConstants.backgroundColor.withValues(alpha: 0.7),
                  AppConstants.backgroundColor.withValues(alpha: 0.7),
                  AppConstants.backgroundColor.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Chat messages list
                  Obx(
                    () => MessagesController.isLoading.value
                        ? Center(child: CircularProgressIndicator.adaptive())
                        : Obx(
                            () => ListView(
                              controller: msgController.listScrollController,
                              reverse: true,
                              padding: const EdgeInsets.only(bottom: 70),
                              children: chatController.chatWidgets.reversed
                                  .toList(),
                            ),
                          ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ChatInputWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
