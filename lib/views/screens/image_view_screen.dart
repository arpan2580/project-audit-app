import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;
  final bool isLocal;
  final File? fileImage;
  final bool showDownloadButton;

  const ImageViewScreen({
    super.key,
    required this.imageUrl,
    required this.isLocal,
    this.fileImage,
    this.showDownloadButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: showDownloadButton
          ? AppBar(
              title: const Text('View Image'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () {
                    DialogHelper.showLoadingDialog("Downloading Image...");
                    BaseController.saveImageToGallery(imageUrl, context);
                    DialogHelper.hideLoadingDialog();
                  },
                ),
              ],
            )
          : AppBar(title: const Text('View Image'), centerTitle: true),
      body: Container(
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
              end: Alignment.center,
              colors: [
                AppConstants.primaryColor.withValues(alpha: 0.5),
                AppConstants.backgroundColor.withValues(alpha: 0.5),
                AppConstants.backgroundColor.withValues(alpha: 0.7),
                AppConstants.backgroundColor.withValues(alpha: 0.7),
                AppConstants.backgroundColor.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: (isLocal)
                    ? Image.file(File(imageUrl), fit: BoxFit.contain)
                    : Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
