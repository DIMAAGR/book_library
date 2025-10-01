import 'package:book_library/src/features/reader/data/models/reader_settings_model.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/value_objects/font_size_object.dart';
import 'package:book_library/src/features/reader/domain/value_objects/line_height_object.dart';

abstract class ReaderSettingsMapper {
  static ReaderSettingsEntity toEntity(ReaderSettingsModel m) {
    final lh = LineHeightVO.values.firstWhere(
      (e) => e.name == m.lineHeight,
      orElse: () => LineHeightVO.comfortable,
    );
    return ReaderSettingsEntity(fontSize: FontSizeVO(m.fontSize), lineHeight: lh);
  }

  static ReaderSettingsModel toModel(ReaderSettingsEntity e) =>
      ReaderSettingsModel(fontSize: e.fontSize.value, lineHeight: e.lineHeight.name);
}
