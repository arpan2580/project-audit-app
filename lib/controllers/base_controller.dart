import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jnk_app/models/user_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/login_screen.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class BaseController {
  static const baseUrl = 'https://jnkundu.com/api/v1';
  static var baseImgUrl = '';
  // https://premierclub.itc.in/empulse/public/storage/
  static RxString deviceId = ''.obs;
  // static const captchaUrl =
  //     'https://premierclub.itc.in/EmPulseQA/public/captcha';
  static int expiryTime = 0;
  static RxBool isPresent = false.obs;
  static RxBool isLunchBreak = false.obs;
  static RxBool showOptions = false.obs;
  static Rx<File> imageFile = Rx<File>(File(''));
  static RxBool timeNotSetToAutomatic = false.obs;
  static RxBool timeZoneNotSetToAutomatic = false.obs;
  static RxBool gpsEnabled = false.obs;
  static RxBool locationEnabled = false.obs;
  static RxBool locationPermission = false.obs;
  static RxBool locationMocked = false.obs;
  static Rx<Position> currentLocation = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    heading: 0.0,
    floor: null,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  ).obs;
  static Rxn<UserModel> user = Rxn<UserModel>();
  static String loginEmail = '';
  static Rx<String> startTime = ''.obs;
  static Rx<String> endTime = ''.obs;
  static Rx<String> latitude = ''.obs;
  static Rx<String> longitude = ''.obs;
  static RxBool isAuditStarted = false.obs;
  static Rx<int> currAuditOutletId = 0.obs;

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
      var response = await BaseClient().dioPost(
        '/refresh-token/',
        json.encode({"refresh": refreshToken}),
        true,
      );
      if (response != null) {
        if (response['access'] != null && response['access'] != "") {
          storeToken.write("token", response['access']);
          // storeToken.write("refreshToken", response['refresh']);
          return true;
        } else {
          sessionExpired();
          return false;
        }
      } else {
        return false;
      }
    } else {
      storeToken.remove("token");
      storeToken.remove("refreshToken");
      storeToken.remove("forcePasswordReset");
      storeToken.remove("user_data");
      storeToken.remove("day_status");
      storeToken.remove("currentAudit");
      storeToken.erase();
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

  static void logout() async {
    var refreshToken = storeToken.read('refreshToken');
    BaseController.showLoading('Logging out...');
    var response = await BaseClient().dioPost(
      '/log-out/',
      json.encode({"refresh": refreshToken}),
    );
    if (response != null) {
      print("{LOGOUT DATA: ${response.toString()}}");
      storeToken.remove("token");
      storeToken.remove("refreshToken");
      storeToken.remove("forcePasswordReset");
      storeToken.remove("user_data");
      storeToken.remove("day_status");
      storeToken.remove("currentAudit");
      storeToken.erase();
      Get.offAll(() => const LoginScreen());
      DialogHelper.showSuccessToast(description: "Logged out successfully.");
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to log out. Please try again.",
      );
    }
  }

  static void sessionExpired() {
    storeToken.remove("token");
    storeToken.remove("refreshToken");
    storeToken.remove("forcePasswordReset");
    storeToken.remove("user_data");
    storeToken.remove("day_status");
    storeToken.remove("currentAudit");
    storeToken.erase();
    Get.offAll(() => const LoginScreen());
    // DialogHelper.showErrorToast(
    //   description: 'Your session has expired. Please log in again.',
    // );
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

  /// Helper function to compress image manually (when not cropping)
  static Future<File> compressImage(File file, int quality) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      final compressedFile =
          await FlutterImageCompress.compressAndGetFile(
                file.absolute.path,
                targetPath,
                quality: quality, // adjust as needed
                format: CompressFormat.jpeg,
              )
              as File?;

      return compressedFile ?? file;
    } catch (e) {
      print("Compression not supported on this platform: $e");
      return file; // fallback to original
    } // fallback to original if compression fails
  }
}
