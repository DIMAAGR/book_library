import 'package:book_library/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension(this.colors);
  final AppColors colors;

  @override
  AppColorsExtension copyWith({AppColors? colors}) => AppColorsExtension(colors ?? this.colors);

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) =>
      other ?? this;
}

extension ColorsX on ThemeData {
  AppColors get colors => extension<AppColorsExtension>()!.colors;
}
