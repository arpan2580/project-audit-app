import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:jnk_app/consts/app_constants.dart';
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
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => IndividualChatScreen(
                          name: 'Agent $index',
                          profilePicUrl: 'profile_pic_url',
                        ),
                      );
                    },
                    child: AgentsChatWidget(
                      agentName: 'Agent $index',
                      agentProfilePic: 'profile_pic_url',
                      lastMessage: 'Last message snippet',
                      lastActive: 'Yesterday',
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
