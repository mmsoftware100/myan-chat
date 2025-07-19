import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  // final String url = 'http://mc.thelectors.com/newapp/'; // 'https://www.google.com';
  // final String url = 'http://192.168. 100.1'; // 'https://www.google.com';
  final String url =  'https://www.google.com';
  // 192.168. 100.1
  late final WebViewController _controller;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    // #docregion platform_features
    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Myan Chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: loadingPercentage / 100,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue.shade300,
            ),
          ),
        ),
        actions: [
          NavigationControls(webViewController: _controller),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }
}