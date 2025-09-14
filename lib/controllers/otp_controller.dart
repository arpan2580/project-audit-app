import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/controllers/base_controller.dart';
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
      print("{OTP DATA: ${response.toString()}}");
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
          var response1 = await BaseClient().dioPost(
            '/user/fetch-account/',
            null,
          );
          if (response1 != null && response1['status']) {
            // print("{USER DATA: ${response1['data']}}");
            BaseController.user.value = UserModel.fromJson(response1['data']);
            BaseController.storeToken.write(
              "forcePasswordReset",
              response1['data']['pass_force_reset'],
            );
          } else {}
          if (BaseController.storeToken.read('forcePasswordReset') == true) {
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
