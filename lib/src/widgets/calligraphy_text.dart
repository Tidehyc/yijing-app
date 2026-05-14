import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CalligraphyText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double? height;
  final String? fontFamily;

  const CalligraphyText(
    this.text, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.height,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: fontFamily ?? 'KaiTi',
        fontSize: fontSize ?? 16,
        color: color ?? AppColors.inkBlack,
        fontWeight: fontWeight ?? FontWeight.normal,
        letterSpacing: letterSpacing ?? 1.2,
        height: height ?? 1.8,
      ),
    );
  }
}
