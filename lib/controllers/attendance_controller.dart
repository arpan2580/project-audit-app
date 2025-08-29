import 'dart:convert';
import 'package:get/get.dart';
import 'package:jnk_app/models/attendance_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class AttendanceController extends GetxController {
  RxList<AttendanceModel> attendance = RxList<AttendanceModel>();
  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    fetchAttendanceData().then((value) {
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
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to fetch attendance data.",
      );
    }
  }
}
