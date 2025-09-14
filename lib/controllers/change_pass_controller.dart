import 'package:jnk_app/models/change_pass_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/bottom_navigation_screen.dart';

class ChangePassController extends GetxController {
  TextEditingController txtCurrentPassword = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  final otpKey = GetStorage();
  Future<void> changePassword() async {
    if (txtCurrentPassword.text == txtNewPassword.text) {
      DialogHelper.showErrorToast(
        description: "New password cannot be the same as current password.",
      );
      return;
    } else {
      ChangePassModel changePassModel = ChangePassModel(
        oldPass: txtCurrentPassword.text.trim(),
        newPass: txtNewPassword.text.trim(),
      );
      BaseController.showLoading('Please wait while we verify');

      var response = await BaseClient().dioPost(
        '/user/change-password/',
        changePassModelToJson(changePassModel),
      );
      BaseController.hideLoading();
      if (response != null) {
        if (response['status']) {
          DialogHelper.showSuccessToast(description: response['message']);
          Get.offAll(() => BottomNavigationScreen());
        } else {
          DialogHelper.showErrorToast(description: response['message']);
        }
      } else {
        // ToastMsg().warningToast(response['message']);
      }
    }
  }
}
