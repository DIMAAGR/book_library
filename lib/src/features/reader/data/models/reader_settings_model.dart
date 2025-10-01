import 'package:equatable/equatable.dart';

class ReaderSettingsModel extends Equatable {
  factory ReaderSettingsModel.fromJson(Map<String, dynamic> json) => ReaderSettingsModel(
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18,
    lineHeight: (json['lineHeight'] as String?) ?? 'comfortable',
  );
  const ReaderSettingsModel({required this.fontSize, required this.lineHeight});
  final double fontSize;
  final String lineHeight;

  Map<String, dynamic> toJson() => {'fontSize': fontSize, 'lineHeight': lineHeight};

  @override
  List<Object?> get props => [fontSize, lineHeight];
}
