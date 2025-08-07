import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/utils/custom/faded_divider.dart';
import 'package:jnk_app/views/dialogs/custom_about_dialog.dart';
import 'package:jnk_app/views/dialogs/custom_privacy_dialog.dart';
import 'package:jnk_app/views/screens/change_pass_screen.dart';
import 'package:jnk_app/views/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: GestureDetector(
        onTap: () {
          BaseController.showOptions.value = false;
        },
        child: Column(
          children: [
            Container(
              height: 440,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            DottedBorder(
                              options: CircularDottedBorderOptions(
                                color: AppConstants.accentColor,
                                strokeWidth: 2.5,
                                dashPattern: const [7, 5, 7, 5, 7, 5],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child:
                                    imageFile == null ||
                                        imageFile.toString() == ''
                                    ? CircleAvatar(
                                        radius: 80,
                                        backgroundImage: AssetImage(
                                          AppConstants.profilePlaceholder,
                                        ),
                                        backgroundColor: Colors.transparent,
                                      )
                                    : CircleAvatar(
                                        radius: 80,
                                        backgroundImage: FileImage(imageFile!),
                                      ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                BaseController.showOptions.value = false;
                                showModalBottomSheet(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  context: context,
                                  builder: ((builder) => openImage(context)),
                                );
                              },
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: AppConstants.logoBlueColor,
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        "Arpan Das",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.backgroundColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "JNK12345, arpan.das@test.com, +91 12345 67890, Kolkata, India",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.backgroundColor.withAlpha(240),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SizedBox(height: 35.0),
            // Center(
            //   child: Stack(
            //     alignment: Alignment.bottomRight,
            //     children: [
            //       DottedBorder(
            //         options: CircularDottedBorderOptions(
            //           color: AppConstants.primaryColor,
            //           strokeWidth: 2.5,
            //           dashPattern: const [7, 5, 7, 5, 7, 5],
            //         ),
            //         child: Padding(
            //           padding: const EdgeInsets.all(5.0),
            //           child: imageFile == null || imageFile.toString() == ''
            //               ? CircleAvatar(
            //                   radius: 80,
            //                   backgroundImage: AssetImage(
            //                     AppConstants.profilePlaceholder,
            //                   ),
            //                   backgroundColor: Colors.transparent,
            //                 )
            //               : CircleAvatar(
            //                   radius: 80,
            //                   backgroundImage: FileImage(imageFile!),
            //                 ),
            //         ),
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           showModalBottomSheet(
            //             backgroundColor: Theme.of(
            //               context,
            //             ).scaffoldBackgroundColor,
            //             context: context,
            //             builder: ((builder) => openImage(context)),
            //           );
            //         },
            //         child: const CircleAvatar(
            //           radius: 30,
            //           backgroundColor: AppConstants.logoBlueColor,
            //           child: Icon(
            //             Icons.camera_alt_rounded,
            //             size: 35,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 15.0),
            // Text(
            //   "Arpan Das",
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            //   textAlign: TextAlign.center,
            // ),
            // Text(
            //   "JNK12345, arpan.das@test.com, +91 12345 67890, Kolkata, India",
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: AppConstants.secondaryColor,
            //     fontStyle: FontStyle.italic,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 30),

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
                    "Options",
                    style: TextStyle(
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
            SizedBox(height: 30.0),

            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 100.0),
                children: [
                  customBtn(
                    context,
                    () {
                      BaseController.showOptions.value = false;
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(
                          context,
                        ).modalBarrierDismissLabel,
                        barrierColor: Colors.black54,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder:
                            (
                              BuildContext buildContext,
                              Animation animation,
                              Animation secondaryAnimation,
                            ) {
                              return Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9.0),
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                  ),
                                  width: MediaQuery.of(context).size.width - 20,
                                  height:
                                      MediaQuery.of(context).size.height - 230,
                                  padding: const EdgeInsets.all(2),
                                  child: CustomPrivacyDialog(),
                                ),
                              );
                            },
                      );
                    },
                    Padding(
                      padding: const EdgeInsets.only(left: 3.5),
                      child: Image.asset(
                        'assets/images/aboutAppIcon.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                    "PRIVACY & POLICY",
                    null,
                  ),
                  Divider(
                    thickness: 0.5,
                    color: AppConstants.primaryColor.withValues(alpha: 0.2),
                  ),
                  customBtn(
                    context,
                    () {
                      BaseController.showOptions.value = false;
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(
                          context,
                        ).modalBarrierDismissLabel,
                        barrierColor: Colors.black54,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder:
                            (
                              BuildContext buildContext,
                              Animation animation,
                              Animation secondaryAnimation,
                            ) {
                              return Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9.0),
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                  ),
                                  width: MediaQuery.of(context).size.width - 20,
                                  height:
                                      MediaQuery.of(context).size.height - 230,
                                  padding: const EdgeInsets.all(2),
                                  child: CustomAboutDialog(),
                                ),
                              );
                            },
                      );
                    },
                    Padding(
                      padding: const EdgeInsets.only(left: 3.5),
                      child: Image.asset(
                        'assets/images/aboutAppIcon.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                    "APP INFO",
                    null,
                  ),
                  Divider(
                    thickness: 0.5,
                    color: AppConstants.primaryColor.withValues(alpha: 0.2),
                  ),
                  customBtn(
                    context,
                    () {
                      BaseController.showOptions.value = false;
                      Get.to(() => ChangePassScreen());
                    },
                    Image.asset(
                      'assets/icons/change-password.png',
                      height: 22,
                      width: 22,
                    ),
                    "CHANGE PASSWORD",
                    null,
                  ),
                  Divider(
                    thickness: 0.5,
                    color: AppConstants.primaryColor.withValues(alpha: 0.2),
                  ),
                  customBtn(
                    context,
                    () {
                      BaseController.showOptions.value = false;
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (builder) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            title: Text(
                              "Confirm Logout",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            content: Text(
                              "Please click on Confirm, if you want to logout",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // widget.controller.logout();
                                  // setState(() {});
                                  Get.offAll(() => LoginScreen());
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.blue,
                                  ),
                                  foregroundColor: WidgetStateProperty.all(
                                    Colors.white,
                                  ),
                                ),
                                child: const Text("Confirm"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "No",
                                  style: TextStyle(color: Colors.cyan),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    SvgPicture.asset(
                      'assets/icons/logout.svg',
                      height: 30,
                      width: 30,
                    ),
                    "LOGOUT",
                    null,
                  ),
                  Divider(
                    thickness: 0.5,
                    color: AppConstants.primaryColor.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialButton customBtn(
    BuildContext context,
    action,
    icon,
    text,
    suffixicon,
  ) {
    return MaterialButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: () {
        action();
      },
      child: Row(
        children: [
          icon,
          SizedBox(width: (text == "LOGOUT") ? 9 : 15),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.normal,
                color: AppConstants.secondaryColor,
              ),
            ),
          ),
          (suffixicon != null)
              ? Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: suffixicon,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget openImage(BuildContext context) {
    return Container(
      height: 150.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Choose Image Source",
            style: TextStyle(
              fontSize: 18.0,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_rounded, size: 30.0),
                    onPressed: () {
                      // BaseController.showReload.value = false;
                      Navigator.of(context).pop();
                      takePhoto(ImageSource.camera);
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    "Camera",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_rounded, size: 30.0),
                    onPressed: () {
                      // BaseController.showReload.value = false;
                      Navigator.of(context).pop();
                      takePhoto(ImageSource.gallery);
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    "Gallery",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 30,
        uiSettings: [
          AndroidUiSettings(
            hideBottomControls: true,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(hidesNavigationBar: true, aspectRatioLockEnabled: true),
        ],
      );

      if (croppedImage != null) {
        final path = croppedImage.path;
        setState(() {
          imageFile = File(path);
        });
        int? sizeInBytes = await imageFile?.length();
        double sizeInKb = sizeInBytes! / 1024;
        double sizeInMb = sizeInKb / 1024;
        print('File size in KB: ${sizeInKb.toStringAsFixed(2)} KB');
        print('File size in MB: ${sizeInMb.toStringAsFixed(2)} MB');
        // print("Cropped File =========> ${_imageFile!.path}");

        // widget.controller.updateProfileImage(imageFile);
      }
      // BaseController.showReload.value = false;
      // widget.controller.updateProfileImage(File(pickedFile.path));
    }
  }
}
