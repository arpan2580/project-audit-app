import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/conversations_controller.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/individual_chat_screen.dart';
import 'package:jnk_app/views/widgets/agents_chat_widget.dart';

class AgentsChatScreen extends StatelessWidget {
  const AgentsChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(title: const Text('Agents Chat'), centerTitle: true),
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
            child: SizedBox(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 50.0),
                physics: BouncingScrollPhysics(),
                itemCount: BaseController.user.value?.managersUsers?.length,
                itemBuilder: (BuildContext context, int index) {
                  final agnt = BaseController.user.value?.managersUsers?[index];
                  return GestureDetector(
                    onTap: () async {
                      final conversationSid = agnt.twilioConversationSid;
                      final controller = Get.find<ConversationsController>();
                      BaseController.showLoading();
                      // Ensure client is initialized
                      if (!controller.isClientInitialized.value) {
                        await controller.fetchAccessToken().then((token) async {
                          if (token != null) {
                            await controller.create(jwtToken: token);
                          }
                        });
                      }

                      // Fetch or join the conversation
                      final conversation = await controller
                          .getOrJoinConversation(conversationSid);

                      // if (conversation != null) {
                      //   Get.to(() => ChatScreen(conversation: conversation));
                      // } else {
                      //   DialogHelper.showErrorToast(description: "Unable to open chat.");
                      // }
                      if (conversation != null) {
                        Get.to(
                          () => IndividualChatScreen(
                            name: agnt.name,
                            profilePicUrl: agnt.avatar,
                            conversation: conversation,
                          ),
                        );
                      } else {
                        DialogHelper.showErrorToast(
                          description: "Unable to open chat.",
                        );
                      }
                    },
                    child: AgentsChatWidget(
                      agentName: agnt!.name,
                      agentProfilePic: agnt.avatar,
                      lastMessage: agnt.empCode,
                      lastActive: '',
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
