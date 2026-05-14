import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../models/line_data.dart';
import '../../providers/divination_provider.dart';
import '../../services/audio_service.dart';
import '../../services/sensor_service.dart';
import '../../utils/hexagram_painter.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';

class DivinationPage extends ConsumerStatefulWidget {
  const DivinationPage({super.key});

  @override
  ConsumerState<DivinationPage> createState() => _DivinationPageState();
}

class _DivinationPageState extends ConsumerState<DivinationPage>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _shakeAnim;
  late final Animation<double> _throwAnim;
  late final Animation<double> _landAnim;
  late final Animation<double> _revealAnim;

  bool _isAnimating = false;
  final SensorService _sensor = SensorService();
  final List<bool> _coinResults = [true, true, true]; // true=正面(阳), false=反面(阴)

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // 初始化音频
    final audio = ref.read(audioServiceProvider);
    audio.init().then((_) => audio.playBgMusic());

    // 启用摇动检测
    _sensor.startListening(onShake: _performCast);
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.17, curve: Curves.easeInOut),
      ),
    );

    _throwAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.17, 0.45, curve: Curves.easeOut),
      ),
    );

    _landAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.45, 0.78, curve: Curves.bounceOut),
      ),
    );

    _revealAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.78, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _sensor.stopListening();
    super.dispose();
  }

  void _performCast() {
    final divination = ref.read(divinationProvider.notifier);
    final currentState = ref.read(divinationProvider);
    if (currentState.isComplete || _isAnimating) return;

    setState(() {
      _isAnimating = true;
      _coinResults[0] = _randomBool();
      _coinResults[1] = _randomBool();
      _coinResults[2] = _randomBool();
    });

    final audio = ref.read(audioServiceProvider);
    audio.playCoinCollision();

    _animController.forward(from: 0).then((_) {
      audio.playCoinLand();
      divination.castCoins();
    });
  }

  bool _randomBool() => DateTime.now().microsecondsSinceEpoch % 2 == 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(divinationProvider);

    return Scaffold(
      backgroundColor: AppColors.antiquePaper,
      appBar: AppBar(
        title: const Text('起卦'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (state.isStarted && !state.isComplete) {
              _showExitDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (state.isStarted)
            TextButton(
              onPressed: () {
                ref.read(divinationProvider.notifier).reset();
              },
              child: const Text('重来', style: TextStyle(color: AppColors.cinnabarRed)),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            children: [
              _buildProgressIndicator(state),
              const SizedBox(height: 16),
              _buildHexagramArea(state),
              const SizedBox(height: 16),
              _buildLineIndicator(state),
              const Spacer(),
              if (state.isComplete)
                _buildCompleteActions(state)
              else
                _buildCastArea(state),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(DivinationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isDone = index < state.lines.length;
        final isCurrent = index == state.currentCast;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.cinnabarRed
                : isCurrent
                    ? AppColors.cinnabarLight
                    : AppColors.silkBeige,
            border: Border.all(
              color: isCurrent && !isDone ? AppColors.cinnabarRed : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontFamily: 'KaiTi',
                fontSize: 14,
                color: isDone ? Colors.white : AppColors.inkGray,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHexagramArea(DivinationState state) {
    return Expanded(
      child: AntiqueCard(
        padding: const EdgeInsets.all(20),
        child: state.lines.isEmpty
            ? Center(
                child: CalligraphyText(
                  '诚心默念所问之事\n然后掷币起卦',
                  fontSize: 16,
                  color: AppColors.inkLight,
                  textAlign: TextAlign.center,
                  height: 2.2,
                ),
              )
            : CustomPaint(
                size: Size.infinite,
                painter: HexagramLinePainter(
                  lines: state.lines,
                  showChangingMarks: state.isComplete,
                ),
              ),
      ),
    );
  }

  Widget _buildLineIndicator(DivinationState state) {
    if (state.isComplete) {
      return const CalligraphyText(
        '六爻已成',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
      );
    }
    if (!state.isStarted) {
      return const SizedBox.shrink();
    }
    return CalligraphyText(
      '第 ${state.currentCast} 爻 — 请掷币',
      fontSize: 16,
      color: AppColors.inkGray,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCastArea(DivinationState state) {
    return Column(
      children: [
        if (state.lines.isNotEmpty) ...[
          _buildLastResult(state.lines.last),
          const SizedBox(height: 16),
        ],
        if (_isAnimating) _buildCoinAnimation() else _buildCoinStatic(),
        const SizedBox(height: 20),
        SizedBox(
          width: AppDimensions.castButtonWidth,
          height: AppDimensions.castButtonHeight,
          child: ElevatedButton(
            onPressed: _isAnimating ? null : _performCast,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinnabarRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.cinnabarLight,
              textStyle: const TextStyle(
                fontFamily: 'KaiTi',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(_isAnimating ? '投掷中...' : (state.isStarted ? '继续掷币' : '掷币起卦')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CalligraphyText(
            '摇动手机或点击按钮',
            fontSize: 12,
            color: AppColors.inkLight,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCoinStatic() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: AppDimensions.coinSize,
          height: AppDimensions.coinSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.coinGold,
            border: Border.all(color: AppColors.coinDark, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '币',
              style: TextStyle(
                fontFamily: 'KaiTi',
                fontSize: 20,
                color: AppColors.coinDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCoinAnimation() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final shakeOffset = _shakeAnim.value > 0
                ? (index % 2 == 0 ? 1 : -1) *
                    sin(_shakeAnim.value * 12 * pi + index) *
                    8.0 *
                    (1 - _shakeAnim.value)
                : 0.0;

            final throwY = _throwAnim.value > 0 ? -_throwAnim.value * 120 : 0.0;
            final throwRotate = _throwAnim.value > 0
                ? _throwAnim.value * 6 * pi * (index % 2 == 0 ? 1 : -1)
                : 0.0;

            final landY = _landAnim.value > 0
                ? -120 * (1 - _landAnim.value)
                : 0.0;
            final landScale = _landAnim.value > 0.9
                ? 1.0 + sin((_landAnim.value - 0.9) * 10 * pi) * 0.1 * (1 - _landAnim.value)
                : 1.0;

            final scale = _landAnim.value < 0.1 ? 1.0 : landScale;

            return Transform.translate(
              offset: Offset(shakeOffset, throwY + landY),
              child: Transform.scale(
                scale: scale,
                child: Transform(
                  transform: Matrix4.rotationX(throwRotate),
                  alignment: Alignment.center,
                  child: _buildSingleCoin(_coinResults[index], _revealAnim),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSingleCoin(bool isHeads, Animation<double> revealAnim) {
    return AnimatedBuilder(
      animation: revealAnim,
      builder: (context, child) {
        final opacity = revealAnim.value < 0.3
            ? 0.0
            : (revealAnim.value - 0.3) / 0.7;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            width: AppDimensions.coinSize,
            height: AppDimensions.coinSize,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coinGold,
              border: Border.all(color: AppColors.coinDark, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isHeads ? '正' : '反',
                style: TextStyle(
                  fontFamily: 'KaiTi',
                  fontSize: 18,
                  color: AppColors.coinDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLastResult(LineData line) {
    final isChanging = line.isChanging;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isChanging ? AppColors.cinnabarLight.withValues(alpha: 0.3) : AppColors.silkBeige,
        borderRadius: BorderRadius.circular(20),
        border: isChanging
            ? Border.all(color: AppColors.cinnabarRed.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            line.nature == LineNature.yang ? '⚊' : '⚋',
            style: TextStyle(
              fontSize: 24,
              color: isChanging ? AppColors.cinnabarRed : AppColors.inkBlack,
            ),
          ),
          const SizedBox(width: 8),
          CalligraphyText(
            line.label,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isChanging ? AppColors.cinnabarRed : AppColors.inkBlack,
          ),
          if (isChanging) ...[
            const SizedBox(width: 8),
            CalligraphyText('(动爻)', fontSize: 12, color: AppColors.cinnabarRed),
          ],
        ],
      ),
    );
  }

  Widget _buildCompleteActions(DivinationState state) {
    return Column(
      children: [
        const CalligraphyText('起卦完成', fontSize: 20, fontWeight: FontWeight.bold),
        const SizedBox(height: 20),
        SizedBox(
          width: AppDimensions.castButtonWidth,
          height: AppDimensions.castButtonHeight,
          child: ElevatedButton(
            onPressed: () {
              final result = state.result!;
              Navigator.of(context).pushNamed('/result', arguments: result);
            },
            child: const Text('查看卦象'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ref.read(divinationProvider.notifier).reset(),
          child: const CalligraphyText('重新起卦', fontSize: 16, color: AppColors.inkGray),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.antiquePaperLight,
        title: const CalligraphyText('确定退出？', fontSize: 18, fontWeight: FontWeight.bold),
        content: const CalligraphyText('当前起卦进度将丢失。', color: AppColors.inkGray),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const CalligraphyText('继续起卦', color: AppColors.cinnabarRed),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: const CalligraphyText('退出', color: AppColors.inkGray),
          ),
        ],
      ),
    );
  }
}
