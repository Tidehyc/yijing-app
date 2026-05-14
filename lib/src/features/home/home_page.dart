import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_dimensions.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.inkBlack.withValues(alpha: 0.3),
                width: 2,
              ),
              color: AppColors.antiquePaperLight,
            ),
            child: Center(
              child: Text(
                '☯',
                style: TextStyle(
                  fontSize: 44,
                  color: AppColors.inkBlack.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CalligraphyText(
            AppStrings.appName,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
            letterSpacing: 8,
          ),
          const SizedBox(height: 6),
          const CalligraphyText(
            '六爻铜钱起卦',
            fontSize: 14,
            color: AppColors.inkGray,
            textAlign: TextAlign.center,
            letterSpacing: 4,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: AppDimensions.castButtonWidth,
            height: AppDimensions.castButtonHeight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/divination');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinnabarRed,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontFamily: 'KaiTi',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(AppStrings.startDivination),
            ),
          ),
          const SizedBox(height: 24),
          AntiqueCard(
            child: _MenuRow(
              icon: Icons.history,
              title: AppStrings.history,
              onTap: () {
                Navigator.of(context).pushNamed('/history');
              },
            ),
          ),
          const SizedBox(height: 8),
          AntiqueCard(
            child: _MenuRow(
              icon: Icons.settings,
              title: AppStrings.settings,
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ),
          const SizedBox(height: 32),
          const CalligraphyText(
            '天行健，君子以自强不息',
            fontSize: 12,
            color: AppColors.inkLight,
            textAlign: TextAlign.center,
            letterSpacing: 2,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.inkGray, size: AppDimensions.iconMedium),
          const SizedBox(width: 16),
          CalligraphyText(title, fontSize: 18),
          const Spacer(),
          Icon(Icons.chevron_right, color: AppColors.inkLight),
        ],
      ),
    );
  }
}
