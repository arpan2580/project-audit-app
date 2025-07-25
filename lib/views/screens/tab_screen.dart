import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/views/screens/bar_chart_screen.dart';

class TabScreen extends HookWidget {
  final List<String> labels;
  final Color tabBgColor;
  final Color tabFgColor;
  final Color tabActiveBgColor;
  final Color tabActiveFgColor;

  const TabScreen({
    super.key,
    required this.labels,
    required this.tabBgColor,
    required this.tabFgColor,
    required this.tabActiveBgColor,
    required this.tabActiveFgColor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTabController(initialLength: 2);
    return Column(
      children: [
        MyTabBar(
          controller: controller,
          labels: labels,
          backgroundColor: tabBgColor,
          foregroundColor: tabFgColor,
          activeBackgroundColor: tabActiveBgColor,
          activeForegroundColor: tabActiveFgColor,
          fontSize: 18,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: [
              BarChartScreen(
                type: 'daily',
                data: [
                  DataModel(key: 'planned', value: 20),
                  DataModel(key: 'achieved', value: 12),
                ],
              ),
              BarChartScreen(
                type: 'monthly',
                data: [
                  DataModel(key: 'planned', value: 1200),
                  DataModel(key: 'achieved', value: 700),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyTabBar extends HookWidget {
  final TabController controller;
  final List<String> labels;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color activeBackgroundColor;
  final Color activeForegroundColor;
  final double fontSize;

  const MyTabBar({
    super.key,
    required this.controller,
    required this.labels,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.activeBackgroundColor,
    required this.activeForegroundColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final ids = useState([1, 0]);
    return AspectRatio(
      aspectRatio: 130 / 18,
      child: ColoredBox(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: ids.value.map((id) {
            final active = controller.index == id;
            return MyTab(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              activeBackgroundColor: activeBackgroundColor,
              activeForegroundColor: activeForegroundColor,
              fontSize: fontSize,
              active: active,
              reversed: id == 1,
              label: labels[id],
              onTap: () {
                controller.animateTo(id);
                ids.value = ids.value.reversed.toList();

                BaseController.showOptions.value = false;
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class MyTab extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color activeBackgroundColor;
  final Color activeForegroundColor;
  final double fontSize;
  final bool active;
  final bool reversed;
  final String label;
  final VoidCallback onTap;

  Color get bgColor => active ? activeBackgroundColor : backgroundColor;
  Color get fgColor => active ? activeForegroundColor : foregroundColor;

  const MyTab({
    super.key,
    required this.active,
    this.reversed = false,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.activeBackgroundColor,
    required this.activeForegroundColor,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: reversed
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: CustomPaint(painter: TabPainter(color: bgColor)),
                  )
                : CustomPaint(painter: TabPainter(color: bgColor)),
          ),
        ),
        Align(
          alignment: reversed ? Alignment.centerRight : Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: .5,
            heightFactor: 1,
            child: TextButton(
              onPressed: active ? null : onTap,
              child: Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: active ? fontSize : fontSize - 2,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TabPainter extends CustomPainter {
  final Color color;

  TabPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, .5 * size.height);
    path.quadraticBezierTo(0, 0, .1 * size.width, 0);
    path.lineTo(.48 * size.width, 0);
    path.quadraticBezierTo(
      .512 * size.width,
      0,
      .52 * size.width,
      .1 * size.height,
    );
    path.lineTo(.57 * size.width, .83 * size.height);
    path.quadraticBezierTo(
      .58 * size.width,
      .9 * size.height,
      .59 * size.width,
      .9 * size.height,
    );
    path.lineTo(size.width, .9 * size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
