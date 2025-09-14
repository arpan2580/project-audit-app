import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'JNK Audit App';
  static const String appVersion = '1.0.0';

  // Colors
  // static const Color primaryColor = Color.fromARGB(
  //   223,
  //   255,
  //   55,
  //   41,
  // ); // Deep Orange  0xFFFF6600
  static const Color primaryColor = Color(0xFFC81C10); // Deep Orange
  static const Color logoBlueColor = Color.fromARGB(
    255,
    1,
    161,
    206,
  ); // JNK Blue - Color(0xFF03bdf2)
  static const Color secondaryColor = Color(0xFF4A4A4A); // Grey-ish
  static const Color accentColor =
      Colors.greenAccent; // Teal - Color(0xFF00BFA6)
  static const Color errorColor = Colors.red;
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static Color appBarColor = Color.alphaBlend(
    primaryColor,
    logoBlueColor,
  ); // Primary color with opacity

  // Font Sizes
  static const double fontSmall = 14.0;
  static const double fontRegular = 16.0;
  static const double fontLarge = 20.0;

  // Padding and Margin
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Image Paths
  static const String logo = 'assets/images/logo.png';
  static const String loginIllustration = 'assets/images/login_logo.svg';
  static const String registerIllustration = 'assets/images/register_logo.svg';
  static const String forgotIllustration = 'assets/images/forgot-password.png';
  static const String otpIllustration = 'assets/images/otp_screen.svg';
  static const String profilePlaceholder = 'assets/images/user-profile.png';
  static const String dashboardCardBg = 'assets/images/background-dark.jpeg';

  // Shared Preferences Keys
  static const String themeModeKey = 'theme_mode';
  static const String userTokenKey = 'user_token';

  // Others
  static const double buttonRadius = 10.0;
  static const double inputBorderRadius = 8.0;
}
