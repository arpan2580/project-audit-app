import 'dart:convert';
import 'package:get/get.dart';
import 'package:jnk_app/models/bit_plan_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class BitPlanController extends GetxController {
  RxList<BitPlanModel> bitPlan = RxList<BitPlanModel>();
  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
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
      } else {
        DialogHelper.showErrorToast(description: response['message']);
      }
    } else {
      DialogHelper.showErrorToast(
        description: "Failed to fetch bit plan data.",
      );
    }
  }
}
