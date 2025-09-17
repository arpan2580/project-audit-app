import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/models/dashboard_model.dart';
import 'package:jnk_app/models/user_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/login_screen.dart';

class DashboardController extends GetxController {
  static Rxn<DashboardModel> dashboard = Rxn<DashboardModel>();
  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;

    // BaseController.user.value = UserModel.fromJson(
    //   BaseController.storeToken.read("user_data"),
    // );
    // Future.delayed(const Duration(seconds: 3), () {
    fetchDashboardData().then((value) {
      isLoading.value = false;
    });
    // });
  }

  static Future<void> fetchUserData() async {
    var response1 = await BaseClient().dioPost('/user/fetch-account/', null);
    if (response1 != null && response1['status']) {
      print("{USER DATA: ${response1['data']}}");
      BaseController.storeToken.write("user_data", response1['data']);
      BaseController.user.value = UserModel.fromJson(
        BaseController.storeToken.read("user_data"),
      );
    } else {
      DialogHelper.showErrorToast(
        description: "Your session has expired. Please log in again.",
      );
      Get.offAll(() => LoginScreen());
    }
  }

  static Future<void> fetchDashboardData({bool fetchUser = false}) async {
    if (BaseController.storeToken.read("user_data") != null) {
      BaseController.user.value = UserModel.fromJson(
        BaseController.storeToken.read("user_data"),
      );
    }
    if (BaseController.user.value == null || fetchUser) {
      fetchUserData();
    }
    var response = await BaseClient().dioPost('/dashboard/', null);
    if (response != null) {
      if (response['status']) {
        print("{DASH DATA: ${response['data']}}");
        dashboard.value = DashboardModel.fromJson(response['data']);
        final attendanceInfo = dashboard.value?.attendanceInfo;
        final lunchBreakInfo = dashboard.value?.lunchBreakInfo;
        if (attendanceInfo?.status != 'present' &&
            attendanceInfo?.checkInTime == null &&
            lunchBreakInfo?.startTime == null &&
            lunchBreakInfo?.endTime == null) {
          BaseController.storeToken.remove("day_status");
        }
        BaseController.isPresent.value =
            attendanceInfo?.status != 'absent' &&
                attendanceInfo?.checkInTime != null
            ? true
            : false;
        BaseController.isLunchBreak.value =
            lunchBreakInfo?.startTime != null && lunchBreakInfo?.endTime == null
            ? true
            : false;
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(description: "Failed to fetch data.");
    }
  }

  Future<void> lunchBreak(String status) async {
    var response = await BaseClient().dioPost(
      '/lunch-break/',
      json.encode({"action": status}),
    );
    if (response != null) {
      if (response['status']) {
        print("{LUNCH DATA: ${response.toString()}}");
        if (status == "start") {
          BaseController.isLunchBreak.value = true;
        } else {
          fetchDashboardData();
          // BaseController.isLunchBreak.value = false;
        }
        DialogHelper.showSuccessToast(description: response['message']);
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(description: "Failed to fetch data.");
    }
  }

  Future<void> markAttendance(File file1, String lat, String long) async {
    BaseController.showLoading('Please wait..');
    dynamic response, formData;
    if (file1.path != '') {
      formData = dio.FormData.fromMap({
        "attendance_image": await dio.MultipartFile.fromFile(
          file1.path,
          filename: file1.path.split('/').last,
        ),
        "latitude": lat,
        "longitude": long,
      });
      response = await BaseClient().dioPost('/mark-attendance/', formData);
      BaseController.hideLoading();
      if (response != null) {
        print("{ATTENDANCE DATA: ${response.toString()}}");
        if (response['status']) {
          // BaseController.isPresent.value = true;
          fetchDashboardData();
          DialogHelper.showSuccessToast(description: response['message']);
        } else {
          DialogHelper.showErrorToast(description: response['messages']);
        }
      }
    } else {
      BaseController.hideLoading();
      DialogHelper.showErrorToast(description: 'Image not recognized');
    }
  }

  Future<void> endAttendance() async {
    BaseController.showLoading('Please wait..');
    var response = await BaseClient().dioPost('/end-attendance/', null);
    if (response != null) {
      if (response['status']) {
        BaseController.hideLoading();
        BaseController.isPresent.value = false;
        BaseController.storeToken.write("day_status", "completed");
        DialogHelper.showSuccessToast(description: response['message']);
      } else {
        BaseController.hideLoading();
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      BaseController.hideLoading();
      DialogHelper.showErrorToast(description: "Failed! Please try later.");
    }
  }

  Future<void> uploadProfilePic(File file1) async {
    BaseController.showLoading('Please wait..');
    dynamic response, formData;
    if (file1.path != '') {
      formData = dio.FormData.fromMap({
        "avatar": await dio.MultipartFile.fromFile(
          file1.path,
          filename: file1.path.split('/').last,
        ),
      });
      response = await BaseClient().dioPost('/user/update-avatar/', formData);
      BaseController.hideLoading();
      if (response != null) {
        if (response['status']) {
          DialogHelper.showSuccessToast(description: response['message']);
        } else {
          DialogHelper.showErrorToast(description: response['messages']);
        }
      }
    } else {
      DialogHelper.showErrorToast(description: 'Image not recognized');
    }
  }
}
