import 'package:jnk_app/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/models/user_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/bottom_navigation_screen.dart';
import 'package:jnk_app/views/screens/change_pass_screen.dart';

class LoginController extends GetxController {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  // final otpKey = GetStorage();
  final storeToken = GetStorage();

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
    // if (txtEmail.text == 'test@gmail.in' && txtPassword.text == '123456') {
    //   DialogHelper.showSuccessToast(description: "Logged in successfully.");
    //   Get.to(() => ChangePassScreen());
    //   return;
    // } else {
    LoginModel loginModel = LoginModel(
      email: txtEmail.text.trim(),
      password: txtPassword.text.trim(),
    );
    var response = await BaseClient().dioPost(
      '/log-in/',
      loginModelToJson(loginModel),
    );
    BaseController.hideLoading();
    if (response != null) {
      print("{LOGIN: $response}");
      if (response['access'] != null ||
          response['refresh'] != null ||
          response['access'] != "" ||
          response['refresh'] != "") {
        DialogHelper.showSuccessToast(description: "Logged in successfully.");
        storeToken.write("token", response['access']);
        storeToken.write("refreshToken", response['refresh']);
        var response1 = await BaseClient().dioPost(
          '/user/fetch-account/',
          null,
        );
        if (response1 != null && response1['status']) {
          // print("{USER DATA: ${response1['data']}}");
          BaseController.user.value = UserModel.fromJson(response1['data']);
          storeToken.write(
            "forcePasswordReset",
            response1['data']['pass_force_reset'],
          );
        } else {}
        if (storeToken.read('forcePasswordReset') == true) {
          Get.to(() => ChangePassScreen());
        } else {
          Get.offAll(() => BottomNavigationScreen());
        }
      } else {
        DialogHelper.showErrorToast(
          description: "Please enter valid mail and password",
        );
      }
    } else {
      // ToastMsg().warningToast(response['message']);
    }
    // }
  }
}
