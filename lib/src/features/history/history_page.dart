import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../database/database_helper.dart';
import '../../utils/hexagram_lookup.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';

class HistoryListPage extends ConsumerStatefulWidget {
  const HistoryListPage({super.key});

  @override
  ConsumerState<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends ConsumerState<HistoryListPage> {
  String _filter = 'all';
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);
    await db.database;

    String? filterParam;
    if (_filter != 'all') filterParam = _filter;

    final records = await db.divinationDao.getRecords(
      limit: 100,
      filter: filterParam,
    );

    setState(() {
      _records = records;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.antiquePaper,
      appBar: AppBar(title: const Text('历史记录')),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('all', '全部'),
          const SizedBox(width: 8),
          _buildFilterChip('today', '今日'),
          const SizedBox(width: 8),
          _buildFilterChip('week', '本周'),
          const SizedBox(width: 8),
          _buildFilterChip('month', '本月'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = value);
        _loadRecords();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.cinnabarRed : AppColors.antiquePaperDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'KaiTi',
            fontSize: 14,
            color: selected ? Colors.white : AppColors.inkGray,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.cinnabarRed));
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('☯', style: TextStyle(fontSize: 48, color: AppColors.inkBlack.withValues(alpha: 0.3))),
            const SizedBox(height: 16),
            const CalligraphyText('尚无起卦记录', fontSize: 16, color: AppColors.inkLight),
            const SizedBox(height: 8),
            const CalligraphyText('开始你的第一次起卦吧', fontSize: 14, color: AppColors.inkLight),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _records.length,
      itemBuilder: (context, index) => _buildRecordItem(_records[index]),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record) {
    final hexId = record['original_hexagram_id'] as int;
    final changingId = record['changing_hexagram_id'] as int?;
    final name = hexagramNames[hexId] ?? '?';
    final changingName = changingId != null ? hexagramNames[changingId] : null;
    final question = record['question'] as String?;
    final createdAt = record['created_at'] as String? ?? '';
    final dateStr = _formatDate(createdAt);
    final notes = record['notes'] as String?;

    return AntiqueCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.of(context).pushNamed(
          '/record_detail',
          arguments: record['id'] as int,
        ).then((_) => _loadRecords());
      },
      child: Row(
        children: [
          // 卦象缩略
          Container(
            width: 48,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.antiquePaperDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.silkBeige),
            ),
            child: Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'KaiTi',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkBlack,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CalligraphyText(
                      name,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    if (changingName != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 14, color: AppColors.cinnabarRed),
                      const SizedBox(width: 4),
                      CalligraphyText(
                        changingName,
                        fontSize: 16,
                        color: AppColors.cinnabarRed,
                      ),
                    ],
                  ],
                ),
                if (question != null && question.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  CalligraphyText(
                    question,
                    fontSize: 14,
                    color: AppColors.inkGray,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    CalligraphyText(dateStr, fontSize: 12, color: AppColors.inkLight),
                    if (notes != null && notes.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.note, size: 14, color: AppColors.cinnabarRed.withValues(alpha: 0.5)),
                    ],
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.inkLight),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoStr) {
    try {
      final dt = DateTime.parse(isoStr);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoStr;
    }
  }
}
