import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlStorageService {
  static const _favoritesKey = 'favorites';
  static const _startupUrlKey = 'startupUrl';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  static Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  static Future<String?> getStartupUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_startupUrlKey);
  }

  static Future<void> setStartupUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startupUrlKey, url);
  }

  static bool validateUrl(String input) {
    final url = _normalizeUrl(input);
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
  }

  static String normalizeInputUrl(String input) {
    return _normalizeUrl(input);
  }

  static String _normalizeUrl(String input) {
    var url = input.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  static Future<void> launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}