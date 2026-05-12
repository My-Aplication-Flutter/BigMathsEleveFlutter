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
