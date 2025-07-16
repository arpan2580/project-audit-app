import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:flutter/cupertino.dart';

class AuditorInfoWidget extends StatelessWidget {
  final String title;
  final String value;
  final bool scroll;
  const AuditorInfoWidget({
    super.key,
    required this.title,
    required this.value,
    this.scroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return scroll
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  "$title:",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.backgroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.backgroundColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : Row(
            children: [
              Text(
                "$title:",
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.backgroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.backgroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
  }
}
