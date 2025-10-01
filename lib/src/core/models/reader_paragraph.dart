import 'package:equatable/equatable.dart';

class ReaderParagraph extends Equatable {
  const ReaderParagraph({required this.title, required this.text});
  final String title;
  final String text;

  @override
  List<Object?> get props => [title, text];
}
