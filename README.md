
# BookList

Aplicativo Flutter desenvolvido como desafio técnico. O objetivo inicial era construir um app simples de gerenciamento de livros com listagem, busca, detalhes e favoritos.

## Escopo do Teste

-   Tela de listagem de livros
    -   Consumir a API REST (mockapi)
    -   Mostrar título, autor e ano
    -   Campo de busca com **debounce**
-   Tela de detalhes
    -   Mostrar dados do livro
    -   Marcar/desmarcar favorito
-   Tela de favoritos
    -   Mostrar apenas livros favoritados
    -   Armazenamento **local persistente** (SharedPreferences), não apenas em memória

## Telas Adicionais

Além do que foi pedido, o projeto ganhou algumas telas para enriquecer a experiência:  
- **Onboarding** com ilustrações para introduzir o app  
- **Tela de leitura** com:  
  - controle de fonte (`Aa`)  
  - espaçamento entre linhas  
  - tema claro/escuro/sépia  
- **Tela de explorador** (explore) com sugestões e filtros  
- **Tela de configurações**:  
  - alternância de tema (light, dark, sepia)  
  - ajustes básicos de preferências  
- **Empty states**:  
  - Sem resultados de busca  
  - Favoritos vazios  
  - Sem conexão

### Launcher & Initial Flow
O app introduz uma LauncherView como ponto de entrada.  
Sua responsabilidade é decidir a navegação inicial com base no estado do onboarding persistido no armazenamento local (SharedPreferences via KeyValueWrapper).
 - Se o onboarding não foi concluído, o usuário é redirecionado para a OnboardView.
 - Se o onboarding já foi concluído, o usuário é redirecionado diretamente para a HomeView.
 - Essa decisão é controlada pelo GetOnboardingDoneUseCase e exposta através do LauncherViewModel.

Para desacoplar navegação e feedbacks de UI transitórios do estado em si, o app utiliza um sistema de UI Event:
 - NavigateTo para mudanças de rota
 - ShowSnackBar, ShowErrorSnackBar, ShowSuccessSnackBar para mensagens únicas

Isso garante que navegação e eventos efêmeros não fiquem misturados com o estado persistente (ViewModelState).

## Arquitetura

O projeto segue **Feature-First + MVVM + Clean Architecture**:

-   **Feature-First**: cada feature (ex.: `books`, `onboarding`, `settings`) é um módulo isolado com `domain`, `data` e `presentation`.
-   **MVVM**:
    -   **View**: UI pura, sem lógica
    -   **ViewModel**: orquestra casos de uso, expõe estados (`ValueNotifier`)
    -   **Model**: entidades de domínio
-   **Clean Architecture**:
    -   `domain` -> contratos e regras de negócio
    -   `data` -> implementações (API, cache, etc.)
    -   `presentation` -> UI + viewmodels

 **Regras de propriedade (Ownership):** Cada regra de negócio pertence à feature. Se várias telas precisam excluir um livro, todas chamam o mesmo `DeleteBookUseCase`. Isso garante **Single Source of Truth**.

## Tema e Design System

O app usa uma camada central de theming em `core/theme`:  
- `AppColorsLight`, `AppColorsDark`, `AppColorsSepia`  
- `AppTextStyles` padronizado  
- `AppTheme` para gerar `ThemeData`  
- **ThemeController** (singleton) com `ValueNotifier` + `SharedPreferences` para persistir

Dessa forma, a UI acessa cores via:

``` dart
Theme.of(context).colors.textPrimary
```

sem acoplar valores hardcoded.

## Integração com APIs

- **MockAPI**: usada para a listagem principal de livros no teste.  
- **Catálogo externo (Google Books)**: fornece **informações adicionais** (descrição, categorias, links, preview em PDF/epub).  
  - O acesso é separado em `features/books/data/datasources/external/` para não misturar responsabilidades.  
  - Uso de `.env` para manter a chave de API segura e configurável.  
  - O cliente HTTP é construído com **Dio**, registrado no `get_it` para injeção e com suporte a interceptors (logging, headers dinâmicos).  

Essa separação garante que trocar ou remover o catálogo externo não impacte o fluxo principal do app.

## Decisões Técnicas

