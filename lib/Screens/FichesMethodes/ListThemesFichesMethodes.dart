import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "FichesMethodesByTheme.dart";

/// =======================================
/// MODEL THEME
/// =======================================
class ThemeModel {
  final String id;
  final String nom;

  ThemeModel({
    required this.id,
    required this.nom,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['_id'] ?? "",
      nom: json['nom'] ?? "",
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
        throw Exception("Aucun thème trouvé");
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
  /// CARD
  /// =======================================
  Widget buildThemeCard(ThemeModel theme) {
    return GestureDetector(
      onTap: () {
        print("THEME CLICKED => ${theme.nom}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SousThemesMethodesPage(themeId: theme.id, themeName: theme.nom),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON
            Container(
              width: 60,
              height: 60,
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
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            /// TITLE
            Expanded(
              child: Text(
                theme.nom,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),

            /// ARROW
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================================
  /// LOADING
  /// =======================================
  Widget buildLoading() {
    return const Center(
      child: CupertinoActivityIndicator(
        radius: 18,
      ),
    );
  }

  /// =======================================
  /// ERROR
  /// =======================================
  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          error ?? "Erreur inconnue",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// =======================================
  /// EMPTY
  /// =======================================
  Widget buildEmpty() {
    return const Center(
      child: Text(
        "Aucun thème disponible",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Thèmes de Mathématiques",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchThemes,
        child: Builder(
          builder: (context) {
            if (isLoading) {
              return buildLoading();
            }

            if (error != null) {
              return ListView(
                children: [
                  const SizedBox(height: 250),
                  buildError(),
                ],
              );
            }

            if (themes.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 250),
                  buildEmpty(),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 30,
              ),
              itemCount: themes.length,
              itemBuilder: (_, index) {
                return buildThemeCard(
                  themes[index],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
