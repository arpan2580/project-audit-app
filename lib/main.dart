import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/location_service.dart';
import 'package:jnk_app/services/time_settings_service.dart';
import 'package:jnk_app/utils/app_bindings.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/animated_splash_screen.dart';
import 'package:jnk_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jnk_app/views/widgets/non_dismissible_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // checkTimeSettings();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register as an observer
    WidgetsBinding.instance.addObserver(this);
    // Check time settings when the app starts
    checkTimeSettings();
    LocationService.checkLocation();
  }

  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isBackground = state == AppLifecycleState.paused;
    final isResumed = state == AppLifecycleState.resumed;
    final isClosed = state == AppLifecycleState.detached;

    if (isBackground || isClosed) {}
    if (isResumed) {
      checkTimeSettings();
      // LocationService.instance.checkLocation();
    }
  }

  void checkTimeSettings() async {
    bool isAutomatic = await TimeSettingsService.isTimeAuto();
    bool isTimeZoneAutomatic = await TimeSettingsService.isTimeZoneAuto();
    if (isAutomatic) {
      BaseController.timeNotSetToAutomatic.value = false;
    } else {
      BaseController.timeNotSetToAutomatic.value = true;
    }

    if (isTimeZoneAutomatic) {
      BaseController.timeZoneNotSetToAutomatic.value = false;
    } else {
      BaseController.timeZoneNotSetToAutomatic.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialBinding: AppBindings(),
      // home: const OtpScreen(),
      home: const AnimatedSplashScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Obx(() {
              if (BaseController.timeNotSetToAutomatic.value ||
                  BaseController.timeZoneNotSetToAutomatic.value) {
                return NonDismissibleWidget(
                  icon: Icons.access_time,
                  title: "Automatic Date & Time Required",
                  content:
                      "Please set date & time and timezone to automatic from settings to continue using the app.",
                  confirmText: "Open Settings",
                  onConfirm: () {
                    TimeSettingsService.openTimeSettings();
                  },
                );
              } else if (BaseController.gpsEnabled.value == false ||
                  BaseController.locationPermission.value == false) {
                return NonDismissibleWidget(
                  icon: Icons.location_off,
                  title: "Location Services Required",
                  content:
                      "Please enable GPS and location permissions to continue using the app.",
                  confirmText: "Open Settings",
                  onConfirm: () async {
                    bool opened = await Geolocator.openLocationSettings();
                    if (!opened) {
                      DialogHelper.showErrorToast(
                        description:
                            "Failed to open location settings. Please enable GPS and permissions manually.",
                      );
                    }
                  },
                  retryText: "Retry",
                  onRefresh: () => LocationService.checkLocation(),
                );
              } else if (BaseController.locationMocked.value) {
                return NonDismissibleWidget(
                  icon: Icons.warning,
                  title: "Mock Location Detected",
                  content:
                      "Please disable mock locations to continue using the app.",
                  confirmText: "Open Settings",
                  onConfirm: () {
                    AppSettings.openAppSettings(asAnotherTask: true);
                  },
                  retryText: "Retry",
                  onRefresh: () => LocationService.checkLocation(),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        );
      },
    );
  }
}
