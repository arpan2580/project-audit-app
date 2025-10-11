import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/agents_chat_controller.dart';
import 'package:jnk_app/controllers/base_controller.dart';

class SearchAgentWidget extends StatelessWidget {
  final AgentsChatController controller;
  const SearchAgentWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: TextField(
        onTap: () {
          BaseController.showOptions.value = false;
        },
        onChanged: (value) {
          if (value == '') {
            AgentsChatController.txtSearchAgent.clear();
            AgentsChatController.isSearch.value = false;
            controller.clearSearch();
          }
        },
        controller: AgentsChatController.txtSearchAgent,
        decoration: InputDecoration(
          hintText: 'Search Agent',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 8.0,
              right: 4.0,
              bottom: 8.0,
            ),
            child: SvgPicture.asset(
              'assets/icons/Profile.svg',
              height: 20,
              // width: 28.0,
            ),
          ),
          suffixIcon: !AgentsChatController.isSearch.value
              ? IconButton(
                  onPressed: () {
                    if (AgentsChatController.txtSearchAgent.text.isNotEmpty) {
                      AgentsChatController.isSearch.value = true;
                      controller.searchOutlet();
                    } else {
                      AgentsChatController.txtSearchAgent.clear();
                      AgentsChatController.isSearch.value = false;
                      controller.clearSearch();
                    }
                  },
                  icon: Icon(
                    Icons.search,
                    size: 40.0,
                    color: AppConstants.logoBlueColor,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    // if (AgentsChatController.txtSearchAgent.text.isNotEmpty) {
                    AgentsChatController.txtSearchAgent.clear();
                    AgentsChatController.isSearch.value = false;
                    controller.clearSearch();
                    // }
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 35.0,
                    color: AppConstants.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }
}
