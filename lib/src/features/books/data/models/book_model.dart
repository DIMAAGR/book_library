class BookModel {
  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    id: json['id']?.toString() ?? '',
    title: (json['title'] as String?)?.trim() ?? '',
    author: (json['author'] as String?)?.trim() ?? '',
    published: json['published'] as String?,
    publisher: (json['publisher'] as String?)?.trim(),
  );

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.published,
    this.publisher,
  });

  final String id;
  final String title;
  final String author;
  final String? published;
  final String? publisher;
}
