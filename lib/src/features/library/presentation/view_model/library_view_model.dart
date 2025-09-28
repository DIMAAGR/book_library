import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/library/presentation/view_model/library_view_model_data.dart';
import 'package:flutter/foundation.dart';

// Disclaimer: Se houvesse outros endpoints para carregar livros lidos recentemente,
// fariamos o prefetch dos itens filtrados aqui. Neste caso, apenas reutilizamos o GetAllBooksUseCase
// para simplificar o exemplo.
//
// ...
// Além do mais preciso simplificar algumas coisas, afinal, só tenho 7 dias para fazer tudo isso :)

class LibraryViewModel {
  LibraryViewModel(this._getBooks, this._getCategories, this._resolver);

  final GetAllBooksUseCase _getBooks;
  final GetCategoriesUseCase _getCategories;
  final ExternalBookInfoResolver _resolver;

  // Eu nem falei isso na vm do home, mas vi esse padrão do LibraryData em mais projetos.
  // pesquisei sobre e descobri que esse padrão do LibraryData (que obviamente é um ValueObject)
  // é a base para diversos gerenciadores de estado, como o BLoC.
  // Juntar tudo em um único objeto facilita o gerenciamento do estado.
  // O Equatable ajuda a comparar instâncias e otimizar atualizações de UI.
  // Acho que vale a pena manter esse padrão... pelo menos nesse projeto.
  final ValueNotifier<ViewModelState<Failure, LibraryData>> state =
      ValueNotifier<ViewModelState<Failure, LibraryData>>(InitialState());

  final ValueNotifier<UiEvent?> event = ValueNotifier<UiEvent?>(null);

  // Já isso aqui é interessante, em um momento eu pensei, poxa, esse cache deveria ser
  // global, mas depois pensei melhor e percebi que não.
  // Se o usuário nunca entrar na tela de detalhes, não faz sentido carregar e manter
  // esses dados na memória. Pior, digamos que ele esteja sendo usado somente para mostrar a imagem
  // da capa do livro (quando acha), os proximos livros podem ser diferentes, e manter eles na memória
  // não significa que serão usados novamente.
  // Então, faz sentido manter esse cache aqui, e quando o usuário sair da tela de biblioteca, tudo será descartado.
  // Se ele voltar, os dados serão recarregados.
  // Se o usuário entrar na tela de detalhes, aí sim, faz sentido manter esses dados na memória, afinal, ele pode navegar
  // entre diversos livros, e não faz sentido ficar recarregando os dados toda hora.
  // (Indo pra o detalhe, voltando pra biblioteca, indo pro detalhe de novo, etc).
  // Afinal foi como eu disse, mesmo que o usuário volte para a tela home, não significa que ele vá querer ver os mesmos livros.
  //
  // ... na verdade, eu poderia por exemplo, antes de procurar novos dados, verificar se o livro já não existe no cache anterior,
  // o cache que está na home por exemplo precisaria estar em outro lugar, pra que eu pudesse reutilizá-lo,
  // mas eu teria que ver se realmente vale a pena...
  //
  // e isso daí já é demais só pra um exemplo hahaha
  final ValueNotifier<Map<String, ExternalBookInfoEntity>> byBookId = ValueNotifier(
    <String, ExternalBookInfoEntity>{},
  );

  Future<void> load() async {
    state.value = LoadingState();

    final catsEither = await _getCategories();
    await catsEither.fold(
      (f) {
        state.value = ErrorState(f);
        event.value = ShowErrorSnackBar(f.message);
      },
      (cats) async {
        final booksEither = await _getBooks();
        booksEither.fold(
          (f) {
            state.value = ErrorState(f);
            event.value = ShowErrorSnackBar(f.message);
          },
          (books) {
            final data = LibraryData(
              categories: cats,
              items: books,
              activeCategoryId: cats.isNotEmpty ? cats.first.id : null,
            );
            state.value = SuccessState(data);

            _prefetchFor(books.take(8));
          },
        );
      },
    );
  }

  void selectCategory(String id) {
    final current = state.value;
    if (current is SuccessState<Failure, LibraryData>) {
      if (current.success.activeCategoryId == id) return;
      state.value = SuccessState(current.success.copyWith(activeCategoryId: id));

      _prefetchFor(current.success.items.take(8));
    }
  }

  Future<void> resolveFor(BookEntity book) async {
    if (byBookId.value.containsKey(book.id)) return;

    final info = await _resolver.resolve(book.title, book.author);
    if (info != null) {
      final next = Map<String, ExternalBookInfoEntity>.from(byBookId.value);
      next[book.id] = info;
      byBookId.value = next;
    }
  }

  Future<void> _prefetchFor(Iterable<BookEntity> books) async {
    final pairs = books.map((b) => (title: b.title, author: b.author));
    await _resolver.prefetch(pairs);
  }

  void consumeEvent() => event.value = null;
}
