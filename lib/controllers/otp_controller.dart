import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/conversations_controller.dart';
import 'package:jnk_app/models/user_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/bottom_navigation_screen.dart';
import 'package:jnk_app/views/screens/change_pass_screen.dart';
import 'package:jnk_app/views/screens/login_screen.dart';

class OtpController extends GetxController {
  TextEditingController txtOtpController = TextEditingController();

  Future<void> verifyOtp() async {
    BaseController.showLoading('Please wait..');
    var response = await BaseClient().dioPost(
      '/verify-otp/',
      {"email": BaseController.loginEmail, "otp": txtOtpController.text.trim()},
      false,
      true,
    );
    if (response != null) {
      if (response['status']) {
        if (response['data']['access'] != null ||
            response['data']['refresh'] != null ||
            response['data']['access'] != "" ||
            response['data']['refresh'] != "") {
          BaseController.hideLoading();
          DialogHelper.showSuccessToast(description: "Logged in successfully.");
          BaseController.storeToken.write("token", response['data']['access']);
          BaseController.storeToken.write(
            "refreshToken",
            response['data']['refresh'],
          );
          // A new session has started. logout() sets this flag to abort any
          // in-flight chat initialization, and it is static, so without
          // clearing it here a logout -> login in the same process leaves chat
          // permanently uninitialized.
          BaseController.isUserLoggedOut.value = false;
          BaseController.isChatInitialized.value = false;
          BaseController.chatInitRetryCount = 0;
          // Drop the previous user's Twilio client and listeners before the new
          // session builds its own.
          if (Get.isRegistered<ConversationsController>()) {
            await Get.find<ConversationsController>().resetSession();
          }
          var response1 = await BaseClient().dioPost(
            '/user/fetch-account/',
            null,
          );
          if (response1 != null && response1['status']) {
            BaseController.user.value = UserModel.fromJson(response1['data']);
            BaseController.storeToken.write(
              "forcePasswordReset",
              response1['data']['pass_force_reset'],
            );
          } else {}
          final forcePassReset = BaseController.storeToken.read(
            'forcePasswordReset',
          );
          if (forcePassReset == 'true') {
            Get.to(() => ChangePassScreen());
          } else {
            Get.offAll(() => BottomNavigationScreen());
          }
        } else {
          BaseController.hideLoading();
          DialogHelper.showErrorToast(
            description: "Login failed! Please try again.",
          );
          Get.offAll(() => LoginScreen());
        }
      } else {
        BaseController.hideLoading();
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      BaseController.hideLoading();
      DialogHelper.showErrorToast(
        description: "OTP verification failed. Please try later.",
      );
      Get.offAll(() => LoginScreen());
    }
  }
}
