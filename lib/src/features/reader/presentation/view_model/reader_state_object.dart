import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/models/reader_paragraph.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:equatable/equatable.dart';

enum ReaderLineHeight { compact, comfortable, spacious }

enum ReaderPanel { none, fontSize, lineHeight, themeMode }

class ReaderSettings extends Equatable {
  const ReaderSettings({this.fontSize = 18.0, this.lineHeight = ReaderLineHeight.comfortable});
  final double fontSize;
  final ReaderLineHeight lineHeight;

  ReaderSettings copyWith({
    double? fontSize,
    ReaderLineHeight? lineHeight,
    ReaderPanel? openPanel,
  }) => ReaderSettings(
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
  );

  @override
  List<Object?> get props => [fontSize, lineHeight];
}

class ReaderPayload extends Equatable {
  const ReaderPayload({required this.book, required this.paragraphs});
  final BookEntity book;
  final List<ReaderParagraph> paragraphs;

  @override
  List<Object?> get props => [book, paragraphs];
}

class ReaderStateObject extends Equatable {
  factory ReaderStateObject.initial() => ReaderStateObject(
    isFavorite: false,
    openPanel: ReaderPanel.none,
    state: InitialState<Failure, ReaderPayload>(),
    settings: const ReaderSettings(),
    currentPage: 1,
    totalPages: 1,
    progress: 0,
  );

  const ReaderStateObject({
    required this.state,
    required this.settings,
    required this.currentPage,
    required this.totalPages,
    required this.isFavorite,
    required this.progress,
    required this.openPanel,
  });

  final ViewModelState<Failure, ReaderPayload> state;
  final ReaderSettings settings;
  final int currentPage;
  final int totalPages;
  final int progress;
  final ReaderPanel openPanel;
  final bool isFavorite;

  ReaderStateObject copyWith({
    ViewModelState<Failure, ReaderPayload>? state,
    ReaderSettings? settings,
    int? currentPage,
    bool? isFavorite,
    int? totalPages,
    ReaderPanel? openPanel,
    int? progress,
  }) {
    return ReaderStateObject(
      isFavorite: isFavorite ?? this.isFavorite,
      openPanel: openPanel ?? this.openPanel,
      state: state ?? this.state,
      settings: settings ?? this.settings,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
    state,
    settings,
    currentPage,
    totalPages,
    progress,
    openPanel,
    isFavorite,
  ];
}
