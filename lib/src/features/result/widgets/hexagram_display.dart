import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/line_data.dart';
import '../../../utils/hexagram_painter.dart';

class HexagramDisplay extends StatelessWidget {
  final List<LineData> lines;
  final List<int> changingPositions;
  final double animationProgress;

  const HexagramDisplay({
    super.key,
    required this.lines,
    required this.changingPositions,
    this.animationProgress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.antiquePaperLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.silkBeige.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            '本卦',
            style: TextStyle(
              fontFamily: 'KaiTi',
              fontSize: 14,
              color: AppColors.inkGray,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: CustomPaint(
                size: Size.infinite,
                painter: HexagramLinePainter(
                  lines: lines,
                  showChangingMarks: true,
                  animationProgress: animationProgress,
                ),
              ),
            ),
          ),
          // 爻位标注
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final pos in changingPositions)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cinnabarLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pos爻动',
                      style: const TextStyle(
                        fontFamily: 'KaiTi',
                        fontSize: 11,
                        color: AppColors.cinnabarRed,
                      ),
                    ),
                  ),
                if (changingPositions.isEmpty)
                  const Text(
                    '静卦',
                    style: TextStyle(
                      fontFamily: 'KaiTi',
                      fontSize: 11,
                      color: AppColors.inkLight,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
