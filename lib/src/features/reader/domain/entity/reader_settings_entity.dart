import 'package:book_library/src/features/reader/domain/value_objects/font_size_object.dart';
import 'package:book_library/src/features/reader/domain/value_objects/line_height_object.dart';
import 'package:equatable/equatable.dart';

class ReaderSettingsEntity extends Equatable {
  const ReaderSettingsEntity({
    this.fontSize = const FontSizeVO(18),
    this.lineHeight = LineHeightVO.comfortable,
  });

  final FontSizeVO fontSize;
  final LineHeightVO lineHeight;

  ReaderSettingsEntity copyWith({FontSizeVO? fontSize, LineHeightVO? lineHeight}) =>
      ReaderSettingsEntity(
        fontSize: (fontSize ?? this.fontSize).clamp(),
        lineHeight: lineHeight ?? this.lineHeight,
      );

  @override
  List<Object?> get props => [fontSize.value, lineHeight];
}
