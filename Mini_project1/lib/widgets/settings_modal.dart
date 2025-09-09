import 'package:flutter/material.dart';
import '../services/url_storage_service.dart';

class SettingsModal extends StatefulWidget {
  final String currentUrl;
  final List<String> favorites;
  final String? startupUrl;

  const SettingsModal({
    super.key,
    required this.currentUrl,
    required this.favorites,
    required this.startupUrl,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();
  String? _selectedFavorite;
  List<String> _favorites = [];
  String? _startupUrl;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _favorites = List.from(widget.favorites);
    _startupUrl = widget.startupUrl;
    _urlController.text = '';
  }

  void _addUrl() {
    final urlInput = _urlController.text.trim();
    final url = UrlStorageService.normalizeInputUrl(urlInput);

    if (!UrlStorageService.validateUrl(url)) {
      setState(() {
        _errorText = 'Invalid URL';
      });
      return;
    }
    if (_favorites.contains(url)) {
      setState(() {
        _errorText = 'Already in favorites';
      });
      return;
    }
    setState(() {
      _favorites.add(url);
      _errorText = null;
      _urlController.clear();
    });
    UrlStorageService.saveFavorites(_favorites);
  }

  void _deleteFavorite(String url) {
    setState(() {
      _favorites.remove(url);
      if (_selectedFavorite == url) _selectedFavorite = null;
    });
    UrlStorageService.saveFavorites(_favorites);
  }

  void _renameFavorite(String url, String newName) {
    final idx = _favorites.indexOf(url);
    if (idx != -1) {
      setState(() {
        _favorites[idx] = newName;
        _selectedFavorite = null;
      });
      UrlStorageService.saveFavorites(_favorites);
    }
  }

  void _setStartupUrl(String url) {
    setState(() {
      _startupUrl = url;
    });
    UrlStorageService.setStartupUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Center(
              child: Container(
                height: 4,
                width: 48,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Add URL',
                errorText: _errorText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addUrl,
                ),
              ),
              keyboardType: TextInputType.url,
              autofillHints: const [AutofillHints.url],
              onSubmitted: (_) => _addUrl(),
            ),
            const SizedBox(height: 8),
            if (_favorites.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Favorites', style: Theme.of(context).textTheme.titleMedium),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _favorites.length,
                    itemBuilder: (ctx, idx) {
                      final url = _favorites[idx];
                      return ListTile(
                        title: Text(url, style: const TextStyle(fontSize: 14)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_browser),
                              onPressed: () {
                                Navigator.of(context).pop({'openExternal': url});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteFavorite(url),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _selectedFavorite = url;
                                  _renameController.text = url;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.star),
                              color: (_startupUrl == url) ? Colors.amber : Colors.grey,
                              onPressed: () => _setStartupUrl(url),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pop({'loadUrl': url});
                        },
                        subtitle: (_startupUrl == url)
                            ? const Text('Startup URL', style: TextStyle(color: Colors.amber, fontSize: 10))
                            : null,
                      );
                    },
                  ),
                  if (_selectedFavorite != null)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _renameController,
                            decoration: const InputDecoration(labelText: 'Rename favorite'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            final newName = _renameController.text.trim();
                            if (UrlStorageService.validateUrl(newName)) {
                              _renameFavorite(_selectedFavorite!, newName);
                              setState(() {
                                _selectedFavorite = null;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedFavorite = null;
                            });
                          },
                        ),
                      ],
                    ),
                ],
              ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.star),
                    label: const Text('Save Current as Favorite'),
                    onPressed: () {
                      final url = UrlStorageService.normalizeInputUrl(widget.currentUrl);
                      if (UrlStorageService.validateUrl(url) && !_favorites.contains(url)) {
                        setState(() {
                          _favorites.add(url);
                        });
                        UrlStorageService.saveFavorites(_favorites);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open in External Browser'),
                    onPressed: () {
                      Navigator.of(context).pop({'openExternal': widget.currentUrl});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Set as Startup URL'),
                    onPressed: () {
                      _setStartupUrl(widget.currentUrl);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop({
                        'favorites': _favorites,
                        'startupUrl': _startupUrl,
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}