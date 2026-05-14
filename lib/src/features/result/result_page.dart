import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../database/database_helper.dart';
import '../../services/ai_config_service.dart';
import '../../services/ai_interpretation_service.dart';
import '../../utils/divination_logic.dart';
import '../../utils/hexagram_lookup.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';
import 'widgets/hexagram_display.dart';
import 'widgets/hexagram_info.dart';
import 'widgets/shallow_interpretation.dart';
import 'widgets/deep_interpretation.dart';
import 'widgets/interpretation_toggle.dart';

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage>
    with SingleTickerProviderStateMixin {
  InterpretationMode _mode = InterpretationMode.shallow;
  late DivinationResult _result;
  Map<String, dynamic>? _hexagramData;
  Map<String, dynamic>? _changingHexagramData;
  List<Map<String, dynamic>> _lineTexts = [];
  bool _loading = true;
  bool _saved = false;

  // AI 解卦状态
  final _questionCtrl = TextEditingController();
  bool _aiLoading = false;
  String? _aiResult;
  String? _aiError;

  late final AnimationController _drawController;
  late final Animation<double> _drawAnimation;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResult();
      _drawController.forward();
    });
  }

  @override
  void dispose() {
    _drawController.dispose();
    _questionCtrl.dispose();
    super.dispose();
  }

  void _loadResult() {
    final result = ModalRoute.of(context)?.settings.arguments as DivinationResult?;
    if (result == null) {
      Navigator.of(context).pop();
      return;
    }
    _result = result;
    _loadData();
    _autoSave();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    await db.database;

    final hexData = await db.hexagramDao.getHexagramById(_result.originalHexagramId);
    final lines = await db.hexagramDao.getLineTexts(_result.originalHexagramId);

    Map<String, dynamic>? changingData;
    if (_result.changingHexagramId != null) {
      changingData = await db.hexagramDao.getHexagramById(_result.changingHexagramId!);
    }

    setState(() {
      _hexagramData = hexData;
      _changingHexagramData = changingData;
      _lineTexts = lines;
      _loading = false;
    });
  }

  Future<void> _autoSave() async {
    if (_saved) return;
    _saved = true;

    final db = ref.read(databaseProvider);
    await db.database;

    await db.divinationDao.insertRecord({
      'created_at': DateTime.now().toIso8601String(),
      'original_hexagram_id': _result.originalHexagramId,
      'changing_hexagram_id': _result.changingHexagramId,
      'changing_line_positions': _result.changingLinePositions.join(','),
      'cast_sequence': _result.castSequence.join(','),
      'solar_date': DateTime.now().toString().split(' ')[0],
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.antiquePaper,
        appBar: AppBar(title: const Text('卦象结果')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.cinnabarRed)),
      );
    }

    final name = hexagramNames[_result.originalHexagramId] ?? '?';
    final changingName = _result.changingHexagramId != null
        ? hexagramNames[_result.changingHexagramId] ?? '?'
        : null;

    return Scaffold(
      backgroundColor: AppColors.antiquePaper,
      appBar: AppBar(
        title: Text(changingName != null ? '$name → $changingName' : name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 卦象图
              AnimatedBuilder(
                animation: _drawAnimation,
                builder: (context, child) {
                  return HexagramDisplay(
                    lines: _result.lines,
                    changingPositions: _result.changingLinePositions,
                    animationProgress: _drawAnimation.value,
                  );
                },
              ),
              const SizedBox(height: 16),

              // 卦象信息
              HexagramInfo(
                hexagramData: _hexagramData!,
                changingHexagramData: _changingHexagramData,
                changingLinePositions: _result.changingLinePositions,
              ),
              const SizedBox(height: 16),

              // 浅解/深解切换
              InterpretationToggle(
                mode: _mode,
                onChanged: (mode) => setState(() => _mode = mode),
              ),
              const SizedBox(height: 12),

              // 解读内容
              if (_mode == InterpretationMode.shallow)
                _buildShallow()
              else
                _buildDeep(),

              const SizedBox(height: 24),

              // AI 解卦区块
              _buildAiSection(),

              const SizedBox(height: 24),

              // 操作按钮
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShallow() {
    final verdict = _hexagramData?['overall_verdict'] as String? ?? '';
    final shallow = _hexagramData?['shallow_interpretation'] as String? ?? verdict;

    return ShallowInterpretation(
      text: shallow.isNotEmpty ? shallow : verdict,
      changingLines: _result.changingLinePositions,
      lineTexts: _lineTexts,
    );
  }

  Widget _buildDeep() {
    return DeepInterpretation(
      hexagramData: _hexagramData!,
      lineTexts: _lineTexts,
      changingLinePositions: _result.changingLinePositions,
    );
  }

  Widget _buildAiSection() {
    final aiConfig = ref.watch(aiConfigProvider);

    return AntiqueCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.auto_awesome, color: AppColors.cinnabarRed, size: 22),
          const SizedBox(width: 8),
          const CalligraphyText('AI 解卦', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cinnabarRed),
        ]),
        const SizedBox(height: 4),
        const CalligraphyText('填写你所问之事，AI 将结合卦象为你详细解读', fontSize: 12, color: AppColors.inkLight),
        const SizedBox(height: 12),

        if (!aiConfig.isConfigured) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.antiquePaperDark, borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              const CalligraphyText('尚未配置 AI', fontSize: 15, color: AppColors.inkGray, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              const CalligraphyText('请在「设置」中配置 API 地址、密钥和模型', fontSize: 13, color: AppColors.inkLight, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/settings'),
                child: const CalligraphyText('前往设置', fontSize: 15, color: AppColors.cinnabarRed),
              ),
            ]),
          ),
        ] else ...[
          TextField(
            controller: _questionCtrl,
            maxLines: 3,
            enabled: !_aiLoading,
            style: const TextStyle(fontFamily: 'FangSong', fontSize: 15, color: AppColors.inkBlack),
            decoration: const InputDecoration(
              hintText: '例如：最近想要换工作，不知道是否合适...',
              hintStyle: TextStyle(fontFamily: 'FangSong', color: AppColors.inkLight),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.silkBeige)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.cinnabarRed)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _aiLoading ? null : _requestAiInterpretation,
              icon: _aiLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome, size: 20),
              label: Text(_aiLoading ? 'AI 正在解卦...' : '开始 AI 解卦',
                  style: const TextStyle(fontFamily: 'KaiTi', fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinnabarRed,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.cinnabarLight,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],

        // AI 结果
        if (_aiResult != null) ...[
          const SizedBox(height: 16),
          const Divider(color: AppColors.silkBeige),
          const SizedBox(height: 12),
          const CalligraphyText('AI 解读', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.cinnabarRed),
          const SizedBox(height: 8),
          MarkdownBody(
            data: _aiResult!,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontFamily: 'FangSong', fontSize: 15, height: 1.8, color: AppColors.inkBlack),
              h2: const TextStyle(fontFamily: 'KaiTi', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.inkBlack),
              h3: const TextStyle(fontFamily: 'KaiTi', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.inkBlack),
              strong: const TextStyle(fontFamily: 'KaiTi', fontWeight: FontWeight.bold, color: AppColors.cinnabarRed),
              listBullet: const TextStyle(fontFamily: 'FangSong', fontSize: 15, color: AppColors.inkBlack),
            ),
          ),
        ],
        if (_aiError != null) ...[
          const SizedBox(height: 12),
          CalligraphyText(_aiError!, fontSize: 14, color: AppColors.cinnabarRed),
        ],
      ]),
    );
  }

  Future<void> _requestAiInterpretation() async {
    final question = _questionCtrl.text.trim();
    if (question.isEmpty) {
      setState(() => _aiError = '请先填写你所问之事');
      return;
    }

    final config = ref.read(aiConfigProvider);
    if (!config.isConfigured) return;

    setState(() { _aiLoading = true; _aiError = null; _aiResult = null; });

    // Build hexagram info for AI context
    final name = hexagramNames[_result.originalHexagramId] ?? '';
    final judgment = _hexagramData?['judgment'] as String? ?? '';
    final judgmentV = _hexagramData?['judgment_vernacular'] as String? ?? '';
    final xiangZhuan = _hexagramData?['xiang_zhuan'] as String? ?? '';
    final xiangV = _hexagramData?['xiang_zhuan_vernacular'] as String? ?? '';
    final verdict = _hexagramData?['overall_verdict'] as String? ?? '';

    final changingInfo = _result.changingLinePositions.map((pos) {
      final line = _lineTexts.where((l) => l['line_number'] == pos).firstOrNull;
      if (line == null) return '第$pos爻动';
      return '第$pos爻 (${line['line_name']}): ${line['line_text']} — ${line['line_text_vernacular'] ?? ''}';
    }).join('\n');

    final hexInfo = '''
卦名: $name
卦辞: $judgment
卦辞释义: $judgmentV
象传: $xiangZhuan
象传释义: $xiangV
总断: $verdict
${_result.isStatic ? '静卦（无动爻）' : '''
动爻:
$changingInfo
变卦: ${hexagramNames[_result.changingHexagramId] ?? ''}
'''}''';

    try {
      final service = AiInterpretationService(
        apiUrl: config.apiUrl,
        apiKey: config.apiKey,
        model: config.model,
      );
      final result = await service.interpret(
        hexagramName: name,
        hexagramInfo: hexInfo,
        question: question,
      );
      setState(() { _aiResult = result; _aiLoading = false; });

      // Save question to record
      final db = ref.read(databaseProvider);
      await db.database;
      final records = await db.divinationDao.getRecords(limit: 1);
      if (records.isNotEmpty) {
        await db.divinationDao.updateQuestion(records.first['id'] as int, question);
      }
    } catch (e) {
      setState(() {
        _aiError = '请求失败: $e';
        _aiLoading = false;
      });
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: AppDimensions.castButtonWidth,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inkBlack,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('返回首页'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/divination',
              (route) => route.settings.name == '/',
            );
          },
          child: const CalligraphyText('重新起卦', fontSize: 16, color: AppColors.cinnabarRed),
        ),
      ],
    );
  }
}
