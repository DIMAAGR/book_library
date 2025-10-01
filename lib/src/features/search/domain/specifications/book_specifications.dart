import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';

// se você está aqui e não entendeu nada vou te explicar rapidinho:

// esse é um conjunto de especificações para filtrar livros

// e o que é uma especificação?
// uma especificação é uma regra que um livro deve satisfazer
// para ser incluído em um conjunto de resultados.

// sabendo disso, temos as seguintes especificações:
// - TitleContains: verifica se o título do livro contém uma string
// - AuthorContains: verifica se o autor do livro contém uma string
// - PublisherContains: verifica se a editora do livro contém uma string
// - PublishedInRange: verifica se o livro foi publicado em um intervalo de datas

// cada especificação é uma classe que implementa a interface BookSpecifications
// cada especificação tem um método isSatisfiedBy que recebe um BookEntity e retorna um bool
// indicando se o livro satisfaz a especificação ou não.
// você pode combinar especificações usando o método and, que retorna uma nova especificação
// que é a conjunção das duas especificações.

// por que usar especificações?
// usar especificações torna o código mais modular, reutilizável e testável.
// você pode criar novas especificações facilmente e combiná-las de diferentes maneiras
// para criar consultas complexas.

abstract class BookSpecifications {
  bool isSatisfiedBy(BookEntity b);
  BookSpecifications and(BookSpecifications other) => _AndSpec(this, other);
}

String normalize(String s) => s.toLowerCase().trim();

class TitleContains extends BookSpecifications {
  TitleContains(this.q);
  final String q;
  @override
  bool isSatisfiedBy(BookEntity b) => q.isEmpty || normalize(b.title).contains(normalize(q));
}

class AuthorContains extends BookSpecifications {
  AuthorContains(this.q);
  final String q;
  @override
  bool isSatisfiedBy(BookEntity b) => q.isEmpty || normalize(b.author).contains(normalize(q));
}

class PublisherContains extends BookSpecifications {
  PublisherContains(this.q);
  final String q;
  @override
  bool isSatisfiedBy(BookEntity b) =>
      q.isEmpty || normalize(b.publisher ?? '').contains(normalize(q));
}

class AuthorIn extends BookSpecifications {
  AuthorIn(this.lowerAuthors);
  final Set<String> lowerAuthors;
  @override
  bool isSatisfiedBy(BookEntity b) =>
      lowerAuthors.isEmpty ? false : lowerAuthors.contains(b.author.toLowerCase());
}

class NotInIds extends BookSpecifications {
  NotInIds(this.ids);
  final Set<String> ids;
  @override
  bool isSatisfiedBy(BookEntity b) => !ids.contains(b.id);
}

class AllowAll extends BookSpecifications {
  @override
  bool isSatisfiedBy(BookEntity b) => true;
}

class PublishedInRange extends BookSpecifications {
  PublishedInRange({this.minInclusive, this.maxExclusive});

  final DateTime? minInclusive;
  final DateTime? maxExclusive;

  @override
  bool isSatisfiedBy(BookEntity b) {
    if (minInclusive == null && maxExclusive == null) return true;

    final d = b.published;
    if (d == null) return false;
    if (minInclusive != null && d.isBefore(minInclusive!)) return false;
    if (maxExclusive != null && !d.isBefore(maxExclusive!)) return false;
    return true;
  }

  static PublishedRangeSpec fromEnum(Enum range) {
    switch (range) {
      case PublishedRange.recent2020plus:
        return PublishedRangeSpec._recent();
      case PublishedRange.classicBefore2000:
        return PublishedRangeSpec._classic();
      default:
        return PublishedRangeSpec._any();
    }
  }
}

class PublishedRangeSpec extends PublishedInRange {
  PublishedRangeSpec._any() : super(minInclusive: null, maxExclusive: null);
  PublishedRangeSpec._recent() : super(minInclusive: DateTime(2020, 1, 1));
  PublishedRangeSpec._classic() : super(minInclusive: null, maxExclusive: DateTime(2000, 1, 1));
}

class _AndSpec extends BookSpecifications {
  _AndSpec(this.a, this.b);
  final BookSpecifications a, b;
  @override
  bool isSatisfiedBy(BookEntity x) => a.isSatisfiedBy(x) && b.isSatisfiedBy(x);
}
