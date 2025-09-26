import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

abstract class TextInputDateFormatter {
  static final dateMask = MaskTextInputFormatter(mask: '##/##/####');
  static final timeMask = MaskTextInputFormatter(mask: '##:##');
}
