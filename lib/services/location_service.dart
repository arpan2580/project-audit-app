import 'package:geolocator/geolocator.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class LocationService {
  // Singleton pattern
  // LocationService._();
  // static final LocationService instance = LocationService._();

  static bool _permissionDialogShown = false;
  static bool _gpsDialogShown = false;

  /// Main function to check GPS, permission and mock status
  static Future<void> checkLocation() async {
    // 1. Check if GPS is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      BaseController.gpsEnabled.value = false;
      if (!_gpsDialogShown) {
        _gpsDialogShown = true;
        DialogHelper.showErrorToast(
          description: "GPS is turned off. Please enable it in settings.",
        );
      }
      return;
    } else {
      BaseController.gpsEnabled.value = true;
      _gpsDialogShown = false;
    }

    // 2. Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      BaseController.locationPermission.value = false;
      if (!_permissionDialogShown) {
        _permissionDialogShown = true;
        DialogHelper.showErrorToast(
          description:
              "Location permission is denied. Please enable it in settings.",
        );
      }
      return;
    } else {
      BaseController.locationPermission.value = true;
      _permissionDialogShown = false;
    }

    // 3. Get location & detect mock provider
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      if (position.isMocked) {
        BaseController.locationMocked.value = true;
        DialogHelper.showErrorToast(
          description: "Fake/mock location detected. Please disable mock apps.",
        );
      } else {
        BaseController.locationMocked.value = false;
        BaseController.currentLocation.value = position;
        print("Real location: ${position.latitude}, ${position.longitude}");
      }
    } catch (e) {
      BaseController.locationMocked.value = false;
      DialogHelper.showErrorToast(
        description:
            "Failed to get location. Please check your GPS and permissions.",
      );
    }
  }
}
