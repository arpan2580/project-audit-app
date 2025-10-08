import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;
  final bool isLocal;

  const ImageViewScreen({
    super.key,
    required this.imageUrl,
    required this.isLocal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: (isLocal)
              ? Image.file(File(imageUrl), fit: BoxFit.contain)
              : Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
