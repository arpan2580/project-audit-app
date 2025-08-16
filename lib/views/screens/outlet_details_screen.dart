import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/outlet_controller.dart';
import 'package:jnk_app/services/location_service.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class OutletDetailsScreen extends StatelessWidget {
  const OutletDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    // File? imageFile;
    Rx<File?> imageFile = Rx<File?>(null);
    // final outletController = Get.put(OutletController());

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
            Container(
              height: 650,
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
                  bottom: false,
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
                              "Outlet Id: JNK123456",
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
                          "Colins Variety Store PVT. LTD.",
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
                        Row(
                          children: [
                            Text(
                              "Last Audited On:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.accentColor,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              "08/08/2025",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppConstants.accentColor,
                              ),
                            ),
                            SizedBox(width: 25.0),
                            VerticalDivider(
                              thickness: 0.8,
                              color: AppConstants.backgroundColor,
                            ),
                            SizedBox(width: 25.0),
                            Text(
                              "Audit Count:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.accentColor,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              "3",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppConstants.accentColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25.0),
                        Obx(
                          () => Center(
                            child:
                                imageFile.value == null ||
                                    imageFile.value.toString() == ''
                                ? CircleAvatar(
                                    radius: 130,
                                    backgroundImage: AssetImage(
                                      'assets/images/shop-exterior.jpg',
                                    ),
                                    backgroundColor: Colors.transparent,
                                  )
                                : CircleAvatar(
                                    radius: 130,
                                    backgroundImage: FileImage(
                                      imageFile.value!,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Start time:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.accentColor,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  "12:35:01",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppConstants.accentColor,
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
                                    color: AppConstants.accentColor,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  "13:55:45",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppConstants.accentColor,
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
            // SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    LocationService.instance.checkLocation();
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

                    Future.delayed(const Duration(seconds: 3), () async {
                      Get.back(); // Close the GPS dialog
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );

                      if (pickedFile != null) {
                        CroppedFile? croppedImage = await ImageCropper()
                            .cropImage(
                              sourcePath: pickedFile.path,
                              compressFormat: ImageCompressFormat.jpg,
                              compressQuality: 30,
                              uiSettings: [
                                AndroidUiSettings(
                                  hideBottomControls: true,
                                  lockAspectRatio: true,
                                  initAspectRatio: CropAspectRatioPreset.square,
                                ),
                                IOSUiSettings(
                                  hidesNavigationBar: true,
                                  aspectRatioLockEnabled: true,
                                ),
                              ],
                            );

                        if (croppedImage != null) {
                          final path = croppedImage.path;
                          imageFile.value = File(path);

                          // print("Cropped File =========> ${OutletController.imageFile.value.path}");
                          // Get the file size in bytes using length() (asynchronously)
                          int sizeInBytes = await imageFile.value!.length();
                          double sizeInKb = sizeInBytes / 1024;
                          double sizeInMb = sizeInKb / 1024;
                          print(
                            'File size in KB: ${sizeInKb.toStringAsFixed(2)} KB',
                          );
                          print(
                            'File size in MB: ${sizeInMb.toStringAsFixed(2)} MB',
                          );
                          // widget.controller.updateProfileImage(imageFile);
                        }
                        // BaseController.showReload.value = false;
                        // widget.controller.updateProfileImage(File(pickedFile.path));
                      } else {
                        DialogHelper.showInfoToast(
                          description: 'No image clicked, please try again',
                        );
                      }
                    });
                  },
                  child: Text(
                    "Start Audit",
                    style: TextStyle(
                      color: AppConstants.backgroundColor,
                      fontSize: AppConstants.fontLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
