import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  static const String _cacheFolderName = 'logo_cache';
  Directory? _cacheDirectory;

  // Lista di proxy CORS gratuiti
  static const List<String> _corsProxies = [
    'https://api.allorigins.win/raw?url=',
    'https://corsproxy.io/?',
    'https://thingproxy.freeboard.io/fetch/',
    'https://cors-anywhere.herokuapp.com/',
  ];

  /// Inizializza la directory di cache
  Future<void> _initCacheDirectory() async {
    if (_cacheDirectory != null) return;

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = Directory(path.join(appDir.path, _cacheFolderName));

    if (!await _cacheDirectory!.exists()) {
      await _cacheDirectory!.create(recursive: true);
    }
  }

  /// Genera un nome file basato sull'URL
  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final fileName = path.basename(uri.path);
    final extension = path.extension(fileName);

    // Se non ha estensione, aggiungi .png
    if (extension.isEmpty) {
      return '${uri.host}_${DateTime.now().millisecondsSinceEpoch}.png';
    }

    return '${uri.host}_${DateTime.now().millisecondsSinceEpoch}$extension';
  }

  /// Scarica e salva un'immagine
  Future<String?> downloadAndCacheImage(String url) async {
    try {
      await _initCacheDirectory();

      final fileName = _getFileNameFromUrl(url);
      final filePath = path.join(_cacheDirectory!.path, fileName);
      final file = File(filePath);

      // Se il file esiste già, restituisci il path
      if (await file.exists()) {
        debugPrint('✅ Image already cached: $filePath');
        return filePath;
      }

      debugPrint('🔄 Downloading image: $url');

      // Prova prima senza proxy
      String? downloadedPath = await _downloadImageDirect(url, file);
      if (downloadedPath != null) {
        return downloadedPath;
      }

      // Se fallisce, prova con i proxy CORS
      for (final proxy in _corsProxies) {
        debugPrint('🔄 Trying CORS proxy: $proxy');
        downloadedPath = await _downloadImageWithProxy(proxy, url, file);
        if (downloadedPath != null) {
          return downloadedPath;
        }
      }

      debugPrint('❌ All download methods failed for: $url');
      return null;
    } catch (e) {
      debugPrint('❌ Error downloading image: $e');
      return null;
    }
  }

  /// Scarica l'immagine direttamente
  Future<String?> _downloadImageDirect(String url, File file) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'DNT': '1',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Image cached successfully (direct): ${file.path}');
        return file.path;
      } else {
        debugPrint(
            '❌ Direct download failed. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Direct download error: $e');
      return null;
    }
  }

  /// Scarica l'immagine usando un proxy CORS
  Future<String?> _downloadImageWithProxy(
      String proxy, String url, File file) async {
    try {
      final proxyUrl = proxy + Uri.encodeComponent(url);
      debugPrint('🔄 Proxy URL: $proxyUrl');

      final response = await http.get(
        Uri.parse(proxyUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'DNT': '1',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Image cached successfully (proxy): ${file.path}');
        return file.path;
      } else {
        debugPrint(
            '❌ Proxy download failed. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Proxy download error: $e');
      return null;
    }
  }

  /// Ottiene il path di un'immagine se è già in cache
  Future<String?> getCachedImagePath(String url) async {
    try {
      await _initCacheDirectory();

      final fileName = _getFileNameFromUrl(url);
      final filePath = path.join(_cacheDirectory!.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting cached image: $e');
      return null;
    }
  }

  /// Pulisce la cache
  Future<void> clearCache() async {
    try {
      await _initCacheDirectory();

      if (await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
        debugPrint('🗑️ Image cache cleared');
      }
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }
}
