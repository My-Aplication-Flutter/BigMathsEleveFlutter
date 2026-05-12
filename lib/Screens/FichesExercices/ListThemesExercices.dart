import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "ListExercicesBySousTheme.dart";

/// =======================================
/// MODEL SOUS THEME
/// =======================================
class SousTheme {
  final String id;
  final String nom;

  SousTheme({
    required this.id,
    required this.nom,
  });

  factory SousTheme.fromJson(Map<String, dynamic> json) {
    return SousTheme(
      id: json['_id'] ?? "",
      nom: json['nom'] ?? "",
    );
  }
}

/// =======================================
/// MODEL THEME
/// =======================================
class ThemeModel {
  final String id;
  final String nom;
  final List<SousTheme> sousThemes;

  ThemeModel({
    required this.id,
    required this.nom,
    required this.sousThemes,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['_id'] ?? "",
      nom: json['nom'] ?? "",
      sousThemes: (json['listSousThemes'] as List?)
              ?.map((e) => SousTheme.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// =======================================
/// PAGE
/// =======================================
class ThemesPage extends StatefulWidget {
  final String niveauId;

  const ThemesPage({
    super.key,
    required this.niveauId,
  });

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  List<ThemeModel> themes = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchThemes();
  }

  /// =======================================
  /// API
  /// =======================================
  Future<void> fetchThemes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://backend-mega-maths-nodejs.vercel.app/api/get-liste-themes-actifs",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "niveau_id": widget.niveauId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data['state'] == true) {
        final List list = data['Themes'];

        setState(() {
          themes = list.map((e) => ThemeModel.fromJson(e)).toList();
        });
      } else {
        throw Exception("Aucun thème");
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

  /// =======================================
  /// CARD THEME
  /// =======================================
  Widget buildThemeCard(ThemeModel theme) {
    return GestureDetector(
      onTap: () {
        print("THEME CLICKED => ${theme.nom}");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          childrenPadding: const EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          leading: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6A11CB),
                  Color(0xFF2575FC),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: Text(
            theme.nom,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "${theme.sousThemes.length} sous-thèmes",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          /// ========================
          /// SOUS THEMES
          /// ========================
          children: [
            Column(
              children: theme.sousThemes.map((sousTheme) {
                return GestureDetector(
                  onTap: () {
                    print("SOUS THEME => ${sousTheme.nom}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciceSousThemePage(
                            sousThemeId: sousTheme.id,
                            sousThemeName: sousTheme.nom),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// ICON LEFT
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6A11CB),
                                Color(0xFF2575FC),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// TITLE
                        Expanded(
                          child: Text(
                            sousTheme.nom,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),

                        /// RIGHT ARROW
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================================
  /// UI
  /// =======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Thèmes de Mathématiques",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: fetchThemes,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 250),
                      Center(
                        child: Text(error!),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 30,
                    ),
                    children: themes.map(buildThemeCard).toList(),
                  ),
      ),
    );
  }
}
