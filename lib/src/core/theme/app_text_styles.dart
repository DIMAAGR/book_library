import 'package:flutter/widgets.dart';

abstract class AppTextStyles {
  static TextStyle get h4 =>
      const TextStyle(fontSize: 34, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);

  static TextStyle get h5 =>
      const TextStyle(fontSize: 24, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);

  static TextStyle get h6 =>
      const TextStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);

  static TextStyle get h6medium =>
      const TextStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);

  static TextStyle get body1Regular =>
      const TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.w400);

  static TextStyle get body1Bold =>
      const TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.w700);

  static TextStyle get body2Regular =>
      const TextStyle(fontSize: 14, fontFamily: 'Roboto', fontWeight: FontWeight.w400);

  static TextStyle get body2Bold =>
      const TextStyle(fontSize: 14, fontFamily: 'Roboto', fontWeight: FontWeight.w700);

  static TextStyle get body3Regular =>
      const TextStyle(fontSize: 12, fontFamily: 'Roboto', fontWeight: FontWeight.w400);

  static TextStyle get body3Bold =>
      const TextStyle(fontSize: 12, fontFamily: 'Roboto', fontWeight: FontWeight.w700);

  static TextStyle get body4Regular =>
      const TextStyle(fontSize: 10, fontFamily: 'Roboto', fontWeight: FontWeight.w400);

  static TextStyle get body4Bold =>
      const TextStyle(fontSize: 10, fontFamily: 'Roboto', fontWeight: FontWeight.w700);

  static TextStyle get subtitle1Medium =>
      const TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.w600);

  static TextStyle get subtitle2Medium =>
      const TextStyle(fontSize: 14, fontFamily: 'Roboto', fontWeight: FontWeight.w600);

  static TextStyle get caption =>
      const TextStyle(fontSize: 12, fontFamily: 'Roboto', fontWeight: FontWeight.w400);

  static TextStyle get caption2 =>
      const TextStyle(fontSize: 10, fontFamily: 'Roboto', fontWeight: FontWeight.w400);

  static TextStyle get captionBold =>
      const TextStyle(fontSize: 12, fontFamily: 'Roboto', fontWeight: FontWeight.w700);

  static TextStyle get button =>
      const TextStyle(fontSize: 14, fontFamily: 'Roboto', fontWeight: FontWeight.w500);
}
