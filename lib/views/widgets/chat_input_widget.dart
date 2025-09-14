import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputWidget extends StatelessWidget {
  const ChatInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePicker chatImgPicker = ImagePicker();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Row(
          children: [
            // Text Input Container
            Expanded(
              child: Container(
                // padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40.0,
                      child: IconButton(
                        onPressed: () {
                          takePhoto(ImageSource.camera, chatImgPicker);
                        },
                        icon: Icon(Icons.camera_alt, color: Colors.grey),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 1.0),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40.0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.attach_file, color: Colors.grey),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: 1.0),
                      ),
                    ),
                    // const SizedBox(width: 8),
                    // Icon(Icons.attach_file, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Mic Button
            CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.send, color: Colors.white, size: 22.0),
            ),
          ],
        ),
      ),
    );
  }
}

void takePhoto(ImageSource source, ImagePicker picker) async {
  // final pickedFile = await picker.pickImage(source: source);

  // if (pickedFile != null) {
  //   CroppedFile? croppedImage = await ImageCropper().cropImage(
  //     sourcePath: pickedFile.path,
  //     compressFormat: ImageCompressFormat.jpg,
  //     compressQuality: 50,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         hideBottomControls: true,
  //         lockAspectRatio: true,
  //         initAspectRatio: CropAspectRatioPreset.square,
  //       ),
  //       IOSUiSettings(hidesNavigationBar: true, aspectRatioLockEnabled: true),
  //     ],
  //   );

  //   if (croppedImage != null) {
  //     final path = croppedImage.path;
  //     setState(() {
  //       imageFile = File(path);
  //     });
  //     // print("Cropped File =========> ${_imageFile!.path}");

  //     // widget.controller.updateProfileImage(imageFile);
  //   }
  // BaseController.showReload.value = false;
  // widget.controller.updateProfileImage(File(pickedFile.path));
}
