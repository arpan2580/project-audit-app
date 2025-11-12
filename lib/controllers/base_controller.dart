import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:jnk_app/controllers/chat_controller.dart';
import 'package:jnk_app/models/user_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class BaseController {
  static const baseUrl = 'https://jnkundu.com/api/v1';
  static RxString deviceId = ''.obs;
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
  static Rx<String> auditorName = ''.obs;
  static RxBool isAuditStarted = false.obs;
  static Rx<int> currAuditOutletId = 0.obs;
  static Rx<String> currAuditOutletName = ''.obs;
  static RxBool isChatInitialized = false.obs;
  static RxBool showReload = true.obs;
  static Rx<int> unreadMessages = 0.obs;
  static RxList chatUsers = [].obs;
  static Rx<String> dayStatus = ''.obs;
  static RxBool isDownloading = false.obs;
  // static final FlutterSecureStorage storeToken = FlutterSecureStorage();
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
    String? refreshToken = storeToken.read('refreshToken');
    // print('refresh: ' + refreshToken.toString());

    if (refreshToken != null && refreshToken != '') {
      var response = await BaseClient().dioPost(
        '/refresh-token/',
        json.encode({"refresh": refreshToken}),
        true,
      );
      if (response != null) {
        if (response['access'] != null && response['access'] != "") {
          storeToken.write('token', response['access']);
          storeToken.write("refreshToken", response['refresh']);
          return true;
        } else {
          sessionExpired();
          return false;
        }
      } else {
        return false;
      }
    } else {
      BaseController.dayStatus.value = '';
      storeToken.remove("token");
      storeToken.remove("refreshToken");
      storeToken.remove("forcePasswordReset");
      storeToken.remove("user_data");
      storeToken.remove("day_status");
      storeToken.remove("currentAudit");
      storeToken.erase();
      return false;
    }
  }

  static void logout() async {
    String? refreshToken = storeToken.read('refreshToken');
    BaseController.showLoading('Logging out...');
    var response = await BaseClient().dioPost(
      '/log-out/',
      json.encode({"refresh": refreshToken}),
    );
    if (response != null) {
      BaseController.dayStatus.value = '';
      storeToken.remove("token");
      storeToken.remove("refreshToken");
      storeToken.remove("forcePasswordReset");
      storeToken.remove("user_data");
      storeToken.remove("day_status");
      storeToken.remove("currentAudit");
      storeToken.erase();
      BaseController.isChatInitialized.value = false;
      ChatController().msgControllerDispose();
      ChatController().dispose();
      Get.delete<ChatController>();
      Get.offAll(() => const LoginScreen());
      DialogHelper.showSuccessToast(description: "Logged out successfully.");
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to log out. Please try again.",
      );
    }
  }

  static void sessionExpired() {
    BaseController.dayStatus.value = '';
    storeToken.remove("token");
    storeToken.remove("refreshToken");
    storeToken.remove("forcePasswordReset");
    storeToken.remove("user_data");
    storeToken.remove("day_status");
    storeToken.remove("currentAudit");
    storeToken.erase();
    BaseController.isChatInitialized.value = false;
    ChatController().msgControllerDispose();
    ChatController().dispose();
    Get.delete<ChatController>();
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

  // Helper function to compress image manually (when not cropping)
  static Future<File> compressImage(File file, int quality) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      // as File?;

      return File(compressedFile!.path);
      // ?? file;
    } catch (e) {
      return file;
    }
  }

  static Future<void> saveImageToGallery(
    String imagePath,
    BuildContext context,
  ) async {
    isDownloading.value = true;
    try {
      if (await requestGalleryPermission(context) == false) {
        DialogHelper.showErrorToast(description: 'Permission denied');
        return;
      }

      // final response = await http.get(Uri.parse(imagePath));
      // if (response.statusCode != 200) {
      //   throw Exception('Failed to download image: ${response.statusCode}');
      // }
      // final Uint8List imageBytes = response.bodyBytes;

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Local image not found at $imagePath');
      }
      final Uint8List imageBytes = await file.readAsBytes();

      // Save image to gallery
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: 'jnk_photo_$timeStamp',
      );

      if (result['isSuccess'] == true || result['filePath'] != null) {
        DialogHelper.showSuccessToast(description: 'Image saved to gallery');
      } else {
        throw Exception('Failed to save image.');
      }
    } catch (e) {
      DialogHelper.showErrorToast(
        description: 'Error saving image, please try again. $e',
      );
    } finally {
      isDownloading.value = false;
    }
  }

  // Handle platform-specific permission requests
  static Future<bool> requestGalleryPermission(context) async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      if (await Permission.photos.isGranted ||
          await Permission.storage.isGranted) {
        return true;
      }

      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      }

      return false;
    } else {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted;
    }
  }
}
