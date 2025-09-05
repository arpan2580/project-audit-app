import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jnk_app/models/bit_plan_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class BitPlanController extends GetxController {
  RxList<BitPlanModel> bitPlan = RxList<BitPlanModel>();
  RxList<BitPlanModel> todaysBitPlan = RxList<BitPlanModel>();
  RxList<BitPlanModel> filteredBit = RxList<BitPlanModel>();
  static TextEditingController txtSearchOutlet = TextEditingController();
  RxBool isLoading = false.obs;
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

  Future<void> fetchBitPlanData() async {
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
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
      print("{TODAY's BIT PLAN DATA: ${todaysBitPlan.toString()}}");
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
