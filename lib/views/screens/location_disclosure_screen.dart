import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/services/location_service.dart';
import 'package:jnk_app/views/dialogs/custom_privacy_dialog.dart';
import 'package:jnk_app/views/screens/animated_splash_screen.dart';
import 'package:jnk_app/views/screens/bottom_navigation_screen.dart';
import 'package:jnk_app/views/screens/login_screen.dart';

class LocationDisclosureScreen extends StatelessWidget {
  final dynamic token;
  final dynamic refreshToken;
  const LocationDisclosureScreen({
    super.key,
    required this.token,
    required this.refreshToken,
  });

  // Future<void> requestPermission(BuildContext context) async {
  //   final status = await Permission.locationAlways.request();

  //   if (status.isGranted) {
  //     Navigator.pop(context, true); // proceed to audit
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Location permission is required to continue audits'),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Access Disclosure'),
        centerTitle: true,
        backgroundColor: AppConstants.primaryColor,
      ),
      body: ListView(
        shrinkWrap: true,
        // crossAxisAlignment: CrossAxisAlignment.start,
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Why we need your location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'The application collects location data at the time of attendance marking '
            'and captures background location data during audit periods to support audit-related activities, '
            'including when the application is closed or not actively in use.\n\n'
            'Location data is used to:\n'
            '• Verify attendance location\n'
            '• Verify audit location\n'
            '• Track audit progress\n'
            '• Ensure audit compliance\n\n'
            '** Background location is captured till the audit is active.\n'
            '** Location data is not shared with third parties.',
            style: TextStyle(fontSize: 16),
          ),
          Center(
            child: SvgPicture.asset(
              'assets/images/location_access.svg',
              height: 330,
              width: 330,
            ),
          ),
          // const Spacer(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(
                      context,
                    ).modalBarrierDismissLabel,
                    barrierColor: Colors.black54,
                    transitionDuration: const Duration(milliseconds: 200),
                    pageBuilder:
                        (
                          BuildContext buildContext,
                          Animation animation,
                          Animation secondaryAnimation,
                        ) {
                          return Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9.0),
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                              ),
                              width: MediaQuery.of(context).size.width - 20,
                              height: MediaQuery.of(context).size.height - 150,
                              padding: const EdgeInsets.all(2),
                              child: CustomPrivacyDialog(),
                            ),
                          );
                        },
                  );
                },
                child: const Text(
                  'View Privacy Policy',
                  style: TextStyle(
                    color: AppConstants.backgroundColor,
                    fontSize: AppConstants.fontLarge,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  GetStorage storage = GetStorage();
                  dynamic page;
                  LocationService.checkLocation();
                  Future.delayed(const Duration(seconds: 2), () {
                    if ((token != null) && (refreshToken != null)) {
                      page = BottomNavigationScreen();
                    } else {
                      page = LoginScreen();
                    }
                    if (!context.mounted) return;
                    storage.write('locationDisclosureAccepted', 'true');
                    BaseController.locationDisclosureAccepted.value = true;
                    Navigator.of(context).pushReplacement(createRoute(page));
                  });
                },
                child: const Text(
                  'I Agree & Continue',
                  style: TextStyle(
                    color: AppConstants.backgroundColor,
                    fontSize: AppConstants.fontLarge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
