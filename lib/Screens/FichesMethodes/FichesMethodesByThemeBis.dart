
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ImageViewPage.dart';

/// ==========================================
/// MODEL FICHE METHODE
/// ==========================================
class FicheMethode {
  final String url;
  final String typeContent;

  FicheMethode({
    required this.url,
    required this.typeContent,
  });

  factory FicheMethode.fromJson(Map<String, dynamic> json) {
    print("FICHE JSON => $json");

    return FicheMethode(
      url: json['content'] ?? "", // 🔥 IMPORTANT
      typeContent: json['typeContent'] ?? "",
    );
  }
}

/// ==========================================
/// MODEL SOUS THEME
/// ==========================================
class SousTheme {
  final String id;
  final String nom;

  final List<FicheMethode> fichesMethodes;

  SousTheme({
    required this.id,
    required this.nom,
    required this.fichesMethodes,
  });

  factory SousTheme.fromJson(Map<String, dynamic> json) {
    return SousTheme(
      id: json['_id'] ?? "",
      nom: json['nom'] ?? "",
      fichesMethodes: (json['fiches_methodes'] as List?)
              ?.map((e) => FicheMethode.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// ==========================================
/// PAGE
/// ==========================================
class SousThemesMethodesPage extends StatefulWidget {
  final String themeId;
  final String themeName;

  const SousThemesMethodesPage({
    super.key,
    required this.themeId,
    required this.themeName,
  });

  @override
  State<SousThemesMethodesPage> createState() => _SousThemesMethodesPageState();
}

class _SousThemesMethodesPageState extends State<SousThemesMethodesPage> {
  List<SousTheme> sousThemes = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSousThemes();
  }

  /// ==========================================
  /// FETCH API
  /// ==========================================
  Future<void> fetchSousThemes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://backend-mega-maths-nodejs.vercel.app/api/get-liste-sous-themes-actifs",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "theme_id": widget.themeId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Erreur HTTP ${response.statusCode}",
        );
      }

      final data = jsonDecode(response.body);

      if (data['state'] == true) {
        final List list = data['SousThemes'];

        setState(() {
          sousThemes = list.map((e) => SousTheme.fromJson(e)).toList();
        });
      } else {
        throw Exception("Aucun sous-thème trouvé");
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

  /// ==========================================
  /// IMAGE
  /// ==========================================
  Widget buildImage(String url) {
    print("IMAGE URL => $url");

    if (url.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text("URL image vide"),
        ),
      );
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          url.trim(),
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,

          /// 🔥 LOADING
          loadingBuilder: (
            context,
            child,
            loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              height: 240,
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },

          /// 🔥 ERROR
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            print("IMAGE ERROR => $error");

            return Container(
              height: 240,
              color: Colors.red.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      url,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ==========================================
  /// CARD
  /// ==========================================
  Widget buildSousThemeCard(SousTheme sousTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===========================
          /// HEADER
          /// ===========================
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6A11CB),
                        Color(0xFF2575FC),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    sousTheme.nom,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ===========================
          /// BADGE
          /// ===========================
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "${sousTheme.fichesMethodes.length} fiche(s) méthode",
                style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// ===========================
          /// LISTE IMAGES
          /// ===========================
          if (sousTheme.fichesMethodes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "Aucune fiche méthode disponible",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            Column(
              children: sousTheme.fichesMethodes.map((fiche) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 18,
                    right: 18,
                    bottom: 18,
                  ),
                  child: buildImage(fiche.url),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// ==========================================
  /// UI
  /// ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          widget.themeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchSousThemes,
        child: Builder(
          builder: (context) {
            /// LOADING
            if (isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 18,
                ),
              );
            }

            /// ERROR
            if (error != null) {
              return ListView(
                children: [
                  const SizedBox(height: 250),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            /// EMPTY
            if (sousThemes.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(
                    child: Text(
                      "Aucun sous-thème disponible",
                    ),
                  ),
                ],
              );
            }

            /// LIST
            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 30,
              ),
              itemCount: sousThemes.length,
              itemBuilder: (_, index) {
                return buildSousThemeCard(
                  sousThemes[index],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
