import 'package:flutter/material.dart';
import '../Services/cache_service.dart';

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  int cacheSize = 0;
  int imageCacheCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    cacheSize = await CacheService.getCacheSize();
    imageCacheCount = CacheService.getImageCacheCount();
    setState(() => loading = false);
  }

  Future<void> action(Function fn) async {
    setState(() => loading = true);
    await fn();
    await loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diagnostic stockage")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  title: const Text("Taille du cache"),
                  trailing: Text(CacheService.formatBytes(cacheSize)),
                ),
                ListTile(
                  title: const Text("Images en cache"),
                  trailing: Text(imageCacheCount.toString()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Nettoyer images"),
                  onTap: () => action(CacheService.clearImageCache),
                ),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text("Nettoyer fichiers temporaires"),
                  onTap: () => action(CacheService.clearTempFiles),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Effacer préférences"),
                  onTap: () => action(CacheService.clearPreferences),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text("Tout nettoyer"),
                  subtitle: const Text("Images, fichiers, préférences"),
                  onTap: () => action(CacheService.clearAll),
                ),
              ],
            ),
    );
  }
}
