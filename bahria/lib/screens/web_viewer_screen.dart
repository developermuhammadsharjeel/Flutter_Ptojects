import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/error_widget.dart';

class WebViewerScreen extends StatefulWidget {
  const WebViewerScreen({Key? key}) : super(key: key);

  @override
  State<WebViewerScreen> createState() => _WebViewerScreenState();
}

class _WebViewerScreenState extends State<WebViewerScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isConnected = true;
  StreamSubscription? _connectivitySubscription;
  final String _url = 'https://cms.bahria.edu.pk/Logins/Student/Login.aspx';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _setupConnectivityListener();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
        if (_isConnected && _hasError) {
          _reloadWebView();
        }
      });
    });
  }

  void _reloadWebView() {
    _webViewController.loadRequest(Uri.parse(_url));
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (!_isConnected)
              CustomErrorWidget(
                message: 'No internet connection',
                onRetry: () {
                  _checkConnectivity();
                  if (_isConnected) {
                    _reloadWebView();
                  }
                },
              )
            else if (_hasError)
              CustomErrorWidget(
                message: 'Failed to load the website',
                onRetry: _reloadWebView,
              )
            else
              WebViewWidget(controller: _webViewController),

            if (_isLoading && _isConnected)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}