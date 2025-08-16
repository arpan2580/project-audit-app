import 'package:flutter/services.dart';

class TimeSettingsService {
  static const platform = MethodChannel('com.yourdomain.time/settings');

  static Future<bool> isTimeAuto() async {
    try {
      final bool result = await platform.invokeMethod('isTimeAutomatic');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check time settings: ${e.message}");
      return false;
    }
  }

  static Future<bool> isTimeZoneAuto() async {
    try {
      final bool result = await platform.invokeMethod('isTimeZoneAutomatic');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check time zone settings: ${e.message}");
      return false;
    }
  }

  static Future<void> openTimeSettings() async {
    try {
      await platform.invokeMethod("openDateTimeSettings");
    } on PlatformException catch (e) {
      print("Failed to open settings: ${e.message}");
    }
  }
}
