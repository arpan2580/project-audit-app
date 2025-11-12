import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/conversations_controller.dart';
import 'package:jnk_app/models/dashboard_model.dart';
import 'package:jnk_app/models/user_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class DashboardController extends GetxController {
  static Rxn<DashboardModel> dashboard = Rxn<DashboardModel>();
  // static late final ConversationsController controller;
  final ConversationsController controller = Get.put(ConversationsController());
  static RxBool isLoading = true.obs;
  String? jwtToken;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    // Future.delayed(const Duration(seconds: 3), () {
    // fetchUserData().then((value) {
    //   fetchDashboardData(fetchUser: false);
    // isLoading.value = false;
    // });
    fetchUserData();
    // });
  }

  static Future<void> fetchUserData() async {
    var response1 = await BaseClient().dioPost('/user/fetch-account/', null);
    if (response1 != null && response1['status']) {
      // print("{USER DATA: ${response1['data']}}");
      BaseController.storeToken.write("user_data", response1['data']);
      BaseController.user.value = UserModel.fromJson(response1['data']);
      BaseController.chatUsers.value = [
        if (BaseController.user.value?.manager != null)
          BaseController.user.value?.manager,
        ...(BaseController.user.value?.managersUsers ?? []),
        ...(BaseController.user.value?.adminUsers ?? []),
      ];
    } else {
      DialogHelper.showErrorToast(
        description: "Your session has expired. Please log in again.",
      );
      // Get.offAll(() => LoginScreen());
    }
  }

  Future<void> fetchDashboardData({bool fetchUser = false}) async {
    final userJson = BaseController.storeToken.read("user_data");
    if (userJson != null) {
      BaseController.user.value = UserModel.fromJson(userJson);
    }
    if (BaseController.user.value == null || fetchUser) {
      fetchUserData();
    }
    var response = await BaseClient().dioPost('/dashboard/', null);
    if (response != null) {
      if (response['status']) {
        // print("{DASH DATA: ${response['data']}}");
        dashboard.value = DashboardModel.fromJson(response['data']);
        final attendanceInfo = dashboard.value?.attendanceInfo;
        final lunchBreakInfo = dashboard.value?.lunchBreakInfo;
        if (attendanceInfo?.status != 'present' &&
            attendanceInfo?.checkInTime == null &&
            lunchBreakInfo?.startTime == null &&
            lunchBreakInfo?.endTime == null) {
          BaseController.storeToken.remove("day_status");
          BaseController.dayStatus.value = "";
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
        isLoading.value = false;
        await initChatWithRetry(controller);
        // if (BaseController.isChatInitialized.value == false) {
        //   await controller.fetchAccessToken().then((value) async {
        //     // print("{TWILIO TOKEN: $value}");
        //     await controller.create(jwtToken: value!).then((onValue) {
        //       controller
        //           .getOrJoinConversation(
        //             BaseController.user.value!.twilioConversationSid,
        //           )
        //           .then((val) {
        //             BaseController.isChatInitialized.value = true;
        //           });
        //     });
        //   });
        // }
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
        // print("{LUNCH DATA: ${response.toString()}}");
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
      if (response != null) {
        // print("{ATTENDANCE DATA: ${response.toString()}}");
        if (response['status']) {
          // BaseController.isPresent.value = true;
          fetchDashboardData();
          BaseController.hideLoading();
          DialogHelper.showSuccessToast(description: response['message']);
        } else {
          BaseController.hideLoading();
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
        BaseController.dayStatus.value = "completed";
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

  Future<void> initChatWithRetry(ConversationsController controller) async {
    if (BaseController.isChatInitialized.value == true ||
        BaseController.isUserLoggedOut.value == true) {
      return;
    }

    final initializationFuture = initializeChat(controller);
    final timeoutFuture = waitForInitialization(timeout: 13);
    final success = await Future.any([
      initializationFuture.then((_) => true),
      timeoutFuture,
    ]);
    if (!success) {
      BaseController.chatInitRetryCount += 1;
      if (BaseController.chatInitRetryCount >=
          BaseController.maxChatInitRetries) {
        Get.dialog(
          AlertDialog(
            title: const Text("Chat Initialization Failed"),
            content: const Text(
              "Chat could not be initialized after multiple attempts. Please check your connection or try again later.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return;
      }
      showRetryDialog(controller);
    } else {
      BaseController.chatInitRetryCount = 0;
    }
  }

  Future<void> initializeChat(ConversationsController controller) async {
    try {
      if (BaseController.isUserLoggedOut.value == true) return;
      final token = await controller.fetchAccessToken();
      if (token == null) {
        throw Exception("Failed to get Twilio token");
      }
      await controller.create(jwtToken: token);
      await controller.getOrJoinConversation(
        BaseController.user.value!.twilioConversationSid,
      );

      if (BaseController.isUserLoggedOut.value == false) {
        BaseController.isChatInitialized.value = true;
      }
    } catch (e) {
      // print("Chat initialization failed: $e");
    }
  }

  Future<bool> waitForInitialization({int timeout = 13}) async {
    const checkInterval = Duration(seconds: 1);
    final maxWaitTime = Duration(seconds: timeout);
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < maxWaitTime) {
      if (BaseController.isChatInitialized.value == true ||
          BaseController.isUserLoggedOut.value == true) {
        stopwatch.stop();
        return true;
      }
      await Future.delayed(checkInterval);
    }
    return false;
  }

  void showRetryDialog(ConversationsController controller) {
    if (BaseController.isUserLoggedOut.value == true) return;
    Get.dialog(
      AlertDialog(
        title: const Text("Chat Initialization Timeout"),
        content: const Text(
          "Chat could not be initialized. Please click on retry button to try again.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              BaseController.isChatInitialized.value = false;
              if (!BaseController.isUserLoggedOut.value) {
                initChatWithRetry(controller);
              }
            },
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
