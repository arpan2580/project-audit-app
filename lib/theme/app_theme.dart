import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/utils/custom/custom_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'SairaCondensed',
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      extensions: <ThemeExtension<dynamic>>[
        CustomColor(specialTextColor: Colors.grey.shade700),
      ],
      colorScheme: ColorScheme.light(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.accentColor,
        error: AppConstants.errorColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 3.0,
        shadowColor: Colors.black.withValues(alpha: 0.7),
        iconTheme: IconThemeData(color: AppConstants.backgroundColor),
        shape: Border(
          bottom: BorderSide(width: 0.5, color: AppConstants.backgroundColor),
        ),

        // RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(15.0),
        //     bottomRight: Radius.circular(15.0),
        //   ),
        // ),
        // foregroundColor: Colors.white,
        // backgroundColor: AppConstants.logoBlueColor,
        backgroundColor: Colors.transparent,
        // iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          // color: Colors.black,
          fontFamily: 'Raleway',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'SairaCondensed',
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      extensions: <ThemeExtension<dynamic>>[
        CustomColor(specialTextColor: Colors.white70),
      ],
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.accentColor,
        error: AppConstants.errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Raleway',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
        ),
      ),
    );
  }
}
