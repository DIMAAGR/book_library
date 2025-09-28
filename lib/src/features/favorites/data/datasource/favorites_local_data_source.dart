abstract class FavoritesLocalDataSource {
  Future<Set<String>> readIds();
  Future<void> writeIds(Set<String> ids);
}
