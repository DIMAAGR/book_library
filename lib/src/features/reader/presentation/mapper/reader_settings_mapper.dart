import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/value_objects/font_size_object.dart';
import 'package:book_library/src/features/reader/domain/value_objects/line_height_object.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_state_object.dart';

class ReaderSettingsUiMapper {
  ReaderSettings toUi(ReaderSettingsEntity e) {
    final lh = switch (e.lineHeight) {
      LineHeightVO.compact => ReaderLineHeight.compact,
      LineHeightVO.comfortable => ReaderLineHeight.comfortable,
      LineHeightVO.spacious => ReaderLineHeight.spacious,
    };
    return ReaderSettings(fontSize: e.fontSize.value, lineHeight: lh);
  }

  ReaderSettingsEntity toEntity(ReaderSettings ui, ReaderSettingsEntity base) {
    final vo = switch (ui.lineHeight) {
      ReaderLineHeight.compact => LineHeightVO.compact,
      ReaderLineHeight.comfortable => LineHeightVO.comfortable,
      ReaderLineHeight.spacious => LineHeightVO.spacious,
    };
    return base.copyWith(fontSize: FontSizeVO(ui.fontSize), lineHeight: vo);
  }
}
