import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "annales_page.dart";

/// =====================
/// MODEL
/// =====================
class MenuSection {
  final String name;
  final String niveauId;

  MenuSection({
    required this.name,
    required this.niveauId,
  });

  factory MenuSection.fromJson(Map<String, dynamic> json) {
    return MenuSection(
      name: json['name'] ?? "",
      niveauId: json['niveau_id'] ?? "",
    );
  }
}

/// =====================
/// PAGE
/// =====================
class MenuSectionAnnalePage extends StatefulWidget {
  final String matiere;
  final String nameMenu;
  const MenuSectionAnnalePage(
      {super.key, required this.matiere, required this.nameMenu});

  @override
  State<MenuSectionAnnalePage> createState() => _MenuSectionPageState();
}

class _MenuSectionPageState extends State<MenuSectionAnnalePage> {
  List<MenuSection> sections = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  /// =====================
  /// API CALL
  /// =====================
  Future<void> fetchSections() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await await http.post(
        Uri.parse(
            "https://backend-mega-maths-nodejs.vercel.app/api/getListMenuSectionFrondApp"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "matiere": widget.matiere,
          "nameMenu": widget.nameMenu,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }

      final data = json.decode(response.body);

      if (data['state'] == true) {
        final List list = data['listMenuSection'];

        setState(() {
          sections = list.map((e) => MenuSection.fromJson(e)).toList();
        });
      } else {
        throw Exception("Aucune donnée");
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    setState(() => isLoading = false);
  }

  /// =====================
  /// CARD DESIGN
  /// =====================
  Widget buildCard(MenuSection section) {
    return GestureDetector(
      onTap: () {
        // 👉 navigation future (annales par niveau)
        print("Clicked: ${section.name}");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnalesPage(niveau_id: section.niveauId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            /// ICON
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 28),
            ),

            const SizedBox(width: 15),

            /// TEXT
            Expanded(
              child: Text(
                section.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// ARROW
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  /// =====================
  /// UI
  /// =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Niveaux pédagogiques"),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchSections,
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
                    itemCount: sections.length,
                    itemBuilder: (_, i) => buildCard(sections[i]),
                  ),
      ),
    );
  }
}
