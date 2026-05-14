import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../database/database_helper.dart';
import '../../utils/hexagram_lookup.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';

class RecordDetailPage extends ConsumerStatefulWidget {
  final int? recordId;

  const RecordDetailPage({super.key, this.recordId});

  @override
  ConsumerState<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends ConsumerState<RecordDetailPage> {
  Map<String, dynamic>? _record;
  bool _loading = true;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.recordId == null) return;

    final db = ref.read(databaseProvider);
    await db.database;

    final record = await db.divinationDao.getRecordById(widget.recordId!);
    if (record == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() {
      _record = record;
      _notesController.text = record['notes'] as String? ?? '';
      _questionController.text = record['question'] as String? ?? '';
      _loading = false;
    });
  }

  Future<void> _saveNotes() async {
    if (widget.recordId == null) return;
    final db = ref.read(databaseProvider);
    await db.database;
    await db.divinationDao.updateNotes(widget.recordId!, _notesController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('备注已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _saveQuestion() async {
    if (widget.recordId == null) return;
    final db = ref.read(databaseProvider);
    await db.database;
    await db.divinationDao.updateQuestion(widget.recordId!, _questionController.text);
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.antiquePaperLight,
        title: const CalligraphyText('确认删除', fontSize: 18, fontWeight: FontWeight.bold),
        content: const CalligraphyText('此记录将被永久删除，无法恢复。', color: AppColors.inkGray),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const CalligraphyText('取消', color: AppColors.inkGray),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const CalligraphyText('删除', color: AppColors.cinnabarRed),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.recordId != null) {
      final db = ref.read(databaseProvider);
      await db.database;
      await db.divinationDao.permanentDelete(widget.recordId!);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.antiquePaper,
        appBar: AppBar(title: const Text('记录详情')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.cinnabarRed)),
      );
    }

    final hexName = hexagramNames[_record!['original_hexagram_id']] ?? '?';
    final changingName = _record!['changing_hexagram_id'] != null
        ? hexagramNames[_record!['changing_hexagram_id']] ?? '?'
        : null;
    final dateStr = _formatDate(_record!['created_at'] as String? ?? '');
    final castSeq = (_record!['cast_sequence'] as String?)?.split(',').map(int.parse).toList() ?? [];
    final changingPos = (_record!['changing_line_positions'] as String?)?.isNotEmpty == true
        ? (_record!['changing_line_positions'] as String).split(',').map(int.parse).toList()
        : <int>[];

    final lineNames = ['初', '二', '三', '四', '五', '上'];

    return Scaffold(
      backgroundColor: AppColors.antiquePaper,
      appBar: AppBar(
        title: Text(changingName != null ? '$hexName → $changingName' : hexName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.cinnabarRed),
            onPressed: _deleteRecord,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 日期信息
              AntiqueCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CalligraphyText(dateStr, fontSize: 16, fontWeight: FontWeight.bold),
                    if (_record!['lunar_date'] != null) ...[
                      const SizedBox(height: 4),
                      CalligraphyText(
                        _record!['lunar_date'] as String,
                        fontSize: 14,
                        color: AppColors.inkGray,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 占问事项
              AntiqueCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CalligraphyText('占问事项', fontSize: 14, color: AppColors.inkGray),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _questionController,
                      style: const TextStyle(
                        fontFamily: 'KaiTi', fontSize: 16, color: AppColors.inkBlack,
                      ),
                      decoration: const InputDecoration(
                        hintText: '添加占问事项...',
                        hintStyle: TextStyle(fontFamily: 'KaiTi', color: AppColors.inkLight),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (_) => _saveQuestion(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 起卦详情
              AntiqueCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CalligraphyText('起卦详情', fontSize: 14, color: AppColors.inkGray),
                    const SizedBox(height: 12),
                    if (castSeq.isNotEmpty)
                      ...List.generate(6, (i) {
                        final sum = i < castSeq.length ? castSeq[i] : null;
                        final sumLabel = sum != null ? _sumLabel(sum) : '—';
                        final isChanging = sum == 6 || sum == 9;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: CalligraphyText(
                                  '${lineNames[i]}爻',
                                  fontSize: 14,
                                  color: AppColors.inkGray,
                                ),
                              ),
                              CalligraphyText(
                                sumLabel,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isChanging ? AppColors.cinnabarRed : AppColors.inkBlack,
                              ),
                              if (isChanging) ...[
                                const SizedBox(width: 4),
                                CalligraphyText('(动)', fontSize: 12, color: AppColors.cinnabarRed),
                              ],
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    CalligraphyText(
                      '本卦: $hexName${changingName != null ? ' → 变卦: $changingName' : ' (静卦)'}',
                      fontSize: 14,
                      color: AppColors.inkGray,
                    ),
                    if (changingPos.isNotEmpty)
                      CalligraphyText(
                        '动爻: ${changingPos.join(", ")}',
                        fontSize: 14,
                        color: AppColors.cinnabarRed,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 备注
              AntiqueCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CalligraphyText('备注', fontSize: 14, color: AppColors.inkGray),
                        const Spacer(),
                        TextButton(
                          onPressed: _saveNotes,
                          child: const CalligraphyText('保存', fontSize: 14, color: AppColors.cinnabarRed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      style: const TextStyle(
                        fontFamily: 'FangSong', fontSize: 15, color: AppColors.inkBlack,
                      ),
                      decoration: const InputDecoration(
                        hintText: '记录你的想法、应验情况...',
                        hintStyle: TextStyle(fontFamily: 'FangSong', color: AppColors.inkLight),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.silkBeige),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.silkBeige),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.cinnabarRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 删除按钮
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _deleteRecord,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cinnabarRed,
                    side: const BorderSide(color: AppColors.cinnabarRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text('删除此记录', style: TextStyle(fontFamily: 'KaiTi', fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _sumLabel(int sum) {
    return switch (sum) {
      6 => '老阴 (6)',
      7 => '少阳 (7)',
      8 => '少阴 (8)',
      9 => '老阳 (9)',
      _ => '$sum',
    };
  }

  String _formatDate(String isoStr) {
    try {
      final dt = DateTime.parse(isoStr);
      return '${dt.year}年${dt.month}月${dt.day}日 '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoStr;
    }
  }
}
