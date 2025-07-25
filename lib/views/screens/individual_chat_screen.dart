import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/chat_controller.dart';
import 'package:jnk_app/views/widgets/chat_input_widget.dart';

class IndividualChatScreen extends StatelessWidget {
  final String name;
  final String profilePicUrl;
  const IndividualChatScreen({
    super.key,
    required this.name,
    required this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    // chatController.buildChatWidgets();

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
                backgroundImage: AssetImage(AppConstants.profilePlaceholder),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(width: 10.0),
              Text(name),
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
                    () => ListView(
                      padding: const EdgeInsets.only(bottom: 70),
                      children: chatController.chatWidgets,
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
