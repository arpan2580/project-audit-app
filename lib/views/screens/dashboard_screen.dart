import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/dashboard_controller.dart';
import 'package:jnk_app/services/location_service.dart';
import 'package:jnk_app/utils/custom/faded_divider.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:jnk_app/views/screens/tab_screen.dart';
import 'package:jnk_app/views/widgets/auditor_info_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.find();

    final ImagePicker picker = ImagePicker();
    // final scrollController = ScrollController();
    return Obx(
      () => dashboardController.isLoading.value
          ? Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: const Center(child: CircularProgressIndicator.adaptive()),
            )
          : Scaffold(
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
                                    AppConstants.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    AppConstants.logoBlueColor.withValues(
                                      alpha: 0.6,
                                    ),
                                  ],
                                ),
                              ),
                              child: SafeArea(
                                left: false,
                                right: false,
                                bottom: false,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                        ? AppConstants
                                                              .accentColor
                                                        : BaseController
                                                                      .isPresent
                                                                      .value ==
                                                                  true &&
                                                              BaseController
                                                                      .isLunchBreak
                                                                      .value ==
                                                                  true
                                                        ? AppConstants
                                                              .primaryColor
                                                        : AppConstants
                                                              .secondaryColor,
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                          5.0,
                                                        ),
                                                    child:
                                                        BaseController
                                                                .user
                                                                .value!
                                                                .avatar ==
                                                            ''
                                                        ? CircleAvatar(
                                                            radius: 40,
                                                            backgroundImage:
                                                                AssetImage(
                                                                  AppConstants
                                                                      .profilePlaceholder,
                                                                ),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                          )
                                                        : CircleAvatar(
                                                            radius: 40,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                  BaseController
                                                                      .user
                                                                      .value!
                                                                      .avatar,
                                                                ),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              SizedBox(
                                                width:
                                                    BaseController.storeToken
                                                            .read(
                                                              "day_status",
                                                            ) ==
                                                        "completed"
                                                    ? 0
                                                    : 50,
                                                height:
                                                    BaseController.storeToken
                                                            .read(
                                                              "day_status",
                                                            ) ==
                                                        "completed"
                                                    ? 0
                                                    : 30,
                                                child: Obx(
                                                  () =>
                                                      BaseController
                                                                  .isPresent
                                                                  .value ==
                                                              true &&
                                                          BaseController
                                                                  .isLunchBreak
                                                                  .value ==
                                                              false
                                                      ? DashboardController
                                                                    .dashboard
                                                                    .value!
                                                                    .lunchBreakInfo!
                                                                    .breakDuration ==
                                                                null
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
                                                                    DialogHelper.showAlertDialog(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          "Start Lunch Break",
                                                                      content: Text(
                                                                        "Please click on Confirm, if you want to start lunch break",
                                                                      ),
                                                                      confirmText:
                                                                          "Confirm",
                                                                      onConfirm: () {
                                                                        dashboardController.lunchBreak(
                                                                          'start',
                                                                        );
                                                                        Get.back();
                                                                        // DialogHelper.showInfoToast(
                                                                        //   description:
                                                                        //       'Lunch Break Started',
                                                                        // );
                                                                      },
                                                                      cancelText:
                                                                          "Cancel",
                                                                    );
                                                                  }
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        0.0,
                                                                      ),
                                                                  backgroundColor:
                                                                      AppConstants
                                                                          .backgroundColor
                                                                          .withAlpha(
                                                                            200,
                                                                          ),
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
                                                            : ElevatedButton(
                                                                onPressed: () {
                                                                  BaseController
                                                                          .showOptions
                                                                          .value =
                                                                      false;

                                                                  DialogHelper.showAlertDialog(
                                                                    context:
                                                                        context,
                                                                    title:
                                                                        "Close Attendance",
                                                                    content: Text(
                                                                      "Please click on Confirm, if you want to close attendance",
                                                                    ),
                                                                    confirmText:
                                                                        "Confirm",
                                                                    onConfirm: () {
                                                                      BaseController
                                                                              .isPresent
                                                                              .value =
                                                                          false;
                                                                      BaseController
                                                                          .storeToken
                                                                          .write(
                                                                            "day_status",
                                                                            "completed",
                                                                          );
                                                                      Get.back();
                                                                      DialogHelper.showInfoToast(
                                                                        description:
                                                                            'Attendance Closed',
                                                                      );
                                                                    },
                                                                    cancelText:
                                                                        "Cancel",
                                                                  );
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        0.0,
                                                                      ),
                                                                  backgroundColor:
                                                                      AppConstants
                                                                          .primaryColor,
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
                                                              DialogHelper.showAlertDialog(
                                                                context:
                                                                    context,
                                                                title:
                                                                    "End Lunch Break",
                                                                content: Text(
                                                                  "Please click on Confirm, if you want to end lunch break",
                                                                ),
                                                                confirmText:
                                                                    "Confirm",
                                                                onConfirm: () {
                                                                  dashboardController
                                                                      .lunchBreak(
                                                                        'stop',
                                                                      );
                                                                  Get.back();
                                                                  // DialogHelper.showInfoToast(
                                                                  //   description:
                                                                  //       'Lunch Break Ended',
                                                                  // );
                                                                },
                                                                cancelText:
                                                                    "Cancel",
                                                              );
                                                            }
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  0.0,
                                                                ),
                                                            backgroundColor:
                                                                AppConstants
                                                                    .backgroundColor
                                                                    .withAlpha(
                                                                      200,
                                                                    ),
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
                                                              takePhoto(
                                                                dashboardController,
                                                                ImageSource
                                                                    .camera,
                                                                picker,
                                                                context,
                                                              );
                                                            }
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.all(
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
                                                MediaQuery.of(
                                                  context,
                                                ).size.width -
                                                120,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: AppConstants
                                                      .backgroundColor,
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
                                                      value: BaseController
                                                          .user
                                                          .value!
                                                          .empCode,
                                                      scroll: true,
                                                    ),
                                                    AuditorInfoWidget(
                                                      title: 'Emp Name',
                                                      value: BaseController
                                                          .user
                                                          .value!
                                                          .name,
                                                      scroll: true,
                                                    ),
                                                    AuditorInfoWidget(
                                                      title:
                                                          'Attendance Details',
                                                      value:
                                                          DashboardController
                                                                      .dashboard
                                                                      .value!
                                                                      .attendanceInfo !=
                                                                  null &&
                                                              DashboardController
                                                                      .dashboard
                                                                      .value!
                                                                      .attendanceInfo!
                                                                      .checkInTime !=
                                                                  null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd hh:mm:ss a',
                                                                )
                                                                .format(
                                                                  DashboardController
                                                                      .dashboard
                                                                      .value!
                                                                      .attendanceInfo!
                                                                      .checkInTime!,
                                                                )
                                                                .toString() // '03-07-2025 10:30:01',
                                                          : '----', // '03-07-2025 10:30:01',
                                                      scroll: true,
                                                    ),
                                                    AuditorInfoWidget(
                                                      title: 'Manager',
                                                      value: BaseController
                                                          .user
                                                          .value!
                                                          .manager!
                                                          .name,
                                                      scroll: true,
                                                    ),
                                                    AuditorInfoWidget(
                                                      title: 'Date Time',
                                                      value:
                                                          DateFormat(
                                                                'yyyy-MM-dd hh:mm:ss a',
                                                              )
                                                              .format(
                                                                DateTime.now(),
                                                              )
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
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            "Audit Dashboard",
                                            style: TextStyle(
                                              color:
                                                  AppConstants.backgroundColor,
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
            ),
    );
  }

  void takePhoto(
    DashboardController dashboardController,
    ImageSource source,
    picker,
    context,
  ) async {
    DialogHelper.showAlertDialog(
      context: context,
      title: "Capturing GPS",
      content: Image.asset(
        'assets/animations/gps_capture.gif',
        height: 120,
        width: 120,
        fit: BoxFit.scaleDown,
      ),
      confirmText: null,
      onConfirm: () {},
      cancelText: null,
    );
    LocationService.checkLocation();
    Future.delayed(const Duration(seconds: 3), () async {
      Get.back(closeOverlays: true); // Close the GPS dialog
      if (BaseController.gpsEnabled.value != false &&
          BaseController.locationPermission.value != false &&
          BaseController.locationMocked.value != true) {
        final pickedFile = await picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.front,
        );

        if (pickedFile != null) {
          File croppedImage = await BaseController.compressImage(
            File(pickedFile.path),
            10,
          );

          final path = croppedImage.path;
          BaseController.imageFile.value = File(path);
          String latitude = BaseController.currentLocation.value.latitude
              .toStringAsFixed(6);
          String longitude = BaseController.currentLocation.value.longitude
              .toStringAsFixed(6);
          DialogHelper.showAlertDialog(
            context: context,
            title: "Mark Attendance",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(
                  BaseController.imageFile.value,
                  height: 400,
                  width: 300,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 7.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppConstants.accentColor,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          "Lat: $latitude",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    Text("Long: $longitude", style: TextStyle(fontSize: 16.0)),
                  ],
                ),
                Text(
                  "Date: ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.now())}",
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            confirmText: "Confirm",
            onConfirm: () {
              Get.back();
              dashboardController.markAttendance(
                BaseController.imageFile.value,
                latitude,
                longitude,
              );
            },
            cancelText: "Cancel",
          );
          // print("Cropped File =========> ${BaseController.imageFile.value.path}");
          // Get the file size in bytes using length() (asynchronously)
          int sizeInBytes = await BaseController.imageFile.value.length();
          double sizeInKb = sizeInBytes / 1024;
          double sizeInMb = sizeInKb / 1024;
          print('File size in KB: ${sizeInKb.toStringAsFixed(2)} KB');
          print('File size in MB: ${sizeInMb.toStringAsFixed(2)} MB');
          // widget.controller.updateProfileImage(imageFile);
          // BaseController.showReload.value = false;
          // widget.controller.updateProfileImage(File(pickedFile.path));
        } else {
          DialogHelper.showInfoToast(
            description: 'No image clicked, please try again',
          );
        }
      }
    });
  }
}
