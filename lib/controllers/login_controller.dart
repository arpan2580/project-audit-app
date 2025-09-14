import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/otp_screen.dart';

class LoginController extends GetxController {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  // @override
  // void onInit(BuildContext context) {
  //   super.onInit();
  //   if (BaseController.timeNotSetToAutomatic.value) {
  //     DialogHelper.showNonDismissibleDialog(
  //       context: context,
  //       title: "Configuration Error",
  //       content: Text("Time is NOT set to automatic. Please enable it in settings to proceed."),
  //       confirmText: "Open Settings",
  //       onConfirm: () {
  //         TimeSettingsService.openTimeSettings();
  //         Navigator.pop(context);
  //       },
  //     );
  //   }
  // }

  Future<void> login() async {
    var response = await BaseClient().dioPost(
      '/log-in/',
      json.encode({
        "email": txtEmail.text.trim(),
        "password": txtPassword.text.trim(),
      }),
      false,
      true,
    );
    BaseController.hideLoading();
    if (response != null) {
      print("{LOGIN: $response}");
      if (response['status']) {
        BaseController.loginEmail = response['data']['email'];
        DialogHelper.showSuccessToast(description: response['message']);
        Get.to(() => OtpScreen());
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(
        description: "Something went wrong! Please try later.",
      );
    }
  }
}