-   **get_it**: Escolhido para injeção de dependência por ser leve e direto. Evita boilerplate do Provider e dá controle manual sobre ciclo de vida.
-   **ValueNotifier / ChangeNotifier**: Para estados simples (ex.: tema, loading, listas), `ValueNotifier` é suficiente. É mais performático e menos verboso que streams ou bloc em casos pequenos. Usei `ChangeNotifier` apenas onde há múltiplos estados observáveis.
-   **SharedPreferences**: Persistência simples para manter tema e favoritos. Abstraído via `KeyValueWrapper` para facilitar troca no futuro.
-   **go_router**: Navegação declarativa, mais simples de escalar que `Navigator.push`.
-   **dartz (Either)**: Para tratamento de erros funcional e explícito (ex.: `Either<Failure, Book>`), evitando exceções escondidas.
-   **Dio + .env**: Configuração de API segura e centralizada, permitindo ambientes distintos (dev/prod).

## Técnicas de Otimização de Requisições Externas

Durante o desenvolvimento do app, surgiu a necessidade de buscar informações adicionais de livros em catálogos externos (ex.: capas, ISBN, descrição).
Isso gera múltiplas requisições simultâneas -> maior latência para o usuário e maior carga no servidor da API.
Para melhorar a experiência, adotei técnicas de otimização inspiradas em sistemas de cache e controle de concorrência.

### LRU Cache (Least Recently Used)
- O que é: Estrutura de cache que guarda os itens mais recentemente usados e descarta os mais antigos quando atinge o limite.
- Por que: Evita refazer requisições para o mesmo livro repetidamente.
- Impacto: Acesso instantâneo a livros já consultados, reduzindo latência e tráfego.

### Inflight Request Coalescing
- O que é: Técnica que une múltiplas requisições para o mesmo recurso em apenas uma chamada real.
- Por que: Se várias partes da UI pedirem a mesma capa ao mesmo tempo, todas recebem o mesmo Future.
- Impacto: Menos chamadas duplicadas, economia de rede e CPU.

### Concurrency Limiter (Semáforo)
- O que é: Limita o número de requisições simultâneas (ex.: 6 ao mesmo tempo).
- Por que: Evita sobrecarregar o device do usuário e o servidor externo.
- Impacto: Fluxo mais estável, menor risco de timeouts, uso balanceado da rede.

### Prefetch em Lote
- O que é: Buscar antecipadamente os livros mais prováveis de serem vistos (ex.: os próximos no scroll).
- Por que: Quando o usuário rola a lista, os próximos itens já estão carregados.
- Impacto: Sensação de fluidez, lista sem travamentos.

### Resumo
Essas técnicas juntas permitem que a app escale bem mesmo com grandes listas de livros, mantendo boa performance de UI, reduzindo tempo de resposta e custo de rede.

## Pacotes Utilizados

