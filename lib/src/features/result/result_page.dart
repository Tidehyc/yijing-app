import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../database/database_helper.dart';
import '../../utils/divination_logic.dart';
import '../../utils/hexagram_lookup.dart';
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
