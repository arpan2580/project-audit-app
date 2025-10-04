import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/models/bit_plan_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class BitPlanController extends GetxController {
  RxList<BitPlanModel> bitPlan = RxList<BitPlanModel>();
  RxList<BitPlanModel> todaysBitPlan = RxList<BitPlanModel>();
  RxList<BitPlanModel> filteredBit = RxList<BitPlanModel>();
  static TextEditingController txtSearchOutlet = TextEditingController();
  RxBool isLoading = true.obs;
  static RxBool isSearch = false.obs;
  static RxBool isViewAll = false.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    todaysBitPlan.bindStream(
      bitPlan.stream.map(
        (list) => list.where((item) => item.isInBitPlan).toList(),
      ),
    );
    fetchBitPlanData().then((value) {
      isLoading.value = false;
    });
  }

  void initData() async {
    isLoading.value = true;
    todaysBitPlan.bindStream(
      bitPlan.stream.map(
        (list) => list.where((item) => item.isInBitPlan).toList(),
      ),
    );
    fetchBitPlanData().then((value) {
      isLoading.value = false;
    });
  }

  Future<void> fetchBitPlanData() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var response = await BaseClient().dioPost('/outlets/', null);
    if (response != null) {
      print("{BIT PLAN DATA: ${response.toString()}}");
      if (response['status']) {
        bitPlan.value = BitPlanModel.fromJsonList(response['data']);
        if (isViewAll.value) {
          filteredBit.value = bitPlan;
        } else {
          filteredBit.value = todaysBitPlan;
        }
        for (var item in bitPlan) {
          if (item.lastVisit != null &&
              item.lastVisit?.date == today &&
              item.lastVisit?.endTime == null &&
              item.lastVisit?.status == 'started') {
            BaseController.storeToken.write(
              'currentAudit',
              json.encode({
                "outletId": item.id,
                "startTime": item.lastVisit?.startTime,
                "latitude": item.lastVisit?.lat,
                "longitude": item.lastVisit?.long,
                "isAuditStarted": true,
                "visitId": item.lastVisit?.id,
              }),
            );
          }
        }
        final String? storedAudit = BaseController.storeToken.read(
          'currentAudit',
        );

        if (storedAudit != null && storedAudit.isNotEmpty) {
          // Decode JSON to a Map
          final Map<String, dynamic> auditData = json.decode(storedAudit);

          // Assign values to your reactive variables
          BaseController.endTime.value =
              ''; // Reset or fetch from API if needed
          BaseController.isAuditStarted.value =
              auditData['isAuditStarted'] ?? false;
          BaseController.currAuditOutletId.value = auditData['outletId'] ?? 0;
          BaseController.latitude.value = auditData['latitude'].toString();
          BaseController.longitude.value = auditData['longitude'].toString();
          BaseController.startTime.value = auditData['startTime'] ?? '';
        } else {
          print("No current audit data found in storage.");
        }
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
      print(
        "{TODAY's BIT PLAN DATA: ${todaysBitPlan.map((e) => e.toJson()).toList()}}",
      );
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to fetch bit plan data.",
      );
    }
  }

  void searchOutlet() {
    String query = txtSearchOutlet.text.toLowerCase().trim();

    if (query.isEmpty) {
      if (BitPlanController.isViewAll.value) {
        filteredBit.value = bitPlan;
      } else {
        filteredBit.value = todaysBitPlan;
      }
    } else {
      if (BitPlanController.isViewAll.value) {
        filteredBit.value = bitPlan
            .where((item) => item.olCode.toLowerCase().contains(query))
            .toList();
      } else {
        filteredBit.value = todaysBitPlan
            .where((item) => item.olCode.toLowerCase().contains(query))
            .toList();
      }
    }
  }

  void clearSearch() {
    txtSearchOutlet.text = '';
    print(BitPlanController.isViewAll.value);
    if (BitPlanController.isViewAll.value) {
      filteredBit.value = bitPlan;
    } else {
      filteredBit.value = todaysBitPlan;
    }
  }
}
