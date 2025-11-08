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
import 'package:jnk_app/views/screens/image_view_screen.dart';

class OutletDetailsScreen extends StatelessWidget {
  final BitPlanModel outletDetails;
  const OutletDetailsScreen({super.key, required this.outletDetails});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    Rx<File?> imageFile = Rx<File?>(null);
    final OutletController outletController = Get.find();
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
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            SizedBox(height: 5.0),
                            Divider(
                              thickness: 0.3,
                              color: AppConstants.backgroundColor,
                            ),
                            SizedBox(height: 10.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Column(
                                    children: [
                                      // Obx(
                                      //   () =>
                                      Center(
                                        child:
                                            imageFile.value == null ||
                                                imageFile.value.toString() == ''
                                            ? outletDetails.myVisit != null &&
                                                      outletDetails
                                                              .myVisit
                                                              ?.photo !=
                                                          null &&
                                                      outletDetails
                                                              .myVisit
                                                              ?.photo !=
                                                          ''
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        Get.to(
                                                          ImageViewScreen(
                                                            imageUrl:
                                                                outletDetails
                                                                    .myVisit!
                                                                    .photo!,
                                                            isLocal: false,
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 350,
                                                        width: Get.width,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                        ),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              outletDetails
                                                                  .myVisit!
                                                                  .photo!,
                                                          fit: BoxFit.cover,
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
                                                  : outletDetails.lastVisit !=
                                                            null &&
                                                        outletDetails
                                                                .lastVisit
                                                                ?.photo !=
                                                            null &&
                                                        outletDetails
                                                                .lastVisit
                                                                ?.photo !=
                                                            ''
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        Get.to(
                                                          ImageViewScreen(
                                                            imageUrl:
                                                                outletDetails
                                                                    .lastVisit!
                                                                    .photo!,
                                                            isLocal: false,
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 350,
                                                        width: Get.width,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                        ),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              outletDetails
                                                                  .lastVisit!
                                                                  .photo!,
                                                          fit: BoxFit.cover,
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
                                                      // CircleAvatar(
                                                      //   radius: 150,
                                                      //   backgroundColor:
                                                      //       Colors.transparent,
                                                      //   child: ClipOval(
                                                      //     child: CachedNetworkImage(
                                                      //       imageUrl:
                                                      //           outletDetails
                                                      //               .lastVisit!
                                                      //               .photo!,
                                                      //       fit: BoxFit.cover,
                                                      //       width:
                                                      //           300, // 2x radius
                                                      //       // height: 300,
                                                      //       placeholder:
                                                      //           (
                                                      //             context,
                                                      //             url,
                                                      //           ) => const Center(
                                                      //             child:
                                                      //                 CircularProgressIndicator(),
                                                      //           ),
                                                      //       errorWidget:
                                                      //           (
                                                      //             context,
                                                      //             url,
                                                      //             error,
                                                      //           ) => const Icon(
                                                      //             Icons.error,
                                                      //           ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 150,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child: SvgPicture.asset(
                                                        'assets/icons/outlet-icon.svg',
                                                      ),
                                                    )
                                            : GestureDetector(
                                                onTap: () {
                                                  Get.to(
                                                    ImageViewScreen(
                                                      imageUrl:
                                                          imageFile.value!.path,
                                                      isLocal: true,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  height: 350,
                                                  width: Get.width,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    image: DecorationImage(
                                                      image: FileImage(
                                                        imageFile.value!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                //  CircleAvatar(
                                                //   radius: 0,
                                                //   backgroundImage: FileImage(
                                                //     imageFile.value!,
                                                //   ),
                                                // ),
                                              ),
                                      ),
                                      // ),
                                      SizedBox(height: 20.0),
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
                                              "Audit Details",
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Auditor:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              BaseController
                                                              .currAuditOutletId
                                                              .value ==
                                                          outletDetails.id &&
                                                      BaseController
                                                          .isAuditStarted
                                                          .value
                                                  ? Text(
                                                      BaseController
                                                          .auditorName
                                                          .value,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: AppConstants
                                                            .accentColor,
                                                      ),
                                                    )
                                                  : Text(
                                                      outletDetails.myVisit !=
                                                              null
                                                          ? outletDetails
                                                                    .myVisit
                                                                    ?.userName ??
                                                                "N/A"
                                                          : outletDetails
                                                                    .lastVisitDate !=
                                                                null
                                                          ? outletDetails
                                                                    .lastVisit
                                                                    ?.userName ??
                                                                "N/A"
                                                          : "N/A",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: AppConstants
                                                            .accentColor,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          SizedBox(height: 5.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Audit Date:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              BaseController
                                                              .currAuditOutletId
                                                              .value ==
                                                          outletDetails.id &&
                                                      BaseController
                                                          .isAuditStarted
                                                          .value
                                                  ? Text(
                                                      DateFormat(
                                                        'dd-MM-yyyy',
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
                                                            .accentColor,
                                                      ),
                                                    )
                                                  : Text(
                                                      // outletDetails.lastVisitDate != null
                                                      //     ? DateFormat(
                                                      //         'dd-MM-yyyy',
                                                      //       ).format(
                                                      //         DateTime.parse(
                                                      //           outletDetails
                                                      //               .lastVisitDate!,
                                                      //         ),
                                                      //       )
                                                      //     : "N/A",
                                                      outletDetails.myVisit !=
                                                              null
                                                          ? DateFormat(
                                                              'dd-MM-yyyy',
                                                            ).format(
                                                              DateTime.parse(
                                                                outletDetails
                                                                    .myVisit!
                                                                    .date,
                                                              ),
                                                            )
                                                          : outletDetails
                                                                    .lastVisitDate !=
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
                                                        color: AppConstants
                                                            .accentColor,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          SizedBox(height: 5.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Audit Time:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              BaseController
                                                              .currAuditOutletId
                                                              .value ==
                                                          outletDetails.id &&
                                                      BaseController
                                                          .isAuditStarted
                                                          .value
                                                  ? Text(
                                                      "${DateFormat('hh:mm:ss a').format(DateTime.parse(BaseController.startTime.value))} - N/A",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: AppConstants
                                                            .accentColor,
                                                      ),
                                                    )
                                                  : Text(
                                                      outletDetails.myVisit !=
                                                              null
                                                          ? "${DateFormat('hh:mm:ss a').format(DateTime.parse(outletDetails.myVisit!.startTime ?? ''))} - N/A"
                                                          : outletDetails
                                                                        .lastVisit !=
                                                                    null &&
                                                                outletDetails
                                                                        .lastVisit!
                                                                        .startTime !=
                                                                    null
                                                          ? "${DateFormat('hh:mm:ss a').format(DateTime.parse(outletDetails.lastVisit!.startTime ?? ''))} - ${outletDetails.lastVisit!.endTime != null ? DateFormat('hh:mm:ss a').format(DateTime.parse(outletDetails.lastVisit!.endTime ?? '')) : 'N/A'}"
                                                          : "N/A",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: AppConstants
                                                            .accentColor,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          SizedBox(height: 5.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Location:",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.accentColor,
                                                ),
                                              ),
                                              SizedBox(width: 3.0),
                                              BaseController
                                                              .currAuditOutletId
                                                              .value ==
                                                          outletDetails.id &&
                                                      BaseController
                                                          .isAuditStarted
                                                          .value
                                                  ? Text(
                                                      "${BaseController.latitude.value}, ${BaseController.longitude.value}",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: AppConstants
                                                            .accentColor,
                                                      ),
                                                    )
                                                  : Text(
                                                      outletDetails.myVisit !=
                                                              null
                                                          ? "${outletDetails.myVisit?.startLatitude.toString()}, ${outletDetails.myVisit?.startLongitude.toString()}"
                                                          : outletDetails
                                                                    .lastVisitDate !=
                                                                null
                                                          ? "${outletDetails.lastVisit?.lat.toString()}, ${outletDetails.lastVisit?.long.toString()}"
                                                          : "N/A",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: AppConstants
                                                            .accentColor,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                                      Future.delayed(
                                                        const Duration(
                                                          seconds: 3,
                                                        ),
                                                        () async {
                                                          Get.back(
                                                            closeOverlays: true,
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
                                                            final Visit?
                                                            storedAudit =
                                                                BaseController
                                                                    .storeToken
                                                                    .read(
                                                                      'currentAudit',
                                                                    );

                                                            if (storedAudit !=
                                                                null) {
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
                                                                storedAudit.id,
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
                                                            'Audit cannot be started while another audit is ongoing on ${BaseController.currAuditOutletName.value}.',
                                                      );
                                                    } else {
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
                                                      Future.delayed(
                                                        const Duration(
                                                          seconds: 3,
                                                        ),
                                                        () async {
                                                          Get.back(
                                                            closeOverlays: true,
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
                                                                  source:
                                                                      ImageSource
                                                                          .camera,
                                                                );

                                                            if (pickedFile !=
                                                                null) {
                                                              startTime.value =
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
                                                              longitude.value =
                                                                  BaseController
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
                                                                    40,
                                                                  );

                                                              final path =
                                                                  croppedImage
                                                                      .path;
                                                              imageFile.value =
                                                                  File(path);

                                                              // print("Cropped File =========> ${OutletController.imageFile.value.path}");
                                                              // Get the file size in bytes using length() (asynchronously)
                                                              int sizeInBytes =
                                                                  await imageFile
                                                                      .value!
                                                                      .length();
                                                              double sizeInKb =
                                                                  sizeInBytes /
                                                                  1024;
                                                              double sizeInMb =
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
        ),
      ),
    );
  }
}
