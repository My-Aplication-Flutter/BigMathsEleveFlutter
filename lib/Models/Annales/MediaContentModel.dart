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
