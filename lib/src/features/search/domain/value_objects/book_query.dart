import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:equatable/equatable.dart';

// se você está aqui e não entendeu nada vou te explicar rapidinho:

// esse é um Value Object que representa uma query de busca de livros
// ele é usado para filtrar e ordenar os livros favoritos
// ele contém os seguintes campos:
// - title: string que representa o título do livro (pode ser vazio)
// - author: string que representa o autor do livro (pode ser vazio)
// - publisher: string que representa a editora do livro (pode ser vazio)
// - publishedRange: intervalo de datas em que o livro foi publicado
// - sort: estratégia de ordenação a ser aplicada aos resultados

// ele também contém um método copyWith para facilitar a criação de novas instâncias
// e um método props para facilitar a comparação de instâncias.

// para entender o que é cada coisa, veja os arquivos:
// - sort_strategy.dart (estratégias de ordenação)
// - book_specifications.dart (especificações para filtrar livros)

enum PublishedRange { recent2020plus, classicBefore2000, any }

class BookQuery extends Equatable {
  const BookQuery({
    this.title = '',
    this.author = '',
    this.publisher = '',
    this.publishedRange = PublishedRange.any,
    this.sort = const SortByAZ(),
  });
  final String title;
  final String author;
  final String publisher;
  final PublishedRange publishedRange;
  final SortStrategy sort;

  BookQuery copyWith({
    String? title,
    String? author,
    String? publisher,
    PublishedRange? publishedRange,
    SortStrategy? sort,
  }) {
    return BookQuery(
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publishedRange: publishedRange ?? this.publishedRange,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [title, author, publisher, publishedRange, sort];
}
