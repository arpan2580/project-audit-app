import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/controllers/base_controller.dart';

class GpsLoggerService {
  static Timer? _timer;
  static final Map<String, Map<String, String>> _gpsLogs = {};

  // Start logging every 2 minutes
  static void startLogging() {
    _gpsLogs.clear();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      await captureLocation();
    });
    captureLocation();
  }

  // Stop logging
  static void stopLogging() {
    _timer?.cancel();
    _timer = null;
  }

  // Get logs for API submission (valid JSON)
  static String getLogsJson() {
    return jsonEncode(_gpsLogs);
  }

  // Capture single location entry with retries
  static Future<void> captureLocation() async {
    String timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    Position? position;

    for (int i = 0; i < 3; i++) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        );

        if (position.isMocked) {
          // Mark as mocked
          BaseController.locationMocked.value = true;
          return;
        }

        // Mark GPS as enabled & permission granted
        BaseController.gpsEnabled.value = true;
        BaseController.locationPermission.value = true;
        BaseController.locationMocked.value = false;

        break; // success, break retry loop
      } catch (e) {
        print("Retry ${i + 1}: Failed to get location. Error: $e");
        if (i < 2) await Future.delayed(const Duration(seconds: 10));
      }
    }

    if (position != null) {
      // Success -> log GPS
      _gpsLogs[timestamp] = {
        "lat": position.latitude.toString(),
        "long": position.longitude.toString(),
      };
      print("GPS Log added: $timestamp => ${_gpsLogs[timestamp]}");
    } else {
      // Failed after retries -> log N/A & mark GPS disabled
      _gpsLogs[timestamp] = {"lat": "N/A", "long": "N/A"};
      print("GPS unavailable after retries at $timestamp");
      BaseController.gpsEnabled.value = false;
    }
  }
}
