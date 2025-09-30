import 'package:equatable/equatable.dart';

class ExternalBookInfoEntity extends Equatable {
  const ExternalBookInfoEntity({required this.title, this.description, this.coverUrl, this.isbn13});
  final String title;
  final String? description;
  final String? coverUrl;
  final String? isbn13;

  @override
  List<Object?> get props => [title, description, coverUrl, isbn13];
}
