import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/antique_card.dart';
import '../../../widgets/calligraphy_text.dart';

class HexagramInfo extends StatelessWidget {
  final Map<String, dynamic> hexagramData;
  final Map<String, dynamic>? changingHexagramData;
  final List<int> changingLinePositions;

  const HexagramInfo({
    super.key,
    required this.hexagramData,
    this.changingHexagramData,
    required this.changingLinePositions,
  });

  @override
  Widget build(BuildContext context) {
    final name = hexagramData['name_zh'] as String? ?? '';
    final pinyin = hexagramData['name_pinyin'] as String? ?? '';
    final palace = hexagramData['palace'] as String? ?? '';
    final wuxing = hexagramData['wuxing'] as String? ?? '';
    final upper = hexagramData['upper_trigram'] as String? ?? '';
    final lower = hexagramData['lower_trigram'] as String? ?? '';

    return AntiqueCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 卦名
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CalligraphyText(name, fontSize: 36, fontWeight: FontWeight.bold),
              if (changingHexagramData != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: AppColors.cinnabarRed, size: 24),
                const SizedBox(width: 8),
                CalligraphyText(
                  changingHexagramData!['name_zh'] as String? ?? '',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cinnabarRed,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          CalligraphyText(
            '$pinyin${changingHexagramData != null ? ' → ${changingHexagramData!['name_pinyin']}' : ''}',
            fontSize: 14,
            color: AppColors.inkGray,
          ),
          const SizedBox(height: 16),
          // 卦象属性
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTag('$upper上 $lower下'),
              const SizedBox(width: 8),
              _buildTag(palace),
              const SizedBox(width: 8),
              _buildTag(wuxing),
            ],
          ),
          if (changingLinePositions.isNotEmpty) ...[
            const SizedBox(height: 12),
            CalligraphyText(
              '动爻: ${changingLinePositions.map((p) => "第$p 爻").join("、")}',
              fontSize: 14,
              color: AppColors.cinnabarRed,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.antiquePaperDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CalligraphyText(text, fontSize: 13, color: AppColors.inkGray),
    );
  }
}
