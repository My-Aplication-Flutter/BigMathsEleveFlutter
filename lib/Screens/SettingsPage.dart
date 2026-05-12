import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/painting.dart';
import '../main.dart';
import "./diagnostic_page.dart";

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  ////////////////////////////////////////////////////////////
  /// 🧹 CLEAR CACHE
  ////////////////////////////////////////////////////////////
  Future<void> _clearCache(BuildContext context) async {
    try {
      // 🧹 Efface le cache images Flutter
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 🧹 Efface les données locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 🔄 Recharge les settings après nettoyage
      MyApp.of(context).settings.load();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cache vidé avec succès"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors du nettoyage: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: AnimatedBuilder(
        animation: appState.settings,
        builder: (context, _) {
          final settings = appState.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ////////////////////////////////////////////////////////////
              /// 🌙 DARK MODE
              ////////////////////////////////////////////////////////////
              SwitchListTile(
                title: const Text("Mode sombre"),
                value: settings.isDarkMode,
                onChanged: (v) => settings.toggleTheme(v),
              ),

              const Divider(),

              ////////////////////////////////////////////////////////////
              /// 🔠 TEXT SIZE
              ////////////////////////////////////////////////////////////
              const Text("Taille du texte"),
              Slider(
                value: settings.textScale,
                min: 0.8,
                max: 1.6,
                divisions: 4,
                label: settings.textScale.toStringAsFixed(1),
                onChanged: (v) => settings.setTextScale(v),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => settings.setTextScale(0.9),
                    child: const Text("A⁻"),
                  ),
                  TextButton(
                    onPressed: () => settings.setTextScale(1.3),
                    child: const Text("A⁺"),
                  ),
                ],
              ),

              const Divider(),

              ////////////////////////////////////////////////////////////
              /// 📱 LAYOUT
              ////////////////////////////////////////////////////////////
              const Text("Disposition des articles"),

              RadioListTile(
                value: "large",
                groupValue: settings.layout,
                title: const Text("Grande image"),
                onChanged: (v) => settings.setLayout(v!),
              ),

              RadioListTile(
                value: "compact",
                groupValue: settings.layout,
                title: const Text("Compact"),
                onChanged: (v) => settings.setLayout(v!),
              ),

              const Divider(),

              ////////////////////////////////////////////////////////////
              /// 🧹 CLEAR CACHE
              ////////////////////////////////////////////////////////////
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Effacer le cache'),
                subtitle: const Text('Vider les images et données locales'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmer"),
                      content: const Text(
                        "Voulez-vous vraiment vider le cache ?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Annuler"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Vider"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _clearCache(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text("Diagnostic & Stockage"),
                subtitle: const Text("Voir et gérer le cache"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DiagnosticPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
