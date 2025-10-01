class FontSizeVO {
  const FontSizeVO(this.value) : assert(value >= 14 && value <= 26);
  final double value;
  FontSizeVO clamp() => FontSizeVO(value.clamp(14, 26).toDouble());
}
