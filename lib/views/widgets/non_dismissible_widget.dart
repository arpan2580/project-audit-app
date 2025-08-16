import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';

class NonDismissibleWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback? onRefresh;
  final String? retryText;

  const NonDismissibleWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    this.onRefresh,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.black54, // semi-transparent background
        child: Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            insetPadding: EdgeInsets.all(20.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(content, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          onConfirm();
                        },
                        child: Text(
                          confirmText,

                          style: TextStyle(
                            color: AppConstants.backgroundColor,
                            fontSize: AppConstants.fontRegular,
                          ),
                        ),
                      ),
                      if (onRefresh != null) SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: onRefresh,
                        child: Text(
                          retryText ?? "Retry",
                          style: TextStyle(
                            color: AppConstants.backgroundColor,
                            fontSize: AppConstants.fontRegular,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     onConfirm();
                  //   },
                  //   child: Text(
                  //     confirmText,

                  //     style: TextStyle(
                  //       color: AppConstants.backgroundColor,
                  //       fontSize: AppConstants.fontRegular,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
