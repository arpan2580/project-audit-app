import 'dart:async';

import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/login_screen.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';

class BaseController {
  static const baseUrl = 'https://premierclub.itc.in/EmPulseQA/public/api/v1';
  static var baseImgUrl = '';
  // https://premierclub.itc.in/empulse/public/storage/
  static RxString deviceId = ''.obs;
  static const captchaUrl =
      'https://premierclub.itc.in/EmPulseQA/public/captcha';
  static int expiryTime = 0;
  static RxBool isPresent = false.obs;
  static RxBool isLunchBreak = false.obs;
  static RxBool showOptions = false.obs;
  // static dynamic unreadNotification = 0.obs;
  // static dynamic assignedPosts = 0.obs;
  // static RxBool commentReload = false.obs;

  // static RxBool isMyFeedOpen = true.obs;
  // static RxBool isSearchApplied = false.obs;
  // static RxString searchString = ''.obs;

  // static RxList isLikedPost = [].obs;
  // static RxList likedFeedbackId = [].obs;
  // static RxList postLikedCount = [].obs;

  static RxBool showReload = true.obs;

  // static RxInt timerCountdown = 60.obs;
  // static RxBool isCountdownEnd = false.obs;
  // static RxBool otpScreen = false.obs;

  // static RxBool notifcationReload = false.obs;

  // static Map<String, dynamic> searchData = {};

  // static RxList feedbackStatusId = [].obs;
  static final storeToken = GetStorage();

  static showLoading([String? message]) {
    DialogHelper.showLoadingDialog(message);
  }

  static showLinearLoading([String? message]) {
    DialogHelper.showLinearDialog(message);
  }

  static hideLoading() {
    DialogHelper.hideLoadingDialog();
  }

  static Future<dynamic> tokenGeneration() async {
    var refreshToken = storeToken.read('refreshToken');
    // print('refresh: ' + refreshToken.toString());

    if (refreshToken != null && refreshToken != '') {
      var response = await BaseClient().dioPost('/refresh-token', null, true);
      if (response != null) {
        if (response['success']) {
          storeToken.write("token", response['token']);
          storeToken.write("refreshToken", response['refresh_token']);
          return true;
        } else {
          storeToken.remove("token");
          storeToken.remove("refreshToken");
          // storeToken.remove("unreadNotification");
          // storeToken.remove("assignedPost");
          // storeToken.remove("company");
          // storeToken.remove("genre");
          // // storeToken.remove("baseImgUrl");
          // storeToken.remove("aboutAppUrl");
          // storeToken.remove("defaultBio");
          // storeToken.remove("baseVersionAppUrl");
          // storeToken.remove("privacyUrl");
          // storeToken.remove("supportUrl");

          Get.offAll(() => const LoginScreen());
          DialogHelper.showErrorToast(
            description:
                'Your session is expired. Please login again to continue.',
          );
          return false;
        }
      } else {
        return false;
      }
    } else {
      storeToken.remove("token");
      storeToken.remove("refreshToken");
      // storeToken.remove("unreadNotification");
      // storeToken.remove("assignedPost");
      // storeToken.remove("company");
      // storeToken.remove("genre");
      // // storeToken.remove("baseImgUrl");
      // storeToken.remove("aboutAppUrl");
      // storeToken.remove("defaultBio");
      // storeToken.remove("baseVersionAppUrl");
      // storeToken.remove("privacyUrl");
      // storeToken.remove("supportUrl");

      return false;
    }
  }

  static getinitials(name) {
    name = name.trim();
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = 2;

    if (numWords < names.length) {
      numWords = names.length;
    }
    for (var i = 0; i < numWords; i++) {
      if (names.length > 1) {
        initials += names[i][0];
      } else {
        initials = names[0][0];
      }
    }
    return initials;
  }

  Future<void> fetchGlobalData() async {
    // if (isLoggedIn.read('unreadNotification') == null ||
    //     isLoggedIn.read('assignedPost') == null) {

    var response = await BaseClient().dioPost('/my-global-data', null);
    if (response != null && response['success']) {
      storeToken.write(
        "unreadNotification",
        response['data']['unread_notification_count'],
      );
      storeToken.write(
        "assignedPost",
        response['data']['assigned_feedback_count'],
      );
    } else {
      storeToken.write("unreadNotification", 0);
      storeToken.write("assignedPost", 0);
    }
    // }
    // unreadNotification.value = storeToken.read('unreadNotification');
    // assignedPosts.value = storeToken.read('assignedPost');
  }

  static late Timer _timer;
  static void otpCountdown(countDown) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countDown.value > 0) {
        countDown.value = countDown.value - 1;
      } else {
        // isCountdownEnd.value = true;
        _timer.cancel();
      }
    });
  }

  static void timerStop() {
    _timer.cancel();
  }
}
