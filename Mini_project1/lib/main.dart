import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/url_storage_service.dart';
import 'widgets/settings_modal.dart';

// For webview_flutter v4+, you need to enable hybrid composition for Android.
// In Flutter 3+, this is handled automatically, but for older versions you might need:
//   if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

void main() {
  runApp(const FullscreenWebViewerApp());
}

class FullscreenWebViewerApp extends StatelessWidget {
  const FullscreenWebViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fullscreen WebViewer',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: const FullscreenWebViewScreen(),
    );
  }
}

class FullscreenWebViewScreen extends StatefulWidget {
  const FullscreenWebViewScreen({super.key});

  @override
  State<FullscreenWebViewScreen> createState() =>
      _FullscreenWebViewScreenState();
}

class _FullscreenWebViewScreenState extends State<FullscreenWebViewScreen> {
  WebViewController? _webViewController;
  String _currentUrl = '';
  bool _showError = false;
  bool _loading = true;
  String _errorMsg = '';
  List<String> _favorites = [];
  String? _startupUrl;

  @override
  void initState() {
    super.initState();
    _loadFavoritesAndStartup();
  }

  Future<void> _loadFavoritesAndStartup() async {
    final favorites = await UrlStorageService.getFavorites();
    final startupUrl = await UrlStorageService.getStartupUrl();
    setState(() {
      _favorites = favorites;
      _startupUrl = startupUrl ?? 'https://flutter.dev';
      _currentUrl = _startupUrl!;
    });
  }

  void _onWebResourceError(WebResourceError error) {
    setState(() {
      _showError = true;
      _errorMsg = error.description;
    });
  }

  void _retryLoad() {
    setState(() {
      _showError = false;
      _loading = true;
    });
    _webViewController?.loadRequest(Uri.parse(_currentUrl));
  }

  void _openSettingsModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.95),
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => SettingsModal(
        currentUrl: _currentUrl,
        favorites: _favorites,
        startupUrl: _startupUrl,
      ),
    );

    if (result != null) {
      if (result.containsKey('loadUrl')) {
        final url = result['loadUrl'] as String;
        setState(() {
          _currentUrl = url;
          _showError = false;
        });
        _webViewController?.loadRequest(Uri.parse(url));
      }
      if (result.containsKey('favorites')) {
        setState(() {
          _favorites = result['favorites'] as List<String>;
        });
      }
      if (result.containsKey('startupUrl')) {
        setState(() {
          _startupUrl = result['startupUrl'] as String;
        });
      }
      if (result.containsKey('openExternal')) {
        // Open in external browser
        final url = result['openExternal'] as String;
        UrlStorageService.launchExternalUrl(url);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_webViewController != null && await _webViewController!.canGoBack()) {
      _webViewController!.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar, no footer, nothing but the WebView and floating button
      body: Stack(
        children: [
          WillPopScope(
            onWillPop: _onWillPop,
            child: WebView(
              initialUrl: _currentUrl,
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onPageStarted: (_) {
                setState(() {
                  _loading = true;
                  _showError = false;
                });
              },
              onPageFinished: (_) {
                setState(() {
                  _loading = false;
                });
              },
              onWebResourceError: _onWebResourceError,
              // For full HTML5 fullscreen video support, no extra param needed in webview_flutter v4+
            ),
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_showError)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const Text(
                        'Failed to load site',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(_errorMsg, style: const TextStyle(color: Colors.redAccent)),
                      ),
                      ElevatedButton(
                        onPressed: _retryLoad,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Floating settings button
          Positioned(
            right: 16,
            bottom: 32,
            child: GestureDetector(
              onTap: _openSettingsModal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.settings, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}