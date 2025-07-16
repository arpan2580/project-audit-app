import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';

class SocialCircleWidget extends StatelessWidget {
  const SocialCircleWidget({
    super.key,
    required this.iconPath,
    required this.theme,
  });

  final String iconPath;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.7),
      child: CircleAvatar(
        backgroundColor: theme.scaffoldBackgroundColor,
        radius: 23,
        child: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.transparent,
          backgroundImage: Image.asset(iconPath).image,
          // child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
