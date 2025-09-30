import 'dart:async';

import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/views/offiline_view.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_app_bar.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_button.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_card.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/presentation/view_model/books_details_state_object.dart';
import 'package:book_library/src/features/books_details/presentation/view_model/books_details_view_model.dart';
import 'package:book_library/src/features/books_details/presentation/widgets/book_details_skeleton.dart';
import 'package:book_library/src/features/books_details/presentation/widgets/info_content.dart';
import 'package:book_library/src/features/books_details/presentation/widgets/like_button.dart';
import 'package:book_library/src/features/books_details/presentation/widgets/rating_block.dart';
import 'package:flutter/material.dart';

class BookDetailsView extends StatefulWidget {
  const BookDetailsView({super.key, required this.viewModel, required this.book});
  final BookEntity book;
  final BookDetailsViewModel viewModel;

  @override
  State<BookDetailsView> createState() => _BookDetailsViewState();
}

class _BookDetailsViewState extends State<BookDetailsView> {
  BookDetailsViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.init(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Scaffold(
      appBar: BookLibraryAppBar(
        title: 'Details',
        onSharePressed: () {
          final book = viewModel.state.value.book.successOrNull;
          if (book != null) {
            viewModel.shareCurrent();
          }
        },
        showShare: true,
      ),
      body: ValueListenableBuilder<BookDetailsStateObject>(
        valueListenable: viewModel.state,
        builder: (_, state, __) {
          return state.state.fold(
            onInitial: () => const BookDetailsSkeleton(),
            onLoading: () => const BookDetailsSkeleton(),
            onError: (f) => OfflineView(
              onRetry: () => viewModel.init(state.book.successOrNull!),
              onOpenSettings: () {},
            ),
            onSuccess: (payload) {
              final BookEntity book = payload.book;
              final ExternalBookInfoEntity? info = payload.info;

              // SIM AMIGOS, ISSO AQUI É MOCK
              // PORQUE A API NÃO TEM ESSES DADOS
              // ENTÃO SÓ PARA FICAR BONITINHO NO DESIGN
              // DEPOIS TEM QUE TIRAR ISSO AQUI
              final rating = 4.6;
              final reviews = '1.2k';
              final chapters = '24';
              final lang = 'EN';

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    BookCard(
                      book: book,
                      info: info,
                      showPercentage: false,
                      showStars: false,
                      disableTap: true,
                      showTitleAndAuthor: false,
                    ),
                    const SizedBox(height: 16),

                    Text(book.title, style: AppTextStyles.h5, textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      style: AppTextStyles.body1Regular.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${book.published?.year ?? '—'} • ${book.publisher ?? '—'}',
                      style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    state.isReading
                        ? RatingBlock(avg: rating, reviewsLabel: reviews)
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                InfoContent(
                                  leading: Icon(
                                    Icons.star_rounded,
                                    size: 18,
                                    color: colors.textSecondary,
                                  ),
                                  value: rating.toStringAsFixed(1),
                                  label: 'Rating',
                                ),
                                const SizedBox(width: 12),
                                InfoContent(value: reviews, label: 'Reviews'),
                                const SizedBox(width: 12),
                                InfoContent(value: chapters, label: 'Chapters'),
                                const SizedBox(width: 12),
                                InfoContent(value: lang, label: 'Language'),
                              ],
                            ),
                          ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: BookLibraryButton(
                            borderRadius: BorderRadius.circular(12),
                            onPressed: viewModel.toggleReading,
                            text: state.isReading ? 'Continue Reading' : 'Start Reading',
                            textStyle: AppTextStyles.subtitle1Medium.copyWith(
                              color: colors.textLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        LikeButton(
                          isFavorited: state.isFavorite,
                          onPressed: viewModel.toggleFavorite,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("What's it about?", style: AppTextStyles.body1Bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (info?.description?.isNotEmpty ?? false)
                          ? info!.description!
                          : 'No description available for this book.',
                      style: AppTextStyles.body2Regular,
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('You might also like', style: AppTextStyles.body1Bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 280,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.similar.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),

                        itemBuilder: (_, i) {
                          final book = state.similar[i];
                          if (!viewModel.hasInfoFor(book.id)) {
                            scheduleMicrotask(() => viewModel.resolveFor(book));
                          }

                          final info = state.byBookId[book.id];
                          return BookCard.compact(
                            book: book,
                            info: info,
                            disableTap: false,
                            showPercentage: false,
                            showStars: false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
