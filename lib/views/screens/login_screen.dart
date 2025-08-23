import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/login_controller.dart';
import 'package:jnk_app/utils/custom/custom_color.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
// import 'package:jnk_app/utils/custom/faded_divider.dart';
// import 'package:jnk_app/views/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTxtColors = Theme.of(context).extension<CustomColor>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final LoginController loginController = Get.find();
    Rx<bool> isPassVisible = true.obs;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLarge,
            AppConstants.paddingMedium,
            AppConstants.paddingLarge,
            AppConstants.paddingMedium,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: SvgPicture.asset(
                    AppConstants.loginIllustration,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Login",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Sign-in to your account",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: customTxtColors?.specialTextColor,
                  ),
                ),
                const SizedBox(height: 24),

                const Text("Your Username"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: loginController.txtEmail,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color.fromARGB(255, 109, 109, 109),
                    ),
                    hintText: "johndoe",
                  ),
                  validator: (value) {
                    loginController.txtEmail.text = value?.trim() ?? '';
                    if (loginController.txtEmail.text.isEmpty) {
                      return "Username is required for login";
                    }
                    // else if (!loginController.txtEmail.text.contains('@') ||
                    //     !loginController.txtEmail.text.contains('.in')) {
                    //   return "Email id is not valid";
                    // }
                    else {
                      return null;
                    }
                  },
                ),

                const SizedBox(height: 16),
                const Text("Password"),
                const SizedBox(height: 6),
                Obx(
                  () => TextFormField(
                    controller: loginController.txtPassword,
                    obscureText: isPassVisible.value,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(255, 109, 109, 109),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            isPassVisible.value = !isPassVisible.value,
                        icon: Icon(
                          isPassVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color.fromARGB(255, 109, 109, 109),
                        ),
                      ),
                      hintText: "xxxxxxx",
                    ),
                    validator: (value) {
                      loginController.txtPassword.text = value?.trim() ?? '';
                      if (loginController.txtPassword.text.isEmpty) {
                        return "Password is required for login";
                      } else if (loginController.txtPassword.text.length < 6) {
                        return 'Password must be 6 characters long';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                // const SizedBox(height: 8),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {
                //       Navigator.of(context).push(_createRoute("ForgotScreen"));
                //     },
                //     child: Text(
                //       "Forgot Password?",
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: AppConstants.fontRegular,
                //         color: customTxtColors?.specialTextColor,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        BaseController.showLoading(
                          'Please wait while we verify',
                        );
                        loginController.login();
                      } else {
                        DialogHelper.showErrorToast(
                          description: "Please fill in all fields correctly.",
                        );
                      }
                      // Get.to(() => ChangePassScreen());
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: AppConstants.backgroundColor,
                        fontSize: AppConstants.fontLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
