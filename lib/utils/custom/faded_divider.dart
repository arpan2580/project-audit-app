import 'package:flutter/material.dart';

class FadedDivider extends StatelessWidget {
  final Color color;
  final double height;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const FadedDivider({
    super.key,
    required this.color,
    required this.height,
    required this.begin,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Defines the start and end points of the gradient
          begin: begin,
          end: end,

          colors: [
            color.withValues(alpha: 0.0),
            color, // Fully transparent
          ],

          // Defines the distribution of the colors.
          // [0.0, 1.0] creates a smooth fade across the entire width.
          // You can adjust this for different effects, e.g., [0.2, 1.0]
          // would make the first 20% of the line completely transparent.
          stops: const [0.20, 1.0],
        ),
      ),
    );
  }
}
