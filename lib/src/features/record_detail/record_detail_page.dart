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
  Map<String, dynamic>? _hexData;
  List<Map<String, dynamic>> _lineTexts = [];
  bool _loading = true;
  bool _showDeep = false;
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

    final hexData = await db.hexagramDao.getHexagramById(record['original_hexagram_id'] as int);
    final lineTexts = await db.hexagramDao.getLineTexts(record['original_hexagram_id'] as int);

    setState(() {
      _record = record;
      _hexData = hexData;
      _lineTexts = lineTexts;
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

    final hexId = _record!['original_hexagram_id'] as int;
    final changingId = _record!['changing_hexagram_id'] as int?;
    final hexName = hexagramNames[hexId] ?? '?';
    final changingName = changingId != null ? hexagramNames[changingId] : null;
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
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.cinnabarRed), onPressed: _deleteRecord),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // 日期 + 卦象信息
            _buildHeader(hexName, changingName, dateStr),
            const SizedBox(height: 12),

            // 浅解/深解切换
            _buildToggle(),
            const SizedBox(height: 12),

            // 解读内容
            if (!_showDeep) _buildShallow() else _buildDeep(),
            const SizedBox(height: 12),

            // 占问事项
            _buildQuestionField(),
            const SizedBox(height: 12),

            // 起卦详情
            _buildCastDetail(castSeq, changingPos, lineNames, hexName, changingName),
            const SizedBox(height: 12),

            // 备注
            _buildNotesField(),
            const SizedBox(height: 24),

            // 删除
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
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(String hexName, String? changingName, String dateStr) {
    return AntiqueCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CalligraphyText(hexName, fontSize: 32, fontWeight: FontWeight.bold),
          if (changingName != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: AppColors.cinnabarRed, size: 22),
            const SizedBox(width: 8),
            CalligraphyText(changingName, fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.cinnabarRed),
          ],
        ]),
        const SizedBox(height: 8),
        CalligraphyText(dateStr, fontSize: 14, color: AppColors.inkGray),
        if (_hexData != null) ...[
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _tag('${_hexData!['upper_trigram']}上 ${_hexData!['lower_trigram']}下'),
            const SizedBox(width: 6),
            _tag(_hexData!['palace'] as String? ?? ''),
            const SizedBox(width: 6),
            _tag(_hexData!['wuxing'] as String? ?? ''),
          ]),
        ],
      ]),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.antiquePaperDark, borderRadius: BorderRadius.circular(10)),
      child: CalligraphyText(text, fontSize: 12, color: AppColors.inkGray),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.antiquePaperDark, borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        _toggleBtn('浅解', !_showDeep),
        _toggleBtn('深解', _showDeep),
      ]),
    );
  }

  Widget _toggleBtn(String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showDeep = label == '深解'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.cinnabarRed : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            fontFamily: 'KaiTi', fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : AppColors.inkGray,
          )),
        ),
      ),
    );
  }

  Widget _buildShallow() {
    final verdict = _hexData?['overall_verdict'] as String? ?? '';
    final shallow = _hexData?['shallow_interpretation'] as String? ?? '';
    final text = shallow.isNotEmpty ? shallow : verdict;

    return AntiqueCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lightbulb_outline, color: AppColors.coinGold, size: 20),
          const SizedBox(width: 8),
          const CalligraphyText('浅解', fontSize: 18, fontWeight: FontWeight.bold),
        ]),
        const SizedBox(height: 12),
        CalligraphyText(text.isNotEmpty ? text : '暂无浅解数据', fontSize: 15, height: 2.0),
        if (_lineTexts.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(color: AppColors.silkBeige),
          const SizedBox(height: 12),
          const CalligraphyText('动爻提示', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cinnabarRed),
          const SizedBox(height: 8),
          ..._lineTexts.where((l) {
            final pos = l['line_number'] as int;
            return _record!['changing_line_positions']?.toString().contains('$pos') == true;
          }).map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CalligraphyText('${l['line_name']}: ${l['changing_meaning'] ?? l['line_text_vernacular'] ?? l['line_text'] ?? ''}', fontSize: 14, height: 1.8),
          )),
        ],
      ]),
    );
  }

  Widget _buildDeep() {
    final hasJudgment = (_hexData?['judgment'] as String?)?.isNotEmpty == true;
    final hasXiang = (_hexData?['xiang_zhuan'] as String?)?.isNotEmpty == true;

    if (!hasJudgment && !hasXiang && _lineTexts.isEmpty) {
      return AntiqueCard(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Icon(Icons.hourglass_empty, color: AppColors.inkLight, size: 32),
          const SizedBox(height: 12),
          const CalligraphyText('暂无深解数据', fontSize: 16, color: AppColors.inkGray, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const CalligraphyText('深度卦辞、爻辞正在持续录入中', fontSize: 13, color: AppColors.inkLight, textAlign: TextAlign.center),
        ]),
      );
    }

    return Column(children: [
      if (hasJudgment)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _collapsibleCard('卦辞', [
            CalligraphyText(_hexData!['judgment'] as String, fontSize: 16, fontFamily: 'KaiTi', letterSpacing: 2),
            if ((_hexData!['judgment_vernacular'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              CalligraphyText(_hexData!['judgment_vernacular'] as String, fontSize: 14, fontFamily: 'FangSong', color: AppColors.inkGray, height: 1.8),
            ],
          ]),
        ),
      if (hasXiang)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _collapsibleCard('象传', [
            CalligraphyText(_hexData!['xiang_zhuan'] as String, fontSize: 16, fontFamily: 'KaiTi', letterSpacing: 2),
            if ((_hexData!['xiang_zhuan_vernacular'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              CalligraphyText(_hexData!['xiang_zhuan_vernacular'] as String, fontSize: 14, fontFamily: 'FangSong', color: AppColors.inkGray, height: 1.8),
            ],
          ]),
        ),
      if (_lineTexts.isNotEmpty) _buildLineSection(),
    ]);
  }

  Widget _buildLineSection() {
    final changingPos = _record!['changing_line_positions'] as String? ?? '';
    final lines = changingPos.isNotEmpty
        ? _lineTexts.where((l) => changingPos.contains('${l['line_number']}')).toList()
        : _lineTexts;

    return _collapsibleCard(
      '爻辞${changingPos.isNotEmpty ? '（动爻）' : ''}',
      lines.map((line) {
        final isChanging = changingPos.contains('${line['line_number']}');
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isChanging ? AppColors.cinnabarLight.withValues(alpha: 0.15) : AppColors.antiquePaperDark,
            borderRadius: BorderRadius.circular(8),
            border: isChanging ? Border.all(color: AppColors.cinnabarRed.withValues(alpha: 0.3)) : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CalligraphyText(line['line_name'] as String? ?? '', fontSize: 16, fontWeight: FontWeight.bold, color: isChanging ? AppColors.cinnabarRed : AppColors.inkBlack),
              if (isChanging) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.cinnabarRed.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('动', style: TextStyle(fontFamily: 'KaiTi', fontSize: 10, color: AppColors.cinnabarRed)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            CalligraphyText(line['line_text'] as String? ?? '', fontSize: 15, letterSpacing: 1.5, fontFamily: 'KaiTi'),
            if ((line['line_text_vernacular'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              CalligraphyText(line['line_text_vernacular'] as String, fontSize: 13, fontFamily: 'FangSong', color: AppColors.inkGray, height: 1.6),
            ],
          ]),
        );
      }).toList(),
      initiallyExpanded: changingPos.isNotEmpty,
    );
  }

  Widget _collapsibleCard(String title, List<Widget> children, {bool initiallyExpanded = false}) {
    return _CollapsibleSection(title: title, initiallyExpanded: initiallyExpanded, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }

  Widget _buildQuestionField() {
    return AntiqueCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CalligraphyText('占问事项', fontSize: 14, color: AppColors.inkGray),
        const SizedBox(height: 8),
        TextField(
          controller: _questionController,
          style: const TextStyle(fontFamily: 'KaiTi', fontSize: 16, color: AppColors.inkBlack),
          decoration: const InputDecoration(
            hintText: '添加占问事项...',
            hintStyle: TextStyle(fontFamily: 'KaiTi', color: AppColors.inkLight),
            border: InputBorder.none, isDense: true,
          ),
          onChanged: (_) => _saveQuestion(),
        ),
      ]),
    );
  }

  Widget _buildCastDetail(List<int> castSeq, List<int> changingPos, List<String> lineNames, String hexName, String? changingName) {
    return AntiqueCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CalligraphyText('起卦详情', fontSize: 14, color: AppColors.inkGray),
        const SizedBox(height: 12),
        if (castSeq.isNotEmpty)
          ...List.generate(6, (i) {
            final sum = i < castSeq.length ? castSeq[i] : null;
            final isChanging = sum == 6 || sum == 9;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                SizedBox(width: 40, child: CalligraphyText('${lineNames[i]}爻', fontSize: 14, color: AppColors.inkGray)),
                CalligraphyText(_sumLabel(sum), fontSize: 14, fontWeight: FontWeight.bold, color: isChanging ? AppColors.cinnabarRed : AppColors.inkBlack),
                if (isChanging) ...[const SizedBox(width: 4), CalligraphyText('(动)', fontSize: 12, color: AppColors.cinnabarRed)],
              ]),
            );
          }),
        const SizedBox(height: 8),
        CalligraphyText('本卦: $hexName${changingName != null ? ' → 变卦: $changingName' : ' (静卦)'}', fontSize: 14, color: AppColors.inkGray),
        if (changingPos.isNotEmpty)
          CalligraphyText('动爻: ${changingPos.join(", ")}', fontSize: 14, color: AppColors.cinnabarRed),
      ]),
    );
  }

  Widget _buildNotesField() {
    return AntiqueCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CalligraphyText('备注', fontSize: 14, color: AppColors.inkGray),
          const Spacer(),
          TextButton(onPressed: _saveNotes, child: const CalligraphyText('保存', fontSize: 14, color: AppColors.cinnabarRed)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController, maxLines: 5,
          style: const TextStyle(fontFamily: 'FangSong', fontSize: 15, color: AppColors.inkBlack),
          decoration: const InputDecoration(
            hintText: '记录你的想法、应验情况...',
            hintStyle: TextStyle(fontFamily: 'FangSong', color: AppColors.inkLight),
            border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.silkBeige)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.silkBeige)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.cinnabarRed)),
          ),
        ),
      ]),
    );
  }

  String _sumLabel(int? sum) => switch (sum) {
    6 => '老阴 (6)', 7 => '少阳 (7)', 8 => '少阴 (8)', 9 => '老阳 (9)',
    _ => '—',
  };

  String _formatDate(String isoStr) {
    try {
      final dt = DateTime.parse(isoStr);
      return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoStr;
    }
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  const _CollapsibleSection({required this.title, required this.child, this.initiallyExpanded = false});
  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _expanded;
  @override
  void initState() { super.initState(); _expanded = widget.initiallyExpanded; }
  @override
  Widget build(BuildContext context) {
    return AntiqueCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(children: [
            Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.cinnabarRed),
            const SizedBox(width: 8),
            CalligraphyText(widget.title, fontSize: 16, fontWeight: FontWeight.bold),
            const Spacer(),
          ]),
        ),
        if (_expanded) ...[const SizedBox(height: 12), widget.child],
      ]),
    );
  }
}
