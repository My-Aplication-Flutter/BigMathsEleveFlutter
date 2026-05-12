
class Annale {
  final String id;
  final String titre;
  final String cover;
  final int annee;
  final String periode;
  final DateTime date;

  Annale({
    required this.id,
    required this.titre,
    required this.cover,
    required this.annee,
    required this.periode,
    required this.date,
  });

  factory Annale.fromJson(Map<String, dynamic> json) {
    return Annale(
      id: json['_id'],
      titre: json['titre'],
      cover: json['cover'],
      annee: json['annee'],
      periode: json['periode'],
      date: DateTime.parse(json['date']),
    );
  }
}