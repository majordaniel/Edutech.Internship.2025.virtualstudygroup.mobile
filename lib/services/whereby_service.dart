import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WherebyService {
  static Widget buildWherebyView({
    required String meetingUrl,
    required VoidCallback onMeetingLeft,
    required Function(String) onError,
  }) {
    // Create controller
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(meetingUrl))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🌐 Whereby page started: $url');
          },
          onPageFinished: (String url) {
            print('✅ Whereby page loaded: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Whereby error: ${error.description}');
            onError('Failed to load meeting: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🧭 Navigation to: ${request.url}');

            // Detect when user leaves the meeting
            if (!request.url.contains('whereby.com')) {
              onMeetingLeft();
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    return WebViewWidget(controller: controller);
  }
}
