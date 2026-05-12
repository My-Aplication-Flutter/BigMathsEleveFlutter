import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "./../../Models/Annales/AnnaleModel.dart";
import "./ProblemesAnnalePage.dart";

class AnnalesPage extends StatefulWidget {
  final String niveau_id;
  const AnnalesPage({super.key, required this.niveau_id});

  @override
  State<AnnalesPage> createState() => _AnnalesPageState();
}

class _AnnalesPageState extends State<AnnalesPage> {
  List<Annale> annales = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAnnales();
  }

  Future<void> fetchAnnales() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://backend-mega-maths-nodejs.vercel.app/api/get-liste-annales-actfs'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "niveau_id": widget.niveau_id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['state'] == true) {
          final List list = data['annales'];

          setState(() {
            annales = list.map((e) => Annale.fromJson(e)).toList();
          });
        } else {
          setState(() {
            error = "Aucune donnée disponible";
          });
        }
      } else {
        setState(() {
          error = "Erreur serveur (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        error = "Erreur réseau";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildCard(Annale annale) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProblemesAnnalePage(
                annaleId: annale.id,
              ),
            ),
          ); // 👉 navigation vers détail (à implémenter)
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image cover
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                annale.cover,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 180, color: Colors.grey[300]),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    annale.titre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    annale.periode,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text("${annale.annee}"),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Annales Maths - Terminale"),
      ),
      body: RefreshIndicator(
        onRefresh: fetchAnnales,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 200),
                      Center(child: Text(error!)),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: fetchAnnales,
                          child: const Text("Réessayer"),
                        ),
                      )
                    ],
                  )
                : annales.isEmpty
                    ? const Center(child: Text("Aucune annale disponible"))
                    : ListView.builder(
                        itemCount: annales.length,
                        itemBuilder: (context, index) {
                          return buildCard(annales[index]);
                        },
                      ),
      ),
    );
  }
}
