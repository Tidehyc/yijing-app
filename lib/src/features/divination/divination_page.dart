import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../models/line_data.dart';
import '../../providers/divination_provider.dart';
import '../../utils/hexagram_painter.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';

class DivinationPage extends ConsumerStatefulWidget {
  const DivinationPage({super.key});

  @override
  ConsumerState<DivinationPage> createState() => _DivinationPageState();
}

class _DivinationPageState extends ConsumerState<DivinationPage> {
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
        return Container(
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
        // 上次结果提示
        if (state.lines.isNotEmpty) ...[
          _buildLastResult(state.lines.last),
          const SizedBox(height: 16),
        ],
        // 掷币按钮
        SizedBox(
          width: AppDimensions.castButtonWidth,
          height: AppDimensions.castButtonHeight,
          child: ElevatedButton(
            onPressed: () {
              ref.read(divinationProvider.notifier).castCoins();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinnabarRed,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'KaiTi',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(state.isStarted ? '继续掷币' : '掷币起卦'),
          ),
        ),
        if (state.isStarted)
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

  Widget _buildLastResult(LineData line) {
    final isChanging = line.isChanging;
    return Container(
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
            CalligraphyText(
              '(动爻)',
              fontSize: 12,
              color: AppColors.cinnabarRed,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompleteActions(DivinationState state) {
    return Column(
      children: [
        const CalligraphyText(
          '起卦完成',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: AppDimensions.castButtonWidth,
          height: AppDimensions.castButtonHeight,
          child: ElevatedButton(
            onPressed: () {
              final result = state.result!;
              Navigator.of(context).pushNamed(
                '/result',
                arguments: result,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinnabarRed,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'KaiTi',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('查看卦象'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            ref.read(divinationProvider.notifier).reset();
          },
          child: const CalligraphyText(
            '重新起卦',
            fontSize: 16,
            color: AppColors.inkGray,
          ),
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
