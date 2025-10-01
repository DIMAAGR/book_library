class ExternalCatalogVolumeModel {
  const ExternalCatalogVolumeModel({
    required this.title,
    this.description,
    this.coverUrl,
    this.isbn13,
  });

  factory ExternalCatalogVolumeModel.fromRootJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?) ?? const [];
    if (items.isEmpty) {
      return const ExternalCatalogVolumeModel(title: '');
    }
    late Map<String, dynamic> item;

    for (Map<String, dynamic> i in items) {
      // ignore: avoid_dynamic_calls
      if (i['volumeInfo']['imageLinks'] != null) {
        item = i;
        break;
      }
    }
    final info = (item['volumeInfo'] as Map?) ?? const {};
    final images = (info['imageLinks'] as Map?) ?? const {};
    final idents = (info['industryIdentifiers'] as List?) ?? const [];

    String? isbn13;
    for (final raw in idents) {
      final m = (raw as Map);
      if (m['type'] == 'ISBN_13') {
        isbn13 = m['identifier'] as String?;
        break;
      }
    }
    isbn13 ??=
        (idents.whereType<Map>().firstWhere(
              (m) => m['type'] == 'ISBN_10',
              orElse: () => const {},
            )['identifier']
            as String?);

    return ExternalCatalogVolumeModel(
      title: (info['title'] as String?) ?? '',
      description: info['description'] as String?,
      coverUrl: (images['thumbnail'] as String?) ?? (images['smallThumbnail'] as String?),
      isbn13: isbn13,
    );
  }

  final String title;
  final String? description;
  final String? coverUrl;
  final String? isbn13;
}
