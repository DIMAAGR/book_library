import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({required this.id, required this.name});
  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
