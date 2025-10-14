import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/models/user_model.dart';

class AgentsChatController extends GetxController {
  RxList<Agent> agentsList = RxList<Agent>();
  RxList<Agent> filteredAgents = RxList<Agent>();
  static TextEditingController txtSearchAgent = TextEditingController();
  static RxBool isSearch = false.obs;

  @override
  void onInit() async {
    super.onInit();
    agentsList.value = BaseController.user.value?.managersUsers ?? [];
    filteredAgents.value = agentsList;
  }

  void searchAgent() {
    String query = txtSearchAgent.text.toLowerCase().trim();

    if (query.isEmpty) {
      filteredAgents.value = agentsList;
    } else {
      filteredAgents.value = agentsList
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    }
  }

  void clearSearch() {
    txtSearchAgent.text = '';
    filteredAgents.value = agentsList;
  }
}