-   [get_it](https://pub.dev/packages/get_it) -> injeção de dependência
-   [shared_preferences](https://pub.dev/packages/shared_preferences) -> persistência leve
-   [go_router](https://pub.dev/packages/go_router) -> navegação
-   [dartz](https://pub.dev/packages/dartz) -> monads (`Either`) para erros
-   [intl](https://pub.dev/packages/intl) -> formatação de datas
-   [mask_text_input_formatter](https://pub.dev/packages/mask_text_input_formatter) -> formatação de inputs
-   [dio](https://pub.dev/packages/dio) -> cliente HTTP
-   [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) -> variáveis de ambiente

## Design Patterns adotados

-   **MVVM (Presentation)** ViewModels orquestram Casos de Uso e expõem estado imutável para a View (via `ValueNotifier`/`ViewModelState`). A View não contém regra de negócio, apenas renderiza e delega intenção.
-   **Clean Architecture** Domínio (contratos/regras) isolado de Data (SDK/IO) via **Repository Pattern**. `domain` define interfaces; `data` implementa; `presentation` orquestra.
-   **Factory (Domínio)** Construção de entidades garantindo invariantes (ex.: `SavedBooks.add(...)` valida e retorna `Either<Failure, Entity>`).
-   **Mapper (Data)** Conversão **DTO ↔ Entity** isolada (mapeadores/`Model.toEntity()`), evitando "vazamento" de serialização para o domínio.
-   **Strategy (Domínio)** Filtros e ordenações como estratégias pluggáveis (ex.: `SortByNewest`, `SortByAZ`, `FilterByRating`), permitindo combinar políticas sem duplicação.
-   **Adapter (Infra/DataSource)** Encapsula SDKs e serviços (ex.: HTTP client, SharedPreferences) atrás de interfaces estáveis, trocáveis em testes.
-   **Value Object (Domínio)** Tipos com validação embutida para valores (ex.: `BookTitle`, `PublishedYear`), reduzindo estados inválidos.
-   **State (Presentation)** Estados explícitos do ViewModel (`Initial/Loading/Success/Error`) para clareza de fluxo e UI previsível.
-   **Railway-Oriented / Error as Data** Uso de `Dartz.Either<Failure, T>` para encadear operações de forma segura e previsível, sem exceptions "silenciosas".
-   **Repository + Cache (Data)** O `FavoritesRepository` abstrai o mecanismo de persistência. Atualmente usa `SharedPreferences` via `KeyValueWrapper`, mas pode evoluir para Hive/SQLite sem impacto no domínio. Isso aplica o princípio de **Dependency Inversion**.

### Padrões para Pesquisa

-   **Specification (Domínio)** Predicados de busca (ex.: `TitleContains(query)`) modelados como especificações combináveis (`and/or`), mantendo regra de filtro no domínio.
-   **Query Object (Domínio/Aplicação)** Objeto que encapsula parâmetros de busca/ordenação/paginação (ex.: `BookQuery { title, sort, ratingMin, language }`) passado ao caso de uso/repositório. Facilita testes e evolução da API.
-   **Repository + Criteria (Data)** Repositório aceita `BookQuery`/`Specification` e aplica critérios no `DataSource` (local ou remoto), mantendo o domínio desacoplado do mecanismo.
-   **Debounce (Apresentação -- UX)** Técnica (não GoF) aplicada na camada de apresentação para otimizar digitação no campo de busca, reduzindo chamadas e evitando flicker.

## Trade-offs

-   **Não usei Provider/Riverpod**: optei por `get_it` + `ValueNotifier` para reduzir complexidade no escopo do desafio.
-   **Favoritos persistidos**: mantidos em `SharedPreferences`, simples e suficiente para o escopo. Futuramente pode evoluir para banco.
-   **Estilo visual minimalista**: segui uma UI clean, com espaços em branco, cards sem sombras (bordas claras), para focar na legibilidade.

## Evoluções de Arquitetura & State Management

Durante o desenvolvimento, foram feitas algumas adições importantes para tornar os ViewModels mais consistentes e escaláveis.

### ViewModelState
Alterei o tipo genérico para facilitar o gerenciamento do ciclo de vida do estado em qualquer ViewModel e View.

DE:
```dart
class ViewModelState<E, S> {
  ViewModelState(this._success, this._error);
  final S? _success;
  final E? _error;
}

class InitialState<E, S> extends ViewModelState<E, S> {
  InitialState() : super(null, null);
}

class LoadingState<E, S> extends ViewModelState<E, S> {
  LoadingState() : super(null, null);
}

class SuccessState<E, S> extends ViewModelState<E, S> {
  SuccessState(S success) : super(success, null);

  S get success => _success!;
}

class ErrorState<E, S> extends ViewModelState<E, S> {
  ErrorState(E error) : super(null, error);

  E get error => _error!;
}

```
PARA:
```dart
class ViewModelState<E, S> {
  bool get isInitial => this is InitialState<E, S>;
  bool get isLoading => this is LoadingState<E, S>;
  bool get isSuccess => this is SuccessState<E, S>;
  bool get isError   => this is ErrorState<E, S>;

  S? get successOrNull => this is SuccessState<E, S> 
      ? (this as SuccessState<E, S>).success 
      : null;

  E? get errorOrNull => this is ErrorState<E, S> 
      ? (this as ErrorState<E, S>).error 
      : null;

  T fold<T>({
    required T Function() onInitial,
    required T Function() onLoading,
    required T Function(S data) onSuccess,
    required T Function(E failure) onError,
  }) {
    if (isInitial) return onInitial();
    if (isLoading) return onLoading();
    if (isSuccess) return onSuccess((this as SuccessState<E, S>).success);
    return onError((this as ErrorState<E, S>).error);
  }
}

[...]
```


Benefícios:
- Clareza: estados explícitos (Initial, Loading, Success, Error).
- UI declarativa: via fold a tela sabe exatamente como renderizar cada caso.
- Reuso: qualquer ViewModel pode adotar sem duplicação.

### StateObject

Cada tela agora possui um StateObject (ex.: SearchStateObject, LibraryStateObject, HomeStateObject).

Esses objetos agrupam:
-	O estado principal (ViewModelState)
-	Dados persistentes ou derivados (ex.: filters, query, favorites)
-	Mapas de cache (byBookId) para informações externas

Exemplo (SearchStateObject simplificado):
```dart
class SearchStateObject {
  final ViewModelState<Failure, List<BookEntity>> state;
  final SearchFilters filters;
  final Set<String> favorites;
  final BookInfoById byBookId;

  const SearchStateObject({
    required this.state,
    required this.filters,
    required this.favorites,
    required this.byBookId,
  });

  factory SearchStateObject.initial() => SearchStateObject(
        state: InitialState(),
        filters: const SearchFilters(),
        favorites: {},
        byBookId: {},
      );

  SearchStateObject copyWith({
    ViewModelState<Failure, List<BookEntity>>? state,
    SearchFilters? filters,
    Set<String>? favorites,
    BookInfoById? byBookId,
  }) {
    return SearchStateObject(
      state: state ?? this.state,
      filters: filters ?? this.filters,
      favorites: favorites ?? this.favorites,
      byBookId: byBookId ?? this.byBookId,
    );
  }
}
```
Isso garante **Single Source of Truth** por tela.

### BaseViewModel

Todos os ViewModels agora herdam de BaseViewModel, que fornece:
- emit(UiEvent) -> disparar eventos efêmeros (snackbars, navegação)
- isDisposed -> previne setState após o dispose
- Lifecycle unificado para limpar recursos (dispose)

Exemplo no FavoritesViewModel:
```dart
class FavoritesViewModel extends BaseViewModel {
  final ValueNotifier<FavoritesStateObject> state =
      ValueNotifier(FavoritesStateObject.initial());

  Future<void> init() async {
    state.value = state.value.copyWith(state: LoadingState());
    final favs = await getFavoritesIds();
    favs.fold(
      (f) => emit(ShowErrorSnackBar(f.message)),
      (ids) => state.value = state.value.copyWith(favorites: ids),
    );
  }
}
```

Com essas padronizações, a UI e VM ficam extremamente simples aumentando a Testabilidade, Escalabilidade e deixando a UI mais Declarativa, diminuindo os IFs/ELSEs.

---

## Execução

``` bash
flutter pub get
flutter run
```

## Testes

-   Testes unitários de usecases
-   Testes unitários de datasources
-   Testes unitários de repositorios
-   Testes de viewmodels
-   Cobertura mínima em regras de negócio

## CI/CD

Pipeline configurado para:  
- rodar `flutter analyze` (sem warnings)  
- rodar `flutter test`  
- build do app (debug)


## Imagens

<div align="center">
    <img src="/images/1.png" width="400px"</img> 
    <img src="/images/2.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/3.png" width="400px"</img> 
    <img src="/images/4.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/5.png" width="400px"</img> 
    <img src="/images/6.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/7.png" width="400px"</img> 
    <img src="/images/8.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/9.png" width="400px"</img> 
    <img src="/images/10.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/11.png" width="400px"</img> 
    <img src="/images/12.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/13.png" width="400px"</img> 
    <img src="/images/14.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/15.png" width="400px"</img> 
    <img src="/images/16.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/17.png" width="400px"</img> 
    <img src="/images/18.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/19.png" width="400px"</img> 
    <img src="/images/20.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/21.png" width="400px"</img> 
    <img src="/images/22.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/23.png" width="400px"</img> 
    <img src="/images/24.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/25.png" width="400px"</img> 
    <img src="/images/26.png" width="400px"</img> 
</div>
<div align="center">
    <img src="/images/27.png" width="400px"</img> 
</div>


Feito com <3 usando o Flutter.

**Notas do Autor:** Chegou um momento que meu cerebro tava fritando, eu tinha várias ideias de outras coisas para adicionar e fazer, mas chega! kkkkkkkkkk ah, e sim, tem alguns livros q n tem foto... e eu n consegui resolver isso criando uma api pra trazer essas imagens a parte pq o tempo é curto meus amigos...

mas tá ai! muito bom o projeto eu gostei mt de fazer, tudo bem que torrou meus miolos mas isso é história para outro dia