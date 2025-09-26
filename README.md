# 📚 BookList

Aplicativo Flutter desenvolvido como desafio técnico.\ O objetivo inicial era construir um app simples de gerenciamento de livros com listagem, busca, detalhes e favoritos.

## 🚀 Escopo do Teste

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

## 📱 Telas Adicionais

Além do que foi pedido, o projeto ganhou algumas telas para enriquecer a experiência: - **Onboarding** com ilustrações para introduzir o app - **Tela de leitura** com: - controle de fonte (`Aa`) - espaçamento entre linhas - tema claro/escuro/sépia - **Tela de explorador** (explore) com sugestões e filtros - **Tela de configurações**: - alternância de tema (light, dark, sepia) - ajustes básicos de preferências - **Empty states**: - Sem resultados de busca - Favoritos vazios - Sem conexão

## 🏗 Arquitetura

O projeto segue **Feature-First + MVVM + Clean Architecture**:

-   **Feature-First**: cada feature (ex.: `books`, `onboarding`, `settings`) é um módulo isolado com `domain`, `data` e `presentation`.
-   **MVVM**:
    -   **View**: UI pura, sem lógica
    -   **ViewModel**: orquestra casos de uso, expõe estados (`ValueNotifier`)
    -   **Model**: entidades de domínio
-   **Clean Architecture**:
    -   `domain` → contratos e regras de negócio
    -   `data` → implementações (API, cache, etc.)
    -   `presentation` → UI + viewmodels

🔑 **Regras de propriedade (Ownership):**\ Cada regra de negócio pertence à feature. Se várias telas precisam excluir um livro, todas chamam o mesmo `DeleteBookUseCase`. Isso garante **Single Source of Truth**.

## 🎨 Tema e Design System

O app usa uma camada central de theming em `core/theme`: - `AppColorsLight`, `AppColorsDark`, `AppColorsSepia` - `AppTextStyles` padronizado - `AppTheme` para gerar `ThemeData` - **ThemeController** (singleton) com `ValueNotifier` + `SharedPreferences` para persistir

Dessa forma, a UI acessa cores via:

``` dart
Theme.of(context).colors.textPrimary
```

sem acoplar valores hardcoded.

## 🛠 Decisões Técnicas

-   **get_it**:\ Escolhido para injeção de dependência por ser leve e direto. Evita boilerplate do Provider e dá controle manual sobre ciclo de vida.
-   **ValueNotifier / ChangeNotifier**:\ Para estados simples (ex.: tema, loading, listas), `ValueNotifier` é suficiente. É mais performático e menos verboso que streams ou bloc em casos pequenos.\ Usei `ChangeNotifier` apenas onde há múltiplos estados observáveis.
-   **SharedPreferences**:\ Persistência simples para manter tema e favoritos. Abstraído via `KeyValueWrapper` para facilitar troca no futuro.
-   **go_router**:\ Navegação declarativa, mais simples de escalar que `Navigator.push`.
-   **dartz (Either)**:\ Para tratamento de erros funcional e explícito (ex.: `Either<Failure, Book>`), evitando exceções escondidas.

## 📦 Pacotes Utilizados

-   [get_it](https://pub.dev/packages/get_it) → injeção de dependência
-   [shared_preferences](https://pub.dev/packages/shared_preferences) -> persistência leve
-   [go_router](https://pub.dev/packages/go_router) -> navegação
-   [dartz](https://pub.dev/packages/dartz) -> monads (`Either`) para erros
-   [intl](https://pub.dev/packages/intl) -> formatação de datas
-   [mask_text_input_formatter](https://pub.dev/packages/mask_text_input_formatter) -> formatação de inputs

## 🧩 Design Patterns adotados

-   **MVVM (Presentation)**\ ViewModels orquestram Casos de Uso e expõem estado imutável para a View (via `ValueNotifier`/`ViewModelState`). A View não contém regra de negócio, apenas renderiza e delega intenção.
-   **Clean Architecture**\ Domínio (contratos/regras) isolado de Data (SDK/IO) via **Repository Pattern**. `domain` define interfaces; `data` implementa; `presentation` orquestra.
-   **Factory (Domínio)**\ Construção de entidades garantindo invariantes (ex.: `SavedBooks.add(...)` valida e retorna `Either<Failure, Entity>`).
-   **Mapper (Data)**\ Conversão **DTO ↔ Entity** isolada (mapeadores/`Model.toEntity()`), evitando "vazamento" de serialização para o domínio.
-   **Strategy (Domínio)**\ Filtros e ordenações como estratégias pluggáveis (ex.: `SortByNewest`, `SortByAZ`, `FilterByRating`), permitindo combinar políticas sem duplicação.
-   **Adapter (Infra/DataSource)**\ Encapsula SDKs e serviços (ex.: HTTP client, SharedPreferences) atrás de interfaces estáveis, trocáveis em testes.
-   **Value Object (Domínio)**\ Tipos com validação embutida para valores (ex.: `BookTitle`, `PublishedYear`), reduzindo estados inválidos.
-   **State (Presentation)**\ Estados explícitos do ViewModel (`Initial/Loading/Success/Error`) para clareza de fluxo e UI previsível.
-   **Railway-Oriented / Error as Data**\ Uso de `Dartz.Either<Failure, T>` para encadear operações de forma segura e previsível, sem exceptions "silenciosas".
-   **Repository + Cache (Data)**\ O `FavoritesRepository` abstrai o mecanismo de persistência.\ Atualmente usa `SharedPreferences` via `KeyValueWrapper`, mas pode evoluir para Hive/SQLite sem impacto no domínio.\ Isso aplica o princípio de **Dependency Inversion**.

### 🔎 Padrões para Pesquisa

-   **Specification (Domínio)**\ Predicados de busca (ex.: `TitleContains(query)`) modelados como especificações combináveis (`and/or`), mantendo regra de filtro no domínio.
-   **Query Object (Domínio/Aplicação)**\ Objeto que encapsula parâmetros de busca/ordenação/paginação (ex.: `BookQuery { title, sort, ratingMin, language }`) passado ao caso de uso/repositório. Facilita testes e evolução da API.
-   **Repository + Criteria (Data)**\ Repositório aceita `BookQuery`/`Specification` e aplica critérios no `DataSource` (local ou remoto), mantendo o domínio desacoplado do mecanismo.
-   **Debounce (Apresentação -- UX)**\ Técnica (não GoF) aplicada na camada de apresentação para otimizar digitação no campo de busca, reduzindo chamadas e evitando flicker.

## ⚖️ Trade-offs

-   **Não usei Provider/Riverpod**: optei por `get_it` + `ValueNotifier` para reduzir complexidade no escopo do desafio.
-   **Favoritos persistidos**: mantidos em `SharedPreferences`, simples e suficiente para o escopo. Futuramente pode evoluir para banco.
-   **Sem persistência offline dos livros**: dado que a API é fictícia, cache local foi considerado fora do escopo.
-   **Estilo visual minimalista**: segui uma UI clean, com espaços em branco, cards sem sombras (bordas claras), para focar na legibilidade.

## ▶️ Execução

``` bash
flutter pub get
flutter run
```

## ✅ Testes

-   Testes unitários de usecases
-   Testes de viewmodels
-   Cobertura mínima em regras de negócio

## 🔄 CI/CD

Pipeline configurado para: - rodar `flutter analyze` (sem warnings) -  rodar `flutter test` - build do app (debug)
