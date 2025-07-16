import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/utils/custom/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jnk_app/views/screens/bottom_navigation_screen.dart';

class ChangePassScreen extends StatelessWidget {
  const ChangePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTxtColors = Theme.of(context).extension<CustomColor>();
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLarge,
            0,
            AppConstants.paddingLarge,
            AppConstants.paddingMedium,
          ),
          child: Column(
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
              TextField(
                controller: currentPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  suffixIcon: Icon(
                    Icons.visibility_off,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  hintText: "xxxxxxx",
                ),
              ),
              const SizedBox(height: 16),
              const Text("New Password"),
              const SizedBox(height: 6),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  suffixIcon: Icon(
                    Icons.visibility_off,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  hintText: "xxxxxxx",
                ),
              ),
              const SizedBox(height: 16),
              const Text("Confirm Password"),
              const SizedBox(height: 6),
              TextField(
                // controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  suffixIcon: Icon(
                    Icons.visibility_off,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  hintText: "xxxxxxx",
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => BottomNavigationScreen());
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
    );
  }
}
