import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/views/screens/agents_chat_screen.dart';
import 'package:jnk_app/views/screens/attendance_screen.dart';
import 'package:jnk_app/views/screens/bit_plan_screen.dart';
import 'package:jnk_app/views/screens/dashboard_screen.dart';
import 'package:jnk_app/views/screens/individual_chat_screen.dart';
import 'package:jnk_app/views/screens/profile_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  final PageController pageController = PageController(initialPage: 0);
  late int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const <Widget>[
                DashboardScreen(),
                BitPlanScreen(),
                AttendanceScreen(),
                ProfileScreen(),
              ],
            ),

            // Additional FAB Options Positioned Above FAB
            Positioned(
              // bottom: MediaQuery.of(context).size.height >= 900
              //     ? 125
              //     : MediaQuery.of(context).size.height >= 850
              //     ? 95
              //     : 90,
              bottom: 50, // Adjusted for better visibility
              left: MediaQuery.of(context).size.width / 2 - 70, // Centered
              child: Obx(
                () => AnimatedSlide(
                  offset: BaseController.showOptions.value
                      ? Offset(0, 0)
                      : Offset(0, 0.7),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: BaseController.showOptions.value ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      // decoration: BoxDecoration(
                      //   border: Border.all(
                      //     color: AppConstants.primaryColor,
                      //     width: 1.0,
                      //   ),
                      //   borderRadius: const BorderRadius.all(Radius.circular(15)),
                      //   gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       AppConstants.backgroundColor.withValues(alpha: 0.5),
                      //       AppConstants.backgroundColor.withValues(alpha: 0.7),
                      //     ],
                      //   ),
                      // ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: 'individual_chat',
                            onPressed: () {
                              BaseController.showOptions.value =
                                  !BaseController.showOptions.value;
                              Get.to(
                                () => IndividualChatScreen(
                                  name: 'Rahul Sharma',
                                  profilePicUrl: 'profile_pic_url',
                                ),
                              );
                            },
                            tooltip: 'Chat with Admin',
                            backgroundColor: AppConstants.logoBlueColor,
                            shape: CircleBorder(),
                            child: SvgPicture.asset(
                              'assets/icons/Admin-chat.svg',
                              height: 23.0,
                            ),
                          ),
                          const SizedBox(width: 7.0),
                          FloatingActionButton(
                            heroTag: 'agent_chat',
                            onPressed: () {
                              BaseController.showOptions.value =
                                  !BaseController.showOptions.value;
                              Get.to(() => AgentsChatScreen());
                            },
                            tooltip: 'Chat with Agents',
                            backgroundColor: AppConstants.logoBlueColor,
                            shape: CircleBorder(),
                            child: SvgPicture.asset(
                              'assets/icons/Agent-chat.svg',
                              height: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Only FAB here (no Column)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BaseController.showOptions.value = !BaseController.showOptions.value;
        },
        backgroundColor: AppConstants.logoBlueColor,
        shape: const CircleBorder(),
        child: SvgPicture.asset('assets/icons/Chat-icon.svg', height: 28.0),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60.0,
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            color: AppConstants.logoBlueColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Home.svg',
                  height: 28,
                  width: 28.0,
                ),
                onPressed: () {
                  BaseController.showOptions.value = false;
                  selectedIndex = 0;
                  pageController.jumpToPage(0);
                },
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/BitPlan.svg',
                  height: 28,
                  width: 28.0,
                ),
                onPressed: () {
                  BaseController.showOptions.value = false;
                  selectedIndex = 1;
                  pageController.jumpToPage(1);
                },
              ),
              const SizedBox(width: 40), // space for FAB
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Attendance.svg',
                  height: 28,
                  width: 28.0,
                ),
                onPressed: () {
                  BaseController.showOptions.value = false;
                  selectedIndex = 2;
                  pageController.jumpToPage(2);
                },
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Profile.svg',
                  height: 28,
                  width: 28.0,
                ),
                onPressed: () {
                  BaseController.showOptions.value = false;
                  selectedIndex = 3;
                  pageController.jumpToPage(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
