import 'dart:convert';
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/models/attendance_model.dart';
import 'package:jnk_app/models/user_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class AttendanceController extends GetxController {
  RxList<AttendanceModel> attendance = RxList<AttendanceModel>();
  RxList<Agent> agents = RxList<Agent>();
  var chooseAgent = RxList<Agent?>();
  // TextEditingController chooseAgent = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isAgentAttendanceFetch = false.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    fetchAttendanceData().then((value) {
      agents.insert(
        0,
        Agent(
          id: 0,
          name: 'Own Attendance',
          agency: BaseController.user.value!.agency,
          role: BaseController.user.value!.role,
          empCode: BaseController.user.value!.empCode,
          avatar: BaseController.user.value!.avatar,
          twilioUserSid: BaseController.user.value!.twilioUserSid,
          twilioConversationSid:
              BaseController.user.value!.twilioConversationSid,
        ),
      );
      isLoading.value = false;
    });
  }

  Future<void> fetchAttendanceData() async {
    var response = await BaseClient().dioPost(
      '/attendance/',
      json.encode({"agent": ''}),
    );
    if (response != null) {
      print("{ATTENDANCE DATA: ${response.toString()}}");
      if (response['status']) {
        attendance.value = AttendanceModel.fromJsonList(response['data']);
        if (BaseController.user.value?.role == 'mngr') {
          agents.value = BaseController.user.value!.managersUsers ?? [];
          if (agents.isNotEmpty) {
            chooseAgent.value = agents;
          }
        }
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to fetch attendance data.",
      );
    }
  }

  Future<void> fetchAgentAttendance(int agentId) async {
    isAgentAttendanceFetch.value = true;
    var response = await BaseClient().dioPost(
      '/attendance/',
      json.encode({"agent": agentId == 0 ? '' : agentId}),
    );
    if (response != null) {
      print("{AGENT ATTENDANCE: ${response.toString()}}");
      if (response['status']) {
        attendance.value = AttendanceModel.fromJsonList(response['data']);
        // if (BaseController.user.value?.role == 'mngr') {
        //   agents.value = BaseController.user.value!.managersUsers ?? [];
        //   if (agents.isNotEmpty) {
        //     chooseAgent.value = agents;
        //   }
        // }
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to fetch attendance data.",
      );
    }
    isAgentAttendanceFetch.value = false;
  }
}
