import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/bit_plan_controller.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/services/gps_logger_service.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class OutletController extends GetxController {
  static Rx<File?> imageFile = Rx<File?>(null);
  final bitPlanController = Get.find<BitPlanController>();

  Future<void> startAudit(File file1, String lat, String long, int id) async {
    BaseController.showLoading('Please wait..');
    dynamic response, formData;
    if (file1.path != '') {
      formData = dio.FormData.fromMap({
        "outlet_image": await dio.MultipartFile.fromFile(
          file1.path,
          filename: file1.path.split('/').last,
        ),
        "start_latitude": lat,
        "start_longitude": long,
        "outlet_id": id,
      });
      response = await BaseClient().dioPost('/visit/start/', formData);
      if (response != null) {
        print("{START AUDIT DATA: ${response.toString()}}");
        if (response['status']) {
          BaseController.storeToken.write(
            'currentAudit',
            json.encode({
              "outletId": id,
              "startTime": response['data']['start_time'],
              "latitude": lat,
              "longitude": long,
              "isAuditStarted": true,
              "visitId": response['data']['visit_id'],
              // "visitCode": response['data']['visit_code'],
            }),
          );
          print(
            "{CURRENT AUDIT: ${BaseController.storeToken.read('currentAudit')}}",
          );
          BaseController.endTime.value = '';
          BaseController.isAuditStarted.value = true;
          BaseController.currAuditOutletId.value = id;
          BaseController.latitude.value = lat;
          BaseController.longitude.value = long;
          BaseController.startTime.value = response['data']['start_time']
              .toString();
          bitPlanController.initData();
          GpsLoggerService.startLogging();
          BaseController.hideLoading();
          DialogHelper.showSuccessToast(description: response['message']);
        } else {
          BaseController.hideLoading();
          DialogHelper.showErrorToast(description: response['messages']);
        }
      }
    } else {
      BaseController.hideLoading();
      DialogHelper.showErrorToast(description: 'Image not recognized');
    }
  }

  Future<void> endAudit(String lat, String long, int visitId) async {
    BaseController.showLoading('Please wait..');
    GpsLoggerService.stopLogging();
    String gpsLogs = GpsLoggerService.getLogsJson();
    var response = await BaseClient().dioPost('/visit/end/', {
      "visit_id": visitId,
      "end_latitude": lat,
      "end_longitude": long,
      "gps_log": gpsLogs,
    });
    if (response != null) {
      print("{END AUDIT DATA: ${response.toString()}}");
      if (response['status']) {
        BaseController.storeToken.remove('currentAudit');
        BaseController.isAuditStarted.value = false;
        BaseController.currAuditOutletId.value = 0;
        BaseController.latitude.value = '';
        BaseController.longitude.value = '';
        BaseController.startTime.value = '';
        // BaseController.endTime.value = DateTime.now().toString();

        bitPlanController.initData();
        BaseController.hideLoading();
        Get.back();
        DialogHelper.showSuccessToast(description: response['message']);
      } else {
        BaseController.hideLoading();
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      BaseController.hideLoading();
      DialogHelper.showErrorToast(
        description: "Failed to fetch attendance data.",
      );
    }
  }
}
