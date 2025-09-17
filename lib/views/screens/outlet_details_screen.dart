import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/outlet_controller.dart';
import 'package:jnk_app/models/bit_plan_model.dart';
import 'package:jnk_app/services/location_service.dart';
import 'package:jnk_app/utils/custom/faded_divider.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class OutletDetailsScreen extends StatelessWidget {
  final BitPlanModel outletDetails;
  const OutletDetailsScreen({super.key, required this.outletDetails});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    Rx<File?> imageFile = Rx<File?>(null);
    final OutletController outletController = Get.find();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("DATETIME - $today");
    Rx<String> startTime = ''.obs;
    Rx<String> latitude = ''.obs;
    Rx<String> longitude = ''.obs;
    // RxBool isAuditStarted = false.obs;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(title: const Text('Outlet Details'), centerTitle: true),
      body: GestureDetector(
        onTap: () {
          BaseController.showOptions.value = false;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
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
                          AppConstants.logoBlueColor.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      left: false,
                      right: false,
                      bottom: true,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/icons/store-icon.png',
                                    height: 45.0,
                                    color: AppConstants.backgroundColor,
                                  ),
                                  Text(
                                    "Outlet Id: ${outletDetails.olCode}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.backgroundColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "Outlet Name:",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppConstants.backgroundColor,
                                ),
                              ),
                              Text(
                                outletDetails.olName,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.backgroundColor,
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     Text(
                              //       "Address:",
                              //       style: TextStyle(
                              //         fontSize: 18,
                              //         fontWeight: FontWeight.bold,
                              //         // color: AppConstants.backgroundColor,
                              //       ),
                              //     ),
                              //     SizedBox(width: 8.0),
                              //     Text(
                              //       "Bhawanipore, Kolkata 700020, India",
                              //       style: TextStyle(
                              //         fontSize: 18,
                              //         color: AppConstants.backgroundColor.withAlpha(
                              //           240,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              SizedBox(height: 5.0),
                              Divider(
                                thickness: 0.3,
                                color: AppConstants.backgroundColor,
                              ),
                              SizedBox(height: 10.0),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Last Audited On:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                outletDetails.lastVisitDate !=
                                                        null
                                                    ? DateFormat(
                                                        'dd-MM-yyyy',
                                                      ).format(
                                                        DateTime.parse(
                                                          outletDetails
                                                              .lastVisitDate!,
                                                        ),
                                                      )
                                                    : "N/A",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: [
                                              Text(
                                                "Audit Count:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                outletDetails
                                                    .currentMonthVisitCount
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 25.0),
                                      Obx(
                                        () => Center(
                                          child:
                                              imageFile.value == null ||
                                                  imageFile.value.toString() ==
                                                      ''
                                              ? outletDetails.lastVisit !=
                                                            null &&
                                                        outletDetails
                                                                .lastVisit
                                                                ?.photo !=
                                                            null &&
                                                        outletDetails
                                                                .lastVisit
                                                                ?.photo !=
                                                            ''
                                                    ? CircleAvatar(
                                                        radius: 150,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        child: ClipOval(
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                outletDetails
                                                                    .lastVisit!
                                                                    .photo!,
                                                            fit: BoxFit.cover,
                                                            width:
                                                                300, // 2x radius
                                                            height: 300,
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => const Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => const Icon(
                                                                  Icons.error,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                    : CircleAvatar(
                                                        radius: 150,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        child: SvgPicture.asset(
                                                          'assets/icons/outlet-icon.svg',
                                                        ),
                                                      )
                                              : CircleAvatar(
                                                  radius: 150,
                                                  backgroundImage: FileImage(
                                                    imageFile.value!,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Start time:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                outletDetails.lastVisit !=
                                                            null &&
                                                        outletDetails
                                                                .lastVisit!
                                                                .startTime !=
                                                            null
                                                    ? DateFormat(
                                                        'hh:mm:ss a',
                                                      ).format(
                                                        DateTime.parse(
                                                          outletDetails
                                                                  .lastVisit!
                                                                  .startTime ??
                                                              '',
                                                        ),
                                                      )
                                                    : "N/A",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "End time:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                outletDetails.lastVisit !=
                                                            null &&
                                                        outletDetails
                                                                .lastVisit!
                                                                .endTime !=
                                                            null
                                                    ? DateFormat(
                                                        'hh:mm:ss a',
                                                      ).format(
                                                        DateTime.parse(
                                                          outletDetails
                                                                  .lastVisit!
                                                                  .endTime ??
                                                              '',
                                                        ),
                                                      )
                                                    : "N/A",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      //Todays audit
                                      SizedBox(height: 15.0),
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
                                              "Today's Audit Details",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18.0,
                                                color: AppConstants
                                                    .backgroundColor,
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
                                      SizedBox(height: 10.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Start time:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppConstants
                                                      .backgroundColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Obx(
                                                () =>
                                                    (BaseController
                                                                .startTime
                                                                .value !=
                                                            '' &&
                                                        BaseController
                                                            .startTime
                                                            .value
                                                            .isNotEmpty &&
                                                        outletDetails.id ==
                                                            BaseController
                                                                .currAuditOutletId
                                                                .value)
                                                    ? Text(
                                                        DateFormat(
                                                          'hh:mm:ss a',
                                                        ).format(
                                                          DateTime.parse(
                                                            BaseController
                                                                .startTime
                                                                .value,
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: AppConstants
                                                              .backgroundColor,
                                                        ),
                                                      )
                                                    : Text(
                                                        "-----",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: AppConstants
                                                              .backgroundColor,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "End time:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppConstants
                                                      .backgroundColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Obx(
                                                () =>
                                                    (BaseController
                                                                .endTime
                                                                .value !=
                                                            '' &&
                                                        BaseController
                                                            .endTime
                                                            .value
                                                            .isNotEmpty)
                                                    ? Text(
                                                        DateFormat(
                                                          'hh:mm:ss a',
                                                        ).format(
                                                          DateTime.parse(
                                                            outletDetails
                                                                    .lastVisit!
                                                                    .endTime ??
                                                                '',
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: AppConstants
                                                              .backgroundColor,
                                                        ),
                                                      )
                                                    : Text(
                                                        "-----",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: AppConstants
                                                              .backgroundColor,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: AppConstants.accentColor,
                                              ),
                                              SizedBox(width: 5.0),
                                              Text(
                                                "Location: ",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppConstants
                                                      .backgroundColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Obx(
                                            () =>
                                                (BaseController
                                                            .latitude
                                                            .value !=
                                                        '' &&
                                                    BaseController
                                                        .latitude
                                                        .value
                                                        .isNotEmpty &&
                                                    outletDetails.id ==
                                                        BaseController
                                                            .currAuditOutletId
                                                            .value)
                                                ? Text(
                                                    "Lat: ${BaseController.latitude.value}",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: AppConstants
                                                          .backgroundColor,
                                                    ),
                                                  )
                                                : Text(
                                                    "Lat: -----",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: AppConstants
                                                          .backgroundColor,
                                                    ),
                                                  ),
                                          ),
                                          // Text(
                                          //   "Lat: ${BaseController.currentLocation.value.latitude.toStringAsFixed(6)}",
                                          //   style: TextStyle(fontSize: 18.0),
                                          // ),
                                          Obx(
                                            () =>
                                                (BaseController
                                                            .longitude
                                                            .value !=
                                                        '' &&
                                                    BaseController
                                                        .longitude
                                                        .value
                                                        .isNotEmpty &&
                                                    outletDetails.id ==
                                                        BaseController
                                                            .currAuditOutletId
                                                            .value)
                                                ? Text(
                                                    "Long: ${BaseController.longitude.value}",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: AppConstants
                                                          .backgroundColor,
                                                    ),
                                                  )
                                                : Text(
                                                    "Long: -----",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: AppConstants
                                                          .backgroundColor,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Start audit button
                                  Column(
                                    children: [
                                      SizedBox(height: 20.0),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 10.0,
                                          bottom: 20.0,
                                        ),
                                        child: SizedBox(
                                          width:
                                              // outletDetails.lastVisitDate !=
                                              //         null &&
                                              //     outletDetails
                                              //             .inBitVisitStatus !=
                                              //         'completed'
                                              // && outletDetails.lastVisitDate !=
                                              // today
                                              // ?
                                              double.infinity,
                                          // : 0,
                                          height:
                                              // outletDetails.lastVisitDate !=
                                              //         null &&
                                              //     outletDetails
                                              //             .inBitVisitStatus !=
                                              //         'completed'
                                              // && outletDetails.lastVisitDate !=
                                              // today
                                              // ?
                                              55,
                                          // : 0,
                                          child: Obx(
                                            () =>
                                                (BaseController
                                                        .isAuditStarted
                                                        .value &&
                                                    outletDetails.id ==
                                                        BaseController
                                                            .currAuditOutletId
                                                            .value)
                                                ? ElevatedButton(
                                                    onPressed: () {
                                                      if (BaseController
                                                              .isPresent
                                                              .value ==
                                                          false) {
                                                        DialogHelper.showInfoToast(
                                                          description:
                                                              'Please mark your attendance first.',
                                                        );
                                                      } else if (BaseController
                                                              .isLunchBreak
                                                              .value ==
                                                          true) {
                                                        DialogHelper.showInfoToast(
                                                          description:
                                                              'Audit cannot be closed while you are in a lunch break.',
                                                        );
                                                      } else {
                                                        DialogHelper.showAlertDialog(
                                                          context: context,
                                                          title:
                                                              "Capturing GPS",
                                                          content: Image.asset(
                                                            'assets/animations/gps_capture.gif',
                                                            height: 120,
                                                            width: 120,
                                                            fit: BoxFit
                                                                .scaleDown,
                                                          ),
                                                          confirmText: null,
                                                          onConfirm: () {},
                                                          cancelText: null,
                                                        );
                                                        LocationService.checkLocation();
                                                        Future.delayed(
                                                          const Duration(
                                                            seconds: 3,
                                                          ),
                                                          () async {
                                                            Get.back(
                                                              closeOverlays:
                                                                  true,
                                                            ); // Close the GPS dialog

                                                            if (BaseController
                                                                        .gpsEnabled
                                                                        .value !=
                                                                    false &&
                                                                BaseController
                                                                        .locationPermission
                                                                        .value !=
                                                                    false &&
                                                                BaseController
                                                                        .locationMocked
                                                                        .value !=
                                                                    true) {
                                                              // BaseController
                                                              //         .isAuditStarted
                                                              //         .value =
                                                              //     false;
                                                              // endTime.value =
                                                              //     DateFormat(
                                                              //       'hh:mm:ss a',
                                                              //     ).format(
                                                              //       DateTime.now(),
                                                              //     );
                                                              final String?
                                                              storedAudit =
                                                                  BaseController
                                                                      .storeToken
                                                                      .read(
                                                                        'currentAudit',
                                                                      );

                                                              if (storedAudit !=
                                                                      null &&
                                                                  storedAudit
                                                                      .isNotEmpty) {
                                                                // Decode JSON to a Map
                                                                final Map<
                                                                  String,
                                                                  dynamic
                                                                >
                                                                auditData = json
                                                                    .decode(
                                                                      storedAudit,
                                                                    );
                                                                outletController.endAudit(
                                                                  BaseController
                                                                      .currentLocation
                                                                      .value
                                                                      .latitude
                                                                      .toStringAsFixed(
                                                                        6,
                                                                      ),
                                                                  BaseController
                                                                      .currentLocation
                                                                      .value
                                                                      .longitude
                                                                      .toStringAsFixed(
                                                                        6,
                                                                      ),
                                                                  auditData['visitId'],
                                                                );
                                                              }
                                                            }
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      "End Audit",
                                                      style: TextStyle(
                                                        color: AppConstants
                                                            .backgroundColor,
                                                        fontSize: AppConstants
                                                            .fontLarge,
                                                      ),
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      if (BaseController
                                                              .isPresent
                                                              .value ==
                                                          false) {
                                                        DialogHelper.showInfoToast(
                                                          description:
                                                              'Please mark your attendance first.',
                                                        );
                                                      } else if (BaseController
                                                              .isLunchBreak
                                                              .value ==
                                                          true) {
                                                        DialogHelper.showInfoToast(
                                                          description:
                                                              'Audit cannot be started while you are in a lunch break.',
                                                        );
                                                      } else if (BaseController
                                                              .isAuditStarted
                                                              .value ==
                                                          true) {
                                                        DialogHelper.showInfoToast(
                                                          description:
                                                              'Audit cannot be started while another audit is ongoing.',
                                                        );
                                                      } else {
                                                        DialogHelper.showAlertDialog(
                                                          context: context,
                                                          title:
                                                              "Capturing GPS",
                                                          content: Image.asset(
                                                            'assets/animations/gps_capture.gif',
                                                            height: 120,
                                                            width: 120,
                                                            fit: BoxFit
                                                                .scaleDown,
                                                          ),
                                                          confirmText: null,
                                                          onConfirm: () {},
                                                          cancelText: null,
                                                        );
                                                        LocationService.checkLocation();
                                                        Future.delayed(
                                                          const Duration(
                                                            seconds: 3,
                                                          ),
                                                          () async {
                                                            Get.back(
                                                              closeOverlays:
                                                                  true,
                                                            ); // Close the GPS dialog
                                                            // print("GPS Enabled: ${BaseController.gpsEnabled.value}");
                                                            // print(
                                                            //   "LOCATION Permission: ${BaseController.locationPermission.value}",
                                                            // );
                                                            // print(
                                                            //   "MOCKED Location: ${BaseController.locationMocked.value}",
                                                            // );
                                                            if (BaseController
                                                                        .gpsEnabled
                                                                        .value !=
                                                                    false &&
                                                                BaseController
                                                                        .locationPermission
                                                                        .value !=
                                                                    false &&
                                                                BaseController
                                                                        .locationMocked
                                                                        .value !=
                                                                    true) {
                                                              final pickedFile =
                                                                  await picker.pickImage(
                                                                    source: ImageSource
                                                                        .camera,
                                                                  );

                                                              if (pickedFile !=
                                                                  null) {
                                                                startTime
                                                                        .value =
                                                                    DateFormat(
                                                                      'hh:mm:ss a',
                                                                    ).format(
                                                                      DateTime.now(),
                                                                    );
                                                                latitude.value =
                                                                    BaseController
                                                                        .currentLocation
                                                                        .value
                                                                        .latitude
                                                                        .toStringAsFixed(
                                                                          6,
                                                                        );
                                                                longitude
                                                                    .value = BaseController
                                                                    .currentLocation
                                                                    .value
                                                                    .longitude
                                                                    .toStringAsFixed(
                                                                      6,
                                                                    );
                                                                File
                                                                croppedImage =
                                                                    await BaseController.compressImage(
                                                                      File(
                                                                        pickedFile
                                                                            .path,
                                                                      ),
                                                                      10,
                                                                    );

                                                                final path =
                                                                    croppedImage
                                                                        .path;
                                                                imageFile
                                                                        .value =
                                                                    File(path);

                                                                // print("Cropped File =========> ${OutletController.imageFile.value.path}");
                                                                // Get the file size in bytes using length() (asynchronously)
                                                                int
                                                                sizeInBytes =
                                                                    await imageFile
                                                                        .value!
                                                                        .length();
                                                                double
                                                                sizeInKb =
                                                                    sizeInBytes /
                                                                    1024;
                                                                double
                                                                sizeInMb =
                                                                    sizeInKb /
                                                                    1024;
                                                                print(
                                                                  'File size in KB: ${sizeInKb.toStringAsFixed(2)} KB',
                                                                );
                                                                print(
                                                                  'File size in MB: ${sizeInMb.toStringAsFixed(2)} MB',
                                                                );
                                                                // widget.controller.updateProfileImage(imageFile);
                                                                // BaseController.showReload.value = false;
                                                                // widget.controller.updateProfileImage(File(pickedFile.path));
                                                                outletController
                                                                    .startAudit(
                                                                      imageFile
                                                                          .value!,
                                                                      latitude
                                                                          .value,
                                                                      longitude
                                                                          .value,
                                                                      outletDetails
                                                                          .id,
                                                                    );
                                                                // isAuditStarted
                                                                // .value =
                                                                // true;
                                                              } else {
                                                                DialogHelper.showInfoToast(
                                                                  description:
                                                                      'No image clicked, please try again',
                                                                );
                                                              }
                                                            }
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      "Start Audit",
                                                      style: TextStyle(
                                                        color: AppConstants
                                                            .backgroundColor,
                                                        fontSize: AppConstants
                                                            .fontLarge,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
