// app_bindings.dart
import 'package:get/get.dart';
import 'package:jnk_app/controllers/change_pass_controller.dart';
import 'package:jnk_app/controllers/dashboard_controller.dart';
import 'package:jnk_app/controllers/login_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<ChangePassController>(
      () => ChangePassController(),
      fenix: true,
    );
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
  }
}
