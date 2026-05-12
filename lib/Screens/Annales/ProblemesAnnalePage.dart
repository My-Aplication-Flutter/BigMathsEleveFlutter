import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ProblemeViewPage.dart';
import './../ImageViewPage.dart';
import './../LoginPage.dart';

/// =====================
/// MODEL MEDIA CONTENT
/// =====================
class MediaContent {
  final String content;
  final String typeContent;

  MediaContent({
    required this.content,
    required this.typeContent,
  });

  factory MediaContent.fromJson(Map<String, dynamic> json) {
    return MediaContent(
      content: json['content'] ?? "",
      typeContent: json['typeContent'] ?? "",
    );
  }
}

/// =====================
/// MODEL PROBLEME
/// =====================
class Probleme {
  final String id;
  final String titre;
  final int points;

  final List<String> enonceImages;
  final List<String> corrigeImages;
  final List<String> methodologieImages;

  final List<String> themes;
  final List<String> sousThemes;

  Probleme({
    required this.id,
    required this.titre,
    required this.points,
    required this.enonceImages,
    required this.corrigeImages,
    required this.methodologieImages,
    required this.themes,
    required this.sousThemes,
  });

  factory Probleme.fromJson(Map<String, dynamic> json) {
    List<String> extractImages(List<dynamic>? list) {
      if (list == null) return [];

      return list
          .map((e) => MediaContent.fromJson(e).content)
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return Probleme(
      id: json['_id'],
      titre: json['titre'],
      points: json['points'] ?? 0,
      enonceImages: extractImages(json['enonce_images']),
      corrigeImages: extractImages(json['corrige_images']),
      methodologieImages: extractImages(json['methodologie_images']),
      themes:
          (json['themes'] as List?)?.map((e) => e['nom'].toString()).toList() ??
              [],
      sousThemes: (json['sous_themes'] as List?)
              ?.map((e) => e['nom'].toString())
              .toList() ??
          [],
    );
  }
}

/// =====================
/// PAGE
/// =====================
class ProblemesAnnalePage extends StatefulWidget {
  final String annaleId;

  const ProblemesAnnalePage({super.key, required this.annaleId});

  @override
  State<ProblemesAnnalePage> createState() => _ProblemesAnnalePageState();
}

class _ProblemesAnnalePageState extends State<ProblemesAnnalePage> {
  List<Probleme> problemes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProblemes();
  }

  Future<void> fetchProblemes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
                'https://backend-mega-maths-nodejs.vercel.app/api/getListeProblemesByAnnale'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "annale_id": widget.annaleId,
            }),
          )
          .timeout(const Duration(seconds: 15));

      // print("STATUS CODE: ${response.statusCode}");
      // print("BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }

      final data = json.decode(response.body);

      if (data['state'] == true) {
        final List list = data['problemes'];

        setState(() {
          problemes = list.map((e) => Probleme.fromJson(e)).toList();
        });
      } else {
        throw Exception("API state=false");
      }
    } catch (e, stack) {
      print("ERREUR: $e");
      print("STACK: $stack");

      setState(() {
        error = e.toString(); // 🔥 IMPORTANT
      });
    }

    setState(() => isLoading = false);
  }

  /// HEADER
  Widget buildHeader(Probleme p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(p.titre,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Chip(label: Text("${p.points} pts"))
        ],
      ),
    );
  }

  /// THEMES
  Widget buildThemes(Probleme p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 6,
        children: p.themes
            .map((t) => Chip(
                  label: Text(t),
                  backgroundColor: Colors.green.shade50,
                ))
            .toList(),
      ),
    );
  }

  /// SOUS THEMES
  Widget buildSousThemes(Probleme p) {
    if (p.sousThemes.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 6,
        children: p.sousThemes
            .map((t) => Chip(
                  label: Text(t),
                  backgroundColor: Colors.orange.shade50,
                ))
            .toList(),
      ),
    );
  }

  /// IMAGE FULL WIDTH + ZOOM
  Widget buildFullImage(String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerPage(imageUrl: url),
          ),
        );
      },
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(height: 200, color: Colors.grey[300]),
      ),
    );
  }

  Future<void> submitCorrection({
    String? token,
    required String problemeId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://backend-mega-maths-nodejs.vercel.app/api/postCorrectionProblemeByAnnale"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "token": token,
          "probleme_id": problemeId,
          "corrige_text": text,
          "image_url": imageUrl ?? "",
        }),
      );

      print("SUBMIT STATUS: ${response.statusCode}");
      print("SUBMIT BODY: ${response.body}");
    } catch (e) {
      print("ERREUR SUBMIT: $e");
    }
  }

  void openSubmitModal(Probleme p) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    print("token = $token");
    // final token = null; // test

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        /// 🔴 NON CONNECTÉ
        if (token == null || token.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 60, color: Colors.grey),
                const SizedBox(height: 15),
                const Text(
                  "Connexion requise",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Vous devez être connecté pour soumettre un corrigé.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: const Text("Se connecter"),
                  ),
                ),
              ],
            ),
          );
        }

        /// 🟢 CONNECTÉ
        final imageController = TextEditingController();
        final textController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Soumettre ton corrigé",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(p.titre, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 20),

                  /// IMAGE URL
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(
                      labelText: "URL image (optionnel)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 EDITEUR SIMPLE MAIS PRO
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: textController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText:
                            "Écris ta solution ici...\n\n(Étapes, raisonnement, formules)",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final text = textController.text.trim();

                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Réponse obligatoire"),
                            ),
                          );
                          return;
                        }

                        await submitCorrection(
                          token: token,
                          problemeId: p.id,
                          text: text,
                          imageUrl: imageController.text,
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Corrigé envoyé 🚀"),
                          ),
                        );
                      },
                      child: const Text("Envoyer"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ACTIONS
  Widget buildActions(Probleme p) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text("Énoncé"),
                onPressed: p.enonceImages.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProblemeViewerPage(
                              title: p.titre,
                              images: p.enonceImages,
                            ),
                          ),
                        );
                      },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.psychology),
                label: const Text("Méthodo"),
                onPressed: p.methodologieImages.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProblemeViewerPage(
                              title: "${p.titre} - Méthode",
                              images: p.methodologieImages,
                            ),
                          ),
                        );
                      },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("Corrigé"),
                onPressed: p.corrigeImages.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProblemeViewerPage(
                              title: "${p.titre} - Corrigé",
                              images: p.corrigeImages,
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔥 NOUVEAU BOUTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.upload,
                  color: Colors.white), // optionnel mais propre
              label: const Text(
                "Soumettre mon corrigé",
                style: TextStyle(color: Colors.white), // 🔥 texte blanc
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white, // 🔥 icône + texte (global)
              ),
              onPressed: () => openSubmitModal(p),
            ),
          ),
        ],
      ),
    );
  }

  /// CARD
  Widget buildCard(Probleme p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(p),
        buildThemes(p),
        const SizedBox(height: 6),
        buildSousThemes(p),
        const SizedBox(height: 10),
        if (p.enonceImages.isNotEmpty) buildFullImage(p.enonceImages.first),
        buildActions(p),
        const Divider(thickness: 1),
      ],
    );
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Problèmes")),
      body: RefreshIndicator(
        onRefresh: fetchProblemes,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 200),
                      Center(child: Text(error!)),
                    ],
                  )
                : ListView.builder(
                    itemCount: problemes.length,
                    itemBuilder: (_, i) => buildCard(problemes[i]),
                  ),
      ),
    );
  }
}
