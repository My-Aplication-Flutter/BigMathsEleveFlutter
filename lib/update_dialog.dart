import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class UpdateDialog {
  /// URL de ton fichier version.json
  final String versionUrl;
  final BuildContext context;

  UpdateDialog({
    required this.context,
    required this.versionUrl,
  });

  /// Vérifie s'il y a une nouvelle version et affiche la popup
  Future<void> checkAndShow() async {
    final navigator = Navigator.of(context);

    try {
      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode != 200) {
        // tu peux loguer ou afficher un snackbar
        return;
      }

      final data = Map<String, dynamic>.from(json.decode(response.body));

      final remoteVersion = data['version'] as String;
      final downloadUrl = data['url'] as String;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewVersionAvailable(currentVersion, remoteVersion)) {
        await _showUpdateDialog(
          remoteVersion: remoteVersion,
          downloadUrl: downloadUrl,
          navigator: navigator,
        );
      }
    } on SocketException {
      // Erreur réseau
      _showErrorDialog('Connexion réseau indisponible.');
    } on FormatException {
      // JSON invalide
      _showErrorDialog('Réponse du serveur invalide.');
    } catch (e) {
      _showErrorDialog(
          "Erreur lors de la vérification de la mise à jour. ${e}");
    }
  }

  bool _isNewVersionAvailable(String current, String remote) {
    final currentParts = current.split('.');
    final remoteParts = remote.split('.');

    final currentNum = int.parse(currentParts[0]) * 10000 +
        int.parse(currentParts[1]) * 100 +
        int.parse(currentParts[2]);

    final remoteNum = int.parse(remoteParts[0]) * 10000 +
        int.parse(remoteParts[1]) * 100 +
        int.parse(remoteParts[2]);

    return remoteNum > currentNum;
  }

  Future<void> _showUpdateDialog({
    required String remoteVersion,
    required String downloadUrl,
    required NavigatorState navigator,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle version disponible'),
        content: Text(
          'Une nouvelle version ($remoteVersion) est disponible. '
          'Voulez‑vous la télécharger et l’installer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Plus tard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startDownload(downloadUrl, navigator);
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showProgressDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Téléchargement'),
            content: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Téléchargement + installation de l'APK
  Future<void> _startDownload(String url, NavigatorState navigator) async {
    File? file;

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showErrorDialog(
          'Permission d\'écriture requise pour télécharger la mise à jour.',
        );
        return;
      }

      await _showProgressDialog(
          navigator.context, 'Préparation du téléchargement...');

      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        Navigator.of(navigator.context, rootNavigator: true).pop();
        _showErrorDialog('Impossible de trouver le dossier de stockage.');
        return;
      }

      file = File('${dir.path}/app-update.apk');

      final request = http.Request('GET', Uri.parse(url));
      final streamed = await request.send();

      if (streamed.statusCode != 200) {
        Navigator.of(navigator.context, rootNavigator: true).pop();
        _showErrorDialog('Échec du téléchargement du fichier APK.');
        return;
      }

      final total = streamed.contentLength ?? 0;
      int received = 0;
      final bytes = <int>[];

      await for (final chunk in streamed.stream) {
        bytes.addAll(chunk);
        received += chunk.length;

        if (total > 0) {
          final percent = ((received / total) * 100).toStringAsFixed(0);
          if (navigator.context.mounted) {
            Navigator.of(navigator.context, rootNavigator: true).pop();
            await _showProgressDialog(
              navigator.context,
              'Téléchargement en cours... $percent%',
            );
          }
        }
      }

      await file.writeAsBytes(bytes, flush: true);

      Navigator.of(navigator.context, rootNavigator: true).pop();

      await showDialog(
        context: navigator.context,
        builder: (ctx) => AlertDialog(
          title: const Text('Téléchargement terminé'),
          content: Text(
            'APK téléchargé avec succès.\n\n'
            'Fichier enregistré ici :\n${file!.path}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final result = await OpenFilex.open(file!.path);
                if (result.type != ResultType.done) {
                  _showErrorDialog(
                    'Impossible d’ouvrir l’APK. Vérifiez que le fichier est valide.',
                  );
                }
              },
              child: const Text('Ouvrir APK'),
            ),
          ],
        ),
      );
    } on SocketException {
      if (navigator.context.mounted) {
        Navigator.of(navigator.context, rootNavigator: true).pop();
      }
      _showErrorDialog(
          'Connexion réseau interrompue pendant le téléchargement.');
    } on FileSystemException {
      if (navigator.context.mounted) {
        Navigator.of(navigator.context, rootNavigator: true).pop();
      }
      _showErrorDialog(
        'Erreur de lecture/écriture du fichier. Vérifiez l’espace de stockage.',
      );
    } catch (e) {
      if (navigator.context.mounted) {
        Navigator.of(navigator.context, rootNavigator: true).pop();
      }
      _showErrorDialog(
          'Erreur inattendue lors du téléchargement/installation.');
    }
  }

  /// Lance directement la vérification
  void show() {
    checkAndShow();
  }
}
