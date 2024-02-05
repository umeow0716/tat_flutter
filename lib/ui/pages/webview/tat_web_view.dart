// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/ui/pages/webview/in_app_webview_callbacks.dart';
import 'package:flutter_app/ui/pages/webview/web_view_button_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:developer' as developer;

class TATWebView extends StatefulWidget {
  const TATWebView({
    super.key,
    required Uri initialUrl,
    String? title,
  })  : _initialUrl = initialUrl,
        _title = title;

  final Uri _initialUrl;
  final String? _title;

  @override
  State<TATWebView> createState() => _TATWebViewState();
}

class _TATWebViewState extends State<TATWebView> {
  final cookieManager = CookieManager.instance();
  final cookieJar = DioConnector.instance.cookiesManager;
  late final InAppWebViewController _controller;

  // A value shows the progress of page loading. Range from 0.0 to 1.0.
  final progress = ValueNotifier(0.0);

  Future<void> setInitialCookies() async {
    final cookies = await cookieJar.loadForRequest(widget._initialUrl);

    for (final cookie in cookies) {
      await cookieManager.setCookie(
        url: widget._initialUrl,
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path ?? '/',
        maxAge: cookie.maxAge,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly,
      );
    }
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _controller = controller;
  }

  void _onProgressChanged(int webViewProgress) {
    progress.value = webViewProgress / 100.0;
  }

  Future<ServerTrustAuthResponse?> _onReceivedTrustAuthReqCallBack(
    InAppWebViewController controller,
    URLAuthenticationChallenge challenge,
  ) async =>
      ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);

  Widget _buildTATWebViewCore() => _TATWebViewCore(
        initialUrl: widget._initialUrl,
        onWebViewCreated: _onWebViewCreated,
        onProgressChanged: (_, progress) => _onProgressChanged(progress),
        onReceivedTrustAuthReqCallBack: _onReceivedTrustAuthReqCallBack,
      );

  Widget _buildButtonBar() => WebViewButtonBar(
        onBackPressed: () => _controller.goBack(),
        onForwardPressed: () => _controller.goForward(),
        onRefreshPressed: () => _controller.reload(),
      );

  Widget _buildProgressBar() => ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, progress, __) => SizedBox(
          child: progress < 1.0
              ? LinearProgressIndicator(
                  value: progress,
                  color: Colors.greenAccent,
                )
              : const SizedBox.shrink(),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ), 
          title: Text(widget._title ?? ''),
        ),
        body: WillPopScope(
          onWillPop: () async {
            bool result = await _controller.canGoBack() as bool;
            _controller.goBack();
            return !result;
          },
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: FutureBuilder(
                  future: setInitialCookies(),
                  builder: (context, snapshot) => _buildTATWebViewCore(),
                ),
              ),
              _buildButtonBar(),
            ],
          ),
        ),
      );
}

class _TATWebViewCore extends StatelessWidget {
  const _TATWebViewCore({
    required Uri initialUrl,
    InAppWebViewCreatedCallback? onWebViewCreated,
    InAppWebViewProgressChangedCallback? onProgressChanged,
    InAppWebViewReceivedServerTrustAuthRequestCallBack? onReceivedTrustAuthReqCallBack,
  })  : _initialUrl = initialUrl,
        _onWebViewCreated = onWebViewCreated,
        _onProgressChanged = onProgressChanged,
        _onReceivedTrustAuthReqCallBack = onReceivedTrustAuthReqCallBack;

  final Uri _initialUrl;
  final InAppWebViewCreatedCallback? _onWebViewCreated;
  final InAppWebViewProgressChangedCallback? _onProgressChanged;
  final InAppWebViewReceivedServerTrustAuthRequestCallBack? _onReceivedTrustAuthReqCallBack;

  @override
  Widget build(BuildContext context) => InAppWebView(
        initialUrlRequest: URLRequest(url: _initialUrl),
        onWebViewCreated: _onWebViewCreated,
        onProgressChanged: _onProgressChanged,
        onReceivedServerTrustAuthRequest: _onReceivedTrustAuthReqCallBack,
        onDownloadStartRequest: (controller, request) async {
          developer.log(await controller.evaluateJavascript(source: 'document.cookie'));
          await FlutterDownloader.enqueue(
            url: request.url.toString(),
            headers: {
                HttpHeaders.connectionHeader: 'keep-alive',
                HttpHeaders.cookieHeader: await controller.evaluateJavascript(source: 'document.cookie'),
            },
            savedDir: (await getExternalStorageDirectory())!.path,
            showNotification: true, // show download progress in status bar (for Android)
            openFileFromNotification: true, // click on notification to open downloaded file (for Android)
            saveInPublicStorage: true
          );
        },
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useOnDownloadStart: true,
          )
        )
  );
}
