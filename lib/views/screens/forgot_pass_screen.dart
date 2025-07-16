import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/utils/custom/custom_color.dart';
import 'package:jnk_app/utils/custom/faded_divider.dart';
import 'package:flutter/material.dart';

class ForgotPassScreen extends StatelessWidget {
  const ForgotPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTxtColors = Theme.of(context).extension<CustomColor>();
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLarge,
            AppConstants.paddingMedium,
            AppConstants.paddingLarge,
            AppConstants.paddingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  AppConstants.forgotIllustration,
                  height: 220,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Forgot Password",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Password reset instructions will be sent to your email",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: customTxtColors?.specialTextColor,
                ),
              ),
              const SizedBox(height: 24),

              const Text("Your Email"),
              const SizedBox(height: 6),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  hintText: "test@gmail.com",
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Reset Password",
                    style: TextStyle(
                      color: AppConstants.backgroundColor,
                      fontSize: AppConstants.fontLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FadedDivider(
                      color: AppConstants.primaryColor,
                      height: 3.0,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Or"),
                  ),
                  Expanded(
                    child: FadedDivider(
                      color: AppConstants.primaryColor,
                      height: 3.0,
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Go back to Login",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: customTxtColors?.specialTextColor,
                      fontSize: AppConstants.fontRegular,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
