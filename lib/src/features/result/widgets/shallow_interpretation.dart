import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/antique_card.dart';
import '../../../widgets/calligraphy_text.dart';

class ShallowInterpretation extends StatelessWidget {
  final String text;
  final List<int> changingLines;
  final List<Map<String, dynamic>> lineTexts;

  const ShallowInterpretation({
    super.key,
    required this.text,
    required this.changingLines,
    required this.lineTexts,
  });

  @override
  Widget build(BuildContext context) {
    return AntiqueCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.coinGold, size: 20),
              const SizedBox(width: 8),
              const CalligraphyText('浅解', fontSize: 18, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 12),
          CalligraphyText(text, fontSize: 15, height: 2.0),
          if (changingLines.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.silkBeige),
            const SizedBox(height: 12),
            const CalligraphyText('动爻提示', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cinnabarRed),
            const SizedBox(height: 8),
            ...changingLines.map((pos) {
              final lineText = lineTexts.where((l) => l['line_number'] == pos).firstOrNull;
              if (lineText == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CalligraphyText(
                  '${lineText['line_name']}: ${lineText['changing_meaning'] ?? lineText['line_text_vernacular'] ?? ''}',
                  fontSize: 14,
                  height: 1.8,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
