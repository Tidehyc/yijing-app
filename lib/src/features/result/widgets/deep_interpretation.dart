import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/antique_card.dart';
import '../../../widgets/calligraphy_text.dart';

class DeepInterpretation extends StatelessWidget {
  final Map<String, dynamic> hexagramData;
  final List<Map<String, dynamic>> lineTexts;
  final List<int> changingLinePositions;

  const DeepInterpretation({
    super.key,
    required this.hexagramData,
    required this.lineTexts,
    required this.changingLinePositions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSection('卦辞', hexagramData['judgment'] as String?,
            hexagramData['judgment_vernacular'] as String?),
        _buildSection('彖传', hexagramData['tuan_zhuan'] as String?,
            hexagramData['tuan_zhuan_vernacular'] as String?),
        _buildSection('象传', hexagramData['xiang_zhuan'] as String?,
            hexagramData['xiang_zhuan_vernacular'] as String?),
        _buildLineSection(),
      ],
    );
  }

  Widget _buildSection(String title, String? classical, String? vernacular) {
    if ((classical == null || classical.isEmpty) &&
        (vernacular == null || vernacular.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _CollapsibleSection(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (classical != null && classical.isNotEmpty)
              CalligraphyText(
                classical,
                fontSize: 16,
                fontFamily: 'KaiTi',
                letterSpacing: 2.0,
              ),
            if (vernacular != null && vernacular.isNotEmpty) ...[
              const SizedBox(height: 8),
              CalligraphyText(
                vernacular,
                fontSize: 14,
                fontFamily: 'FangSong',
                color: AppColors.inkGray,
                height: 1.8,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLineSection() {
    if (lineTexts.isEmpty) return const SizedBox.shrink();

    final relevantLines = changingLinePositions.isEmpty
        ? lineTexts
        : lineTexts.where((l) => changingLinePositions.contains(l['line_number'])).toList();

    return _CollapsibleSection(
      title: '爻辞${changingLinePositions.isNotEmpty ? '（动爻）' : ''}',
      initiallyExpanded: changingLinePositions.isNotEmpty,
      child: Column(
        children: relevantLines.map((line) {
          final isChanging = changingLinePositions.contains(line['line_number']);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isChanging
                  ? AppColors.cinnabarLight.withValues(alpha: 0.15)
                  : AppColors.antiquePaperDark,
              borderRadius: BorderRadius.circular(8),
              border: isChanging
                  ? Border.all(color: AppColors.cinnabarRed.withValues(alpha: 0.3))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CalligraphyText(
                      line['line_name'] as String? ?? '',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isChanging ? AppColors.cinnabarRed : AppColors.inkBlack,
                    ),
                    if (isChanging) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.cinnabarRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('动', style: TextStyle(
                          fontFamily: 'KaiTi', fontSize: 10, color: AppColors.cinnabarRed,
                        )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                CalligraphyText(
                  line['line_text'] as String? ?? '',
                  fontSize: 15,
                  letterSpacing: 1.5,
                  fontFamily: 'KaiTi',
                ),
                if ((line['line_text_vernacular'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  CalligraphyText(
                    line['line_text_vernacular'] as String,
                    fontSize: 13,
                    fontFamily: 'FangSong',
                    color: AppColors.inkGray,
                    height: 1.6,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _CollapsibleSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return AntiqueCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.cinnabarRed,
                ),
                const SizedBox(width: 8),
                CalligraphyText(widget.title, fontSize: 16, fontWeight: FontWeight.bold),
                const Spacer(),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            widget.child,
          ],
        ],
      ),
    );
  }
}
