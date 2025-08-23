import 'package:get/get.dart';
import 'package:jnk_app/models/dashboard_model.dart';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class DashboardController extends GetxController {
  static Rxn<DashboardModel> dashboard = Rxn<DashboardModel>();

  // @override
  // void onInit() async {
  //   super.onInit();

  //   var response = await BaseClient().dioPost('/dashboard/', null);
  //   if (response != null) {
  //     if (response['status']) {
  //       DialogHelper.showSuccessToast(description: response['message']);
  //     } else {
  //       DialogHelper.showErrorToast(description: response['message']);
  //     }
  //   } else {
  //     // ToastMsg().warningToast(response['message']);
  //   }
  // }
}
