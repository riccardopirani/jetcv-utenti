import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Base64ImageService {
  static final Base64ImageService _instance = Base64ImageService._internal();
  factory Base64ImageService() => _instance;
  Base64ImageService._internal();

  // Lista di proxy CORS gratuiti
  static const List<String> _corsProxies = [
    'https://api.allorigins.win/raw?url=',
    'https://corsproxy.io/?',
    'https://thingproxy.freeboard.io/fetch/',
    'https://cors-anywhere.herokuapp.com/',
  ];

  /// Converte un'immagine in Base64
  Future<String?> getImageAsBase64(String imageUrl) async {
    try {
      debugPrint('🔄 Converting image to Base64: $imageUrl');

      // Prova prima senza proxy
      Uint8List? imageBytes = await _downloadImageDirect(imageUrl);
      if (imageBytes != null) {
        return _encodeToBase64(imageBytes);
      }

      // Se fallisce, prova con i proxy CORS
      for (final proxy in _corsProxies) {
        debugPrint('🔄 Trying CORS proxy for Base64: $proxy');
        imageBytes = await _downloadImageWithProxy(proxy, imageUrl);
        if (imageBytes != null) {
          return _encodeToBase64(imageBytes);
        }
      }

      debugPrint('❌ All download methods failed for Base64: $imageUrl');
      return null;
    } catch (e) {
      debugPrint('❌ Error converting image to Base64: $e');
      return null;
    }
  }

  /// Scarica l'immagine direttamente
  Future<Uint8List?> _downloadImageDirect(String url) async {
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
        debugPrint('✅ Image downloaded successfully (direct)');
        return response.bodyBytes;
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
  Future<Uint8List?> _downloadImageWithProxy(String proxy, String url) async {
    try {
      final proxyUrl = proxy + Uri.encodeComponent(url);
      debugPrint('🔄 Proxy URL for Base64: $proxyUrl');

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
        debugPrint('✅ Image downloaded successfully (proxy)');
        return response.bodyBytes;
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

  /// Converte i bytes in Base64
  String _encodeToBase64(Uint8List bytes) {
    final base64String = base64Encode(bytes);
    debugPrint('✅ Image converted to Base64 successfully');
    return base64String;
  }
}
