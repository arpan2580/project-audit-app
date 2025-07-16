import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomPrivacyDialog extends StatelessWidget {
  final RxBool isLoading = true.obs;
  late final WebViewController controller;

  CustomPrivacyDialog({super.key}) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            if (progress == 100) {
              isLoading.value = false;
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // Hide loading indicator when page is finished loading.
            isLoading.value = false;
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://www.termsfeed.com/live/3a11ed72-3a10-4ba6-8638-c389522ac10c',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => isLoading.value
          ? const Center(child: CircularProgressIndicator.adaptive())
          : WebViewWidget(controller: controller),
    );
  }
}
