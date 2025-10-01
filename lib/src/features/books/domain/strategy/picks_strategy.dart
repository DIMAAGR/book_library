import 'package:book_library/src/features/books/domain/entities/book_entity.dart';

// Strategy pattern (PickStrategy)

// Para que serve?
// Permite definir diferentes algoritmos de seleção (picking) de livros,
// encapsulando cada um em uma classe separada que implementa a interface PickStrategy.
// Isso facilita a adição de novos algoritmos sem modificar o código existente,
// promovendo a extensibilidade e a manutenção do código.

abstract class PickStrategy {
  List<BookEntity> pick(List<BookEntity> input);
}

class PickNewReleases extends PickStrategy {
  PickNewReleases({this.limit = 12});
  final int limit;

  @override
  List<BookEntity> pick(List<BookEntity> input) {
    final list = [...input]
      ..sort((a, b) => (b.published ?? DateTime(0)).compareTo(a.published ?? DateTime(0)));
    return list.take(limit).toList();
  }
}

class PickPopularAZ extends PickStrategy {
  PickPopularAZ({this.limit = 10});
  final int limit;
  @override
  List<BookEntity> pick(List<BookEntity> input) {
    final list = [...input]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list.take(limit).toList();
  }
}

class PickSimilarToFavorites extends PickStrategy {
  PickSimilarToFavorites({
    required this.favoriteIds,
    required this.favoriteAuthorsLower,
    PickPopularAZ? fallback,
    this.limit = 12,
  }) : fallback = fallback ?? PickPopularAZ(limit: 12);

  final Set<String> favoriteIds;
  final Set<String> favoriteAuthorsLower;
  final PickStrategy fallback;
  final int limit;

  @override
  List<BookEntity> pick(List<BookEntity> input) {
    final similar = input
        .where(
          (b) =>
              !favoriteIds.contains(b.id) && favoriteAuthorsLower.contains(b.author.toLowerCase()),
        )
        .toList();
    if (similar.isEmpty) return fallback.pick(input);
    return similar.take(limit).toList();
  }
}
