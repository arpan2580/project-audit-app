import 'package:flutter/material.dart';

@immutable
class CustomColor extends ThemeExtension<CustomColor> {
  const CustomColor({required this.specialTextColor});

  final Color? specialTextColor;

  @override
  CustomColor copyWith({Color? specialTextColor}) {
    return CustomColor(
      specialTextColor: specialTextColor ?? this.specialTextColor,
    );
  }

  @override
  CustomColor lerp(ThemeExtension<CustomColor>? other, double t) {
    if (other is! CustomColor) {
      return this;
    }
    return CustomColor(
      specialTextColor: Color.lerp(specialTextColor, other.specialTextColor, t),
    );
  }
}
