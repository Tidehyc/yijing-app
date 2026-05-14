import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../database/database_helper.dart';
import '../../../widgets/antique_card.dart';
import '../../../widgets/calligraphy_text.dart';

class CaseReferenceCard extends ConsumerStatefulWidget {
  final int hexagramId;

  const CaseReferenceCard({super.key, required this.hexagramId});

  @override
  ConsumerState<CaseReferenceCard> createState() => _CaseReferenceCardState();
}

class _CaseReferenceCardState extends ConsumerState<CaseReferenceCard> {
  bool _showAncient = true;
  List<Map<String, dynamic>> _ancientCases = [];
  List<Map<String, dynamic>> _modernCases = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final db = ref.read(databaseProvider);
    await db.database;

    final ancient = await db.hexagramDao.getCases(widget.hexagramId, 'ancient');
    final modern = await db.hexagramDao.getCases(widget.hexagramId, 'modern');

    setState(() {
      _ancientCases = ancient;
      _modernCases = modern;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    final allCases = _showAncient ? _ancientCases : _modernCases;
    if (allCases.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.menu_book, color: AppColors.inkGray, size: 20),
            const SizedBox(width: 8),
            const CalligraphyText('案例参考', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        const SizedBox(height: 8),
        // 切换按钮
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.antiquePaperDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildTypeTab(true, '古代'),
              _buildTypeTab(false, '现代'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...allCases.map((c) => _buildCaseItem(c)),
      ],
    );
  }

  Widget _buildTypeTab(bool isAncient, String label) {
    final selected = _showAncient == isAncient;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showAncient = isAncient),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.cinnabarRed : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'KaiTi',
              fontSize: 14,
              color: selected ? Colors.white : AppColors.inkGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaseItem(Map<String, dynamic> caseData) {
    return AntiqueCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalligraphyText(
            caseData['title'] as String? ?? '',
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          CalligraphyText(
            caseData['source'] as String? ?? '',
            fontSize: 12,
            color: AppColors.inkLight,
          ),
          const SizedBox(height: 8),
          CalligraphyText(
            caseData['narrative'] as String? ?? '',
            fontSize: 14,
            fontFamily: 'FangSong',
            height: 1.8,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.antiquePaperDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CalligraphyText(
              caseData['analysis'] as String? ?? '',
              fontSize: 13,
              fontFamily: 'FangSong',
              color: AppColors.inkGray,
              height: 1.6,
            ),
          ),
          if (caseData['relevance'] != null) ...[
            const SizedBox(height: 8),
            CalligraphyText(
              '现代启示: ${caseData['relevance']}',
              fontSize: 13,
              color: AppColors.cinnabarRed,
              height: 1.6,
            ),
          ],
        ],
      ),
    );
  }
}
