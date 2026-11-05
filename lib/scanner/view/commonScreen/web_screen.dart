import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/color.dart';
import '../../utils/helper_functions.dart';

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
        color: Colors.white,
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

PreferredSizeWidget normalAppBarBuilder(String title, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  return AppBar(
    scrolledUnderElevation: 0,
    elevation: 0,
    shadowColor: Colors.transparent,
    backgroundColor: Colors.transparent, // Make AppBar transparent
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    title: Text(
      title,
      style: TextStyle(
        fontSize: convertFigmaToUIWidth(20, width),
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: cyangreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(10),
      child: SizedBox(),
    ),
  );
}
