import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.themeTextStyle,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.height,
  });

  final String text;
  final TextStyle? style;
  final TextStyle? themeTextStyle;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        themeTextStyle ??
        Theme.of(context).textTheme.bodyLarge ??
        const TextStyle();

    final finalStyle = baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? baseStyle.color,
      letterSpacing: letterSpacing,
      height: height,
    );

    return Text(
      text,
      style: style ?? finalStyle,
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
