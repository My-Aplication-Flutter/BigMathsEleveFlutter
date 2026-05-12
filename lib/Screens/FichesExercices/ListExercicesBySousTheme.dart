import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'ExerciceViewPage.dart';
import '../ImageViewPage.dart';
import './../LoginPage.dart';

/// =====================================
/// MODEL MEDIA CONTENT
/// =====================================
/// =====================================
/// MODEL MEDIA CONTENT
/// =====================================
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

/// =====================================
/// MODEL EXERCICE
/// =====================================
class Exercice {
  final String id;
  final String titre;
  final int level;

  final List<String> enonceImages;
  final List<String> corrigeImages;
  final List<String> methodologieImages;

  Exercice({
    required this.id,
    required this.titre,
    required this.level,
    required this.enonceImages,
    required this.corrigeImages,
    required this.methodologieImages,
  });

  factory Exercice.fromJson(Map<String, dynamic> json) {
    /// 🔥 EXTRACTION NOUVELLE STRUCTURE API
    List<String> extractImages(dynamic list) {
      print("LIST RAW => $list");
      if (list == null) return [];

      if (list is! List) return [];

      return list
          .map<String>((item) {
            /// CAS:
            /// {
            ///   "content": "...",
            ///   "typeContent": "image_online"
            /// }

            if (item is Map<String, dynamic>) {
              return item['content']?.toString() ?? "";
            }

            return "";
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Exercice(
      id: json['_id'] ?? "",
      titre: json['titre'] ?? "",
      level: json['level'] ?? 1,

      /// 🔥 ADAPTATION API
      enonceImages: extractImages(
        json['enonce_images'],
      ),

      corrigeImages: extractImages(
        json['corrige_images'],
      ),

      methodologieImages: extractImages(
        json['methodologie_images'],
      ),
    );
  }
}

/// =====================================
/// PAGE
/// =====================================
class ExerciceSousThemePage extends StatefulWidget {
  final String sousThemeId;
  final String sousThemeName;

  const ExerciceSousThemePage({
    super.key,
    required this.sousThemeId,
    required this.sousThemeName,
  });

  @override
  State<ExerciceSousThemePage> createState() => _ExerciceSousThemePageState();
}

class _ExerciceSousThemePageState extends State<ExerciceSousThemePage> {
  List<Exercice> exercices = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchExercices();
  }

  /// =====================================
  /// FETCH API
  /// =====================================
  Future<void> fetchExercices() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://backend-mega-maths-nodejs.vercel.app/api/get-liste-exo-by-sous-theme-actifs",
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "sous_theme_id": widget.sousThemeId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['state'] == true) {
        final List list = data['exosSousTheme'];

        setState(() {
          exercices = list.map((e) => Exercice.fromJson(e)).toList();
        });
      } else {
        setState(() {
          error = "Aucun exercice trouvé";
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  /// =====================================
  /// LEVEL COLOR
  /// =====================================
  Color getLevelColor(int level) {
    if (level <= 2) return Colors.green;
    if (level <= 4) return Colors.orange;
    return Colors.red;
  }

  /// =====================================
  /// LEVEL TEXT
  /// =====================================
  String getLevelText(int level) {
    if (level <= 2) return "Facile";
    if (level <= 4) return "Moyen";
    return "Difficile";
  }

  /// =====================================
  /// IMAGE FULL WIDTH
  /// =====================================
  Widget buildImage(String url) {
    print("IMAGE URL BUILD => $url");
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerPage(
              imageUrl: url,
            ),
          ),
        );
      },
      child: Hero(
        tag: url,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            url,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                height: 240,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_not_supported),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// =====================================
  /// SUBMIT CORRECTION
  /// =====================================
  Future<void> submitCorrection({
    required String token,
    required String exerciceId,
    required String text,
    required String imageUrl,
  }) async {
    try {
      await http.post(
        Uri.parse(
          "https://backend-mega-maths-nodejs.vercel.app/api/postCorrectionProblemeByAnnale",
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "token": token,
          "probleme_id": exerciceId,
          "corrige_text": text,
          "image_url": imageUrl,
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  /// =====================================
  /// MODAL SUBMIT
  /// =====================================
  void openSubmitModal(Exercice exo) async {
    const storage = FlutterSecureStorage();

    final token = await storage.read(key: 'auth_token');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        /// ======================
        /// USER NOT CONNECTED
        /// ======================
        if (token == null || token.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 36,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Connexion requise",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Vous devez être connecté pour envoyer votre corrigé.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text(
                      "Se connecter",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }

        /// ======================
        /// CONNECTED
        /// ======================
        final imageController = TextEditingController();
        final textController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Soumettre un corrigé",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    exo.titre,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// URL IMAGE
                  TextField(
                    controller: imageController,
                    decoration: InputDecoration(
                      hintText: "URL image",
                      prefixIcon: const Icon(Icons.image),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// TEXT
                  TextField(
                    controller: textController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: "Écris ton raisonnement mathématique...",
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Envoyer mon corrigé",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        if (textController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "La réponse est obligatoire",
                              ),
                            ),
                          );
                          return;
                        }

                        await submitCorrection(
                          token: token,
                          exerciceId: exo.id,
                          text: textController.text,
                          imageUrl: imageController.text,
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Corrigé envoyé 🚀",
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// =====================================
  /// ACTIONS
  /// =====================================
  Widget buildActions(Exercice exo) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text("Énoncé"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: exo.enonceImages.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciceViewerPage(
                              title: exo.titre,
                              images: exo.enonceImages,
                            ),
                          ),
                        );
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.psychology),
                label: const Text("Méthodo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: exo.methodologieImages.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciceViewerPage(
                              title: "${exo.titre} - Méthodo",
                              images: exo.methodologieImages,
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.upload,
              color: Colors.white,
            ),
            label: const Text(
              "Soumettre mon corrigé",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => openSubmitModal(exo),
          ),
        ),
      ],
    );
  }

  /// =====================================
  /// CARD
  /// =====================================
  Widget buildCard(Exercice exo) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          if (exo.enonceImages.isNotEmpty) buildImage(exo.enonceImages.first),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  exo.titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 15),

                /// LEVEL
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: getLevelColor(exo.level).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 18,
                            color: getLevelColor(exo.level),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            getLevelText(exo.level),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getLevelColor(exo.level),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Niveau ${exo.level}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                buildActions(exo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =====================================
  /// UI
  /// =====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          widget.sousThemeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchExercices,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : error != null
                ? Center(
                    child: Text(error!),
                  )
                : exercices.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucun exercice disponible",
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 30,
                        ),
                        itemCount: exercices.length,
                        itemBuilder: (_, index) {
                          return buildCard(
                            exercices[index],
                          );
                        },
                      ),
      ),
    );
  }
}
