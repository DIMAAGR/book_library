import 'package:book_library/src/features/reader/data/models/reader_settings_model.dart';

abstract class ReaderSettingsLocalDataSource {
  Future<ReaderSettingsModel?> read();
  Future<void> write(ReaderSettingsModel model);
}
