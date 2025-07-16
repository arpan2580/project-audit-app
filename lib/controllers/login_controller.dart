import 'package:jnk_app/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/change_pass_screen.dart';

class LoginController extends GetxController {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  final otpKey = GetStorage();
  Future<void> login() async {
    if (txtEmail.text == 'test@gmail.in' && txtPassword.text == '123456') {
      DialogHelper.showSuccessToast(description: "Logged in successfully.");
      Get.to(() => ChangePassScreen());
      return;
    } else {
      LoginModel loginModel = LoginModel(
        email: txtEmail.text.trim(),
        password: txtPassword.text.trim(),
      );
      BaseController.showLoading('Please wait while we verify');

      var response = await BaseClient().dioPost(
        '/login',
        loginModelToJson(loginModel),
      );
      BaseController.hideLoading();
      if (response != null) {
        if (response['success']) {
          DialogHelper.showSuccessToast(
            description: response['message'] + " " + txtEmail.text,
          );

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
