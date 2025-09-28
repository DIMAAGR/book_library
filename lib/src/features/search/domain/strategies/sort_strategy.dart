import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:equatable/equatable.dart';

// se você está aqui e não entendeu nada vou te explicar rapidinho:

// esse é um conjunto de estratégias de ordenação para livros
// e o que é uma estratégia de ordenação?

// uma estratégia de ordenação é uma forma de ordenar uma lista de livros
// baseado em algum critério.

// sabendo disso, temos as seguintes estratégias:
// - SortByAZ: ordena os livros em ordem alfabética crescente pelo título
// - SortByNewest: ordena os livros do mais novo para o mais antigo pela data
// - SortByOldest: ordena os livros do mais antigo para o mais novo pela data

// cada estratégia é uma classe que implementa a interface SortStrategy
// cada estratégia tem um método sort que recebe uma lista de BookEntity e retorna
// uma nova lista ordenada baseado na estratégia.

// por que usar estratégias de ordenação?
// usar estratégias de ordenação torna o código mais modular, reutilizável e testável.
// você pode criar novas estratégias facilmente e usá-las em diferentes partes do código.

abstract class SortStrategy extends Equatable {
  const SortStrategy();
  List<BookEntity> sort(List<BookEntity> input);
}

class SortByAZ extends SortStrategy {
  const SortByAZ();
  @override
  List<Object?> get props => [];
  @override
  List<BookEntity> sort(List<BookEntity> input) =>
      [...input]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
}

class SortByNewest extends SortStrategy {
  const SortByNewest();
  @override
  List<Object?> get props => [];
  @override
  List<BookEntity> sort(List<BookEntity> input) =>
      [...input]
        ..sort((a, b) => (b.published ?? DateTime(0)).compareTo(a.published ?? DateTime(0)));
}

class SortByOldest extends SortStrategy {
  const SortByOldest();
  @override
  List<Object?> get props => [];
  @override
  List<BookEntity> sort(List<BookEntity> input) =>
      [...input]
        ..sort((a, b) => (a.published ?? DateTime(0)).compareTo(b.published ?? DateTime(0)));
}
