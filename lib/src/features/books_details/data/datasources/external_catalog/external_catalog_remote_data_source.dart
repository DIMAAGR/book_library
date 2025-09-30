abstract class ExternalCatalogRemoteDataSource {
  Future<Map<String, dynamic>> findByTitleAuthor({required String title, required String author});
}
