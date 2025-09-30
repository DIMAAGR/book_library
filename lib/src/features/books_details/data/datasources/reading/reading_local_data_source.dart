abstract class ReadingLocalDataSource {
  Future<bool> isReading(String id);
  Future<bool> toggleReading(String id);
  Future<int> getProgress(String id);
  Future<void> setProgress(String id, int percent);
}
