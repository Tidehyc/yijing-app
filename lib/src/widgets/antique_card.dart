import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AntiqueCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;
  final VoidCallback? onTap;

  const AntiqueCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? AppColors.antiquePaperLight,
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(
          color: AppColors.silkBeige.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
          child: child,
        ),
      ),
    );
  }
}
