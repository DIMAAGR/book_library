import 'package:book_library/src/core/services/key/canonical_key_strategy.dart';

class DefaultCanonicalKey implements CanonicalKeyStrategy {
  String _norm(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  @override
  String call(String title, String author) => '${_norm(title)}|${_norm(author)}';
}
