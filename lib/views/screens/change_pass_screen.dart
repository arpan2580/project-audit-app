import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/change_pass_controller.dart';
import 'package:jnk_app/utils/custom/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class ChangePassScreen extends StatelessWidget {
  const ChangePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTxtColors = Theme.of(context).extension<CustomColor>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final ChangePassController changePassController = Get.find();
    Rx<bool> isPassVisible = true.obs;
    Rx<bool> isNewPassVisible = true.obs;
    Rx<bool> isConfPassVisible = true.obs;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLarge,
            0,
            AppConstants.paddingLarge,
            AppConstants.paddingMedium,
          ),
          child: Form(
            key: formKey,
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AppConstants.registerIllustration,
                      height: 220,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Change Password",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Change your password to keep your account secure",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: customTxtColors?.specialTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Current Password"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: changePassController.txtCurrentPassword,
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
                      changePassController.txtCurrentPassword.text =
                          value?.trim() ?? '';
                      if (changePassController
                          .txtCurrentPassword
                          .text
                          .isEmpty) {
                        return "Please enter current password to continue";
                      } else if (changePassController
                              .txtCurrentPassword
                              .text
                              .length <
                          6) {
                        return 'Password must be 6 characters long';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("New Password"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: changePassController.txtNewPassword,
                    obscureText: isNewPassVisible.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(255, 109, 109, 109),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            isNewPassVisible.value = !isNewPassVisible.value,
                        icon: Icon(
                          isNewPassVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromARGB(255, 109, 109, 109),
                        ),
                      ),
                      hintText: "xxxxxxx",
                    ),
                    validator: (value) {
                      changePassController.txtNewPassword.text =
                          value?.trim() ?? '';
                      if (changePassController.txtNewPassword.text.isEmpty) {
                        return "Please enter new password to continue";
                      } else if (changePassController
                              .txtNewPassword
                              .text
                              .length <
                          6) {
                        return 'Password must be 6 characters long';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Confirm Password"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: changePassController.txtConfirmPassword,
                    obscureText: isConfPassVisible.value,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(255, 109, 109, 109),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            isConfPassVisible.value = !isConfPassVisible.value,
                        icon: Icon(
                          isConfPassVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color.fromARGB(255, 109, 109, 109),
                        ),
                      ),
                      hintText: "xxxxxxx",
                    ),
                    validator: (value) {
                      changePassController.txtConfirmPassword.text =
                          value?.trim() ?? '';
                      if (changePassController
                          .txtConfirmPassword
                          .text
                          .isEmpty) {
                        return "Please confirm new password to continue";
                      } else if (changePassController.txtConfirmPassword.text !=
                          changePassController.txtNewPassword.text) {
                        return "New password and confirm password does not match";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          changePassController.changePassword();
                        } else {
                          DialogHelper.showErrorToast(
                            description: "Please fill in all fields correctly.",
                          );
                        }
                      },
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          color: AppConstants.backgroundColor,
                          fontSize: AppConstants.fontLarge,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
