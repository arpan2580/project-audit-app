import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/views/screens/bottom_navigation_screen.dart';
import 'package:jnk_app/views/screens/login_screen.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  GetStorage storage = GetStorage();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      print(storage.read('token'));
      print(storage.read('refreshToken'));
      if (mounted) {
        if ((storage.read('token') != null || storage.read('token') != '') &&
            (storage.read('refreshToken') != null ||
                storage.read('refreshToken') != '')) {
          Navigator.of(
            context,
          ).pushReplacement(createRoute(BottomNavigationScreen()));
        } else {
          Navigator.of(context).pushReplacement(createRoute(LoginScreen()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          "assets/animations/logo_animation_loop1.gif",
          fit: BoxFit.fill,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

Route createRoute(Widget screenName) {
  var animationBegin = const Offset(
    0.0,
    -1.0,
  ); // Default animation for LoginScreen
  Widget page = screenName;

  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = animationBegin;
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
