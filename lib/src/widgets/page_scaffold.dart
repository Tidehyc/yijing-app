import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class PageScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool showBackground;

  const PageScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.antiquePaper,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: showBackground
            ? const BoxDecoration(
                color: AppColors.antiquePaper,
              )
            : null,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
