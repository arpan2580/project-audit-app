import 'package:jnk_app/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/bottom_navigation_screen.dart';
import 'package:jnk_app/views/screens/change_pass_screen.dart';

class ChangePassController extends GetxController {
  TextEditingController txtCurrentPassword = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();
  final otpKey = GetStorage();
  Future<void> login() async {
    if (txtCurrentPassword.text == txtNewPassword.text) {
      DialogHelper.showErrorToast(
        description: "New password cannot be the same as current password.",
      );
      return;
    }
    if (txtCurrentPassword.text == '123456' &&
        txtNewPassword.text == '1234567') {
      DialogHelper.showSuccessToast(
        description: "Password changed successfully.",
      );
      Get.to(() => BottomNavigationScreen());
      return;
    } else {
      LoginModel loginModel = LoginModel(
        email: txtCurrentPassword.text.trim(),
        password: txtNewPassword.text.trim(),
      );
      BaseController.showLoading('Please wait while we verify');

      var response = await BaseClient().dioPost(
        '/login',
        loginModelToJson(loginModel),
      );
      BaseController.hideLoading();
      if (response != null) {
        if (response['success']) {
          DialogHelper.showSuccessToast(description: response['message']);

          // otpKey.write("otpKey", response['resend_otp_token'].toString());
          Get.to(() => ChangePassScreen());
        } else {
          DialogHelper.showErrorToast(
            description: "Please enter valid mail and password",
          );
        }
      } else {
        // ToastMsg().warningToast(response['message']);
      }
    }
  }
}
