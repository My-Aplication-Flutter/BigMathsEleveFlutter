import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  /// Taille totale du cache
  static Future<int> getCacheSize() async {
    int totalSize = 0;

    final dir = await getTemporaryDirectory();
    if (dir.existsSync()) {
      dir.listSync(recursive: true).forEach((file) {
        if (file is File) {
          totalSize += file.lengthSync();
        }
      });
    }

    return totalSize;
  }

  /// Taille cache images
  static int getImageCacheCount() {
    return PaintingBinding.instance.imageCache.currentSize;
  }

  /// Nettoyer cache images
  static Future<void> clearImageCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Nettoyer SharedPreferences
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Nettoyer fichiers cache
  static Future<void> clearTempFiles() async {
    final dir = await getTemporaryDirectory();
    if (dir.existsSync()) {
      for (final file in dir.listSync()) {
        try {
          file.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// Nettoyage complet
  static Future<void> clearAll() async {
    await clearImageCache();
    await clearPreferences();
    await clearTempFiles();
  }

  /// Formatage taille (Ko, Mo…)
  static String formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }
}
