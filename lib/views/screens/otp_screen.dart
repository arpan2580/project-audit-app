import 'package:flutter_svg/svg.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/otp_controller.dart';
import 'package:jnk_app/utils/custom/custom_color.dart';
import 'package:jnk_app/utils/custom/faded_divider.dart';
import 'package:flutter/material.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTxtColors = Theme.of(context).extension<CustomColor>();
    final OtpController otpController = OtpController();

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal),
      ),
    );

    return Scaffold(
      // appBar: AppBar(),
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
              SizedBox(height: 50),
              Center(
                child: SvgPicture.asset(
                  AppConstants.otpIllustration,
                  height: 320,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "OTP Verfication",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "OTP has been sent on your email",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: customTxtColors?.specialTextColor,
                ),
              ),
              const SizedBox(height: 24),

              const Text("Enter OTP"),
              const SizedBox(height: 6),
              Pinput(
                length: 6,
                controller: otpController.txtOtpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal, width: 2),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal),
                  ),
                ),
                // onCompleted: (pin) => verifyOtp(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    otpController.txtOtpController.text.trim().length == 6
                        ? otpController.verifyOtp()
                        : DialogHelper.showInfoToast(
                            description: "Please enter a valid 6-digit OTP.",
                          );
                  },
                  child: Text(
                    "Verify OTP",
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
