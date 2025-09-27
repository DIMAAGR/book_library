import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    this.publisher,
    this.published,
  });

  final String id;
  final String title;
  final String author;
  final DateTime? published;
  final String? publisher;

  @override
  List<Object?> get props => [id, title, author, published, publisher];
}
