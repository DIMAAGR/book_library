
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
