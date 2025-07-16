import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/utils/custom/faded_divider.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/tab_screen.dart';
import 'package:jnk_app/views/widgets/auditor_info_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final scrollController = ScrollController();
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: GestureDetector(
        onTap: () {
          // Hide options when tapped outside
          BaseController.showOptions.value = false;
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 370,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppConstants.dashboardCardBg),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppConstants.primaryColor.withValues(alpha: 0.5),
                            AppConstants.logoBlueColor.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        left: false,
                        right: false,
                        bottom: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // SizedBox(height: 15.0),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 0,
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 7.0),
                                      Obx(
                                        () => DottedBorder(
                                          options: CircularDottedBorderOptions(
                                            // color: AppConstants.logoBlueColor,
                                            color:
                                                BaseController
                                                            .isPresent
                                                            .value ==
                                                        true &&
                                                    BaseController
                                                            .isLunchBreak
                                                            .value ==
                                                        false
                                                ? AppConstants.accentColor
                                                : BaseController
                                                              .isPresent
                                                              .value ==
                                                          true &&
                                                      BaseController
                                                              .isLunchBreak
                                                              .value ==
                                                          true
                                                ? AppConstants.primaryColor
                                                : AppConstants.secondaryColor,
                                            // color: AppConstants.backgroundColor,
                                            strokeWidth: 2.5,
                                            dashPattern: const [
                                              7,
                                              5,
                                              7,
                                              5,
                                              7,
                                              5,
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: CircleAvatar(
                                              radius: 40,
                                              backgroundImage: AssetImage(
                                                AppConstants.profilePlaceholder,
                                              ),
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      SizedBox(
                                        width: 50,
                                        height: 30,
                                        child: Obx(
                                          () =>
                                              BaseController.isPresent.value ==
                                                      true &&
                                                  BaseController
                                                          .isLunchBreak
                                                          .value ==
                                                      false
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    BaseController
                                                            .showOptions
                                                            .value =
                                                        false;
                                                    if (BaseController
                                                            .isLunchBreak
                                                            .value ==
                                                        false) {
                                                      BaseController
                                                              .isLunchBreak
                                                              .value =
                                                          true;
                                                      DialogHelper.showInfoToast(
                                                        description:
                                                            'Lunch Break Started',
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.all(
                                                      0.0,
                                                    ),
                                                    backgroundColor:
                                                        AppConstants
                                                            .backgroundColor
                                                            .withAlpha(200),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/icons/lunch-time.png',
                                                    height: 20,
                                                  ),
                                                )
                                              : BaseController
                                                            .isPresent
                                                            .value ==
                                                        true &&
                                                    BaseController
                                                            .isLunchBreak
                                                            .value ==
                                                        true
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    BaseController
                                                            .showOptions
                                                            .value =
                                                        false;
                                                    if (BaseController
                                                            .isLunchBreak
                                                            .value ==
                                                        true) {
                                                      BaseController
                                                              .isLunchBreak
                                                              .value =
                                                          false;
                                                      DialogHelper.showInfoToast(
                                                        description:
                                                            'Lunch Break Ended',
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.all(
                                                      0.0,
                                                    ),
                                                    backgroundColor:
                                                        AppConstants
                                                            .backgroundColor
                                                            .withAlpha(200),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/icons/break-over.png',
                                                    height: 20,
                                                    color: AppConstants
                                                        .primaryColor,
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    BaseController
                                                            .showOptions
                                                            .value =
                                                        false;
                                                    if (BaseController
                                                            .isPresent
                                                            .value ==
                                                        false) {
                                                      BaseController
                                                              .isPresent
                                                              .value =
                                                          true;
                                                      DialogHelper.showInfoToast(
                                                        description:
                                                            'Attendance Marked',
                                                      );
                                                    } else {
                                                      BaseController
                                                              .isPresent
                                                              .value =
                                                          false;
                                                      DialogHelper.showInfoToast(
                                                        description:
                                                            'Attendance Closed',
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.all(
                                                      0.0,
                                                    ),
                                                    backgroundColor:
                                                        AppConstants
                                                            .accentColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/icons/attendance-icon.png',
                                                    height: 20,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12.0),
                                  Container(
                                    height: 150,
                                    width:
                                        MediaQuery.of(context).size.width - 120,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: AppConstants.backgroundColor,
                                          width: 0.3,
                                        ),
                                      ),
                                      // borderRadius: const BorderRadius.all(
                                      //   Radius.circular(20),
                                      // ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                        right: 10.0,
                                      ),
                                      child: Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.all(0.0),
                                          // crossAxisAlignment:
                                          //     CrossAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AuditorInfoWidget(
                                              title: 'Emp ID',
                                              value: 'JNK12345',
                                              scroll: true,
                                            ),
                                            AuditorInfoWidget(
                                              title: 'Emp Name',
                                              value: 'Arpan Das',
                                              scroll: true,
                                            ),
                                            AuditorInfoWidget(
                                              title: 'Attendance Details',
                                              value:
                                                  DateFormat(
                                                        'yyyy-MM-dd hh:mm:ss a',
                                                      )
                                                      .format(DateTime.now())
                                                      .toString(), // '03-07-2025 10:30:01',
                                              scroll: true,
                                            ),
                                            AuditorInfoWidget(
                                              title: 'Manager',
                                              value: 'Rahul Sharma',
                                              scroll: true,
                                            ),
                                            AuditorInfoWidget(
                                              title: 'Date Time',
                                              value:
                                                  DateFormat(
                                                        'yyyy-MM-dd hh:mm:ss a',
                                                      )
                                                      .format(DateTime.now())
                                                      .toString(),
                                              scroll: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FadedDivider(
                                    color: AppConstants.primaryColor,
                                    height: 3.0,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "Audit Dashboard",
                                    style: TextStyle(
                                      color: AppConstants.backgroundColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FadedDivider(
                                    color: AppConstants.primaryColor,
                                    height: 3.0,
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 35.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 320,
                    left: 0,
                    right: 0,
                    child: TabScreen(
                      labels: [
                        (DateFormat.yMMMd().format(DateTime.now())),
                        "${DateFormat.MMMM().format(DateTime.now())} - ${DateFormat.y().format(DateTime.now())}",
                      ],
                      tabBgColor: AppConstants.primaryColor,
                      tabFgColor: Colors.black,
                      tabActiveBgColor: AppConstants.logoBlueColor,
                      tabActiveFgColor: AppConstants.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
