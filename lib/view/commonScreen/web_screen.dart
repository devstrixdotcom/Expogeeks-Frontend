import 'package:event_pro/sharedwidget/appbar__search_field.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatefulWidget {
  final String initialUrl;
  final String titleText;

  WebScreen({required this.initialUrl, required this.titleText, super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: normalAppBarBuilder(widget.titleText, context),
      body: Container(
        // color: Colors.white,
        color: Color.fromRGBO(204, 232, 234, 0.7),
        margin: EdgeInsets.only(top: 10),
        // child: WebView(
        //   initialUrl: widget.initialUrl,
        //   javascriptMode: JavascriptMode.unrestricted,
        // ),
        child: WebViewWidget(
          controller:
              WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setBackgroundColor(const Color(0x00000000))
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onProgress: (int progress) {
                      // Update loading bar.
                    },
                    onPageStarted: (String url) {},
                    onPageFinished: (String url) {},
                    onWebResourceError: (WebResourceError error) {},
                    onNavigationRequest: (NavigationRequest request) {
                      return NavigationDecision.navigate;
                    },
                  ),
                )
                ..loadRequest(Uri.parse(widget.initialUrl)),
        ),
      ),
    );
  }
}
