import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const WebsiteLauncherApp());
}

class WebsiteLauncherApp extends StatelessWidget {
  const WebsiteLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In-App Browser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebsiteHomePage(),
    );
  }
}

class WebsiteHomePage extends StatefulWidget {
  const WebsiteHomePage({super.key});

  @override
  State<WebsiteHomePage> createState() => _WebsiteHomePageState();
}

class _WebsiteHomePageState extends State<WebsiteHomePage> {
  String? savedUrl;
  bool isLoading = true;
  bool isWebViewVisible = false;
  late WebViewController webViewController;
  bool isWebViewLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _loadSavedUrl();
  }

  void _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isWebViewLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isWebViewLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            _showErrorSnackBar('Error loading page: ${error.description}');
          },
        ),
      );
  }

  Future<void> _loadSavedUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('saved_url');

      setState(() {
        savedUrl = url;
        isLoading = false;
      });

      if (savedUrl != null) {
        _loadWebPage(savedUrl!);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar("Error loading saved URL: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _saveUrl(String url) async {
    // Normalize URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      // Validate URL
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) {
        throw Exception("Invalid URL format");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_url', url);
      setState(() {
        savedUrl = url;
      });

      _loadWebPage(url);
    } catch (e) {
      _showErrorSnackBar("Error saving URL: $e");
    }
  }

  void _loadWebPage(String url) {
    setState(() {
      isWebViewVisible = true;
      isWebViewLoading = true;
    });

    webViewController.loadRequest(Uri.parse(url));
  }

  void _showUrlInputDialog() {
    final urlController = TextEditingController();
    urlController.text = savedUrl ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(savedUrl == null ? 'Enter Website URL' : 'Update Website URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Text(
              "Examples:\n• https://cms.bahria.edu.pk/Logins/Student/Login.aspx\n• https://flutter.dev\n• youtube.com",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String inputUrl = urlController.text.trim();
              if (inputUrl.isNotEmpty) {
                _saveUrl(inputUrl);
                Navigator.pop(context);
              } else {
                _showErrorSnackBar('Please enter a URL');
              }
            },
            child: const Text('Save & Open'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.language, size: 80, color: Colors.blue),
            const SizedBox(height: 30),

            Text(
              savedUrl == null
                  ? 'No website saved yet'
                  : 'Current website:',
              style: const TextStyle(fontSize: 18),
            ),
            if (savedUrl != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  savedUrl!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.public),
                label: const Text('Open Website'),
                onPressed: () => _loadWebPage(savedUrl!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: Icon(savedUrl == null ? Icons.add : Icons.edit),
              label: Text(savedUrl == null ? 'Add Website URL' : 'Change Website URL'),
              onPressed: _showUrlInputDialog,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isWebViewVisible ? (savedUrl ?? 'In-App Browser') : 'In-App Browser'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (isWebViewVisible)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                webViewController.reload();
              },
            ),
          IconButton(
            icon: Icon(isWebViewVisible ? Icons.home : Icons.edit),
            onPressed: isWebViewVisible
                ? () => setState(() => isWebViewVisible = false)
                : _showUrlInputDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWebViewVisible
          ? Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (isWebViewLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      )
          : _buildHomeScreen(),
      floatingActionButton: isWebViewVisible
          ? FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: _showUrlInputDialog,
      )
          : null,
    );
  }
}