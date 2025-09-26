import 'package:flutter/widgets.dart';

abstract class AppTextStyles {
  static TextStyle get h4 => TextStyle(
    fontSize: 34,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
  );

  static TextStyle get h5 => TextStyle(
    fontSize: 24,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
  );

  static TextStyle get h6 => TextStyle(
    fontSize: 20,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w700,
  );

  static TextStyle get h6medium => TextStyle(
    fontSize: 20,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );

  static TextStyle get body1Regular => TextStyle(
    fontSize: 16,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  static TextStyle get body1Bold => TextStyle(
    fontSize: 16,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
  );

  static TextStyle get body2Regular => TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  static TextStyle get body2Bold => TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
  );

  static TextStyle get subtitle1Medium => TextStyle(
    fontSize: 16,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  static TextStyle get button => TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
  );
}
