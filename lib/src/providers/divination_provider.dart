import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/line_data.dart';
import '../utils/divination_logic.dart';

/// 起卦状态
class DivinationState {
  final int currentCast; // 当前第几次投掷 (0=未开始, 1-6)
  final List<LineData> lines; // 已得爻 (从初爻到上爻)
  final List<int> castSequence; // 已投掷的 coinSum
  final DivinationResult? result;

  const DivinationState({
    this.currentCast = 0,
    this.lines = const [],
    this.castSequence = const [],
    this.result,
  });

  bool get isComplete => result != null;
  bool get isStarted => currentCast > 0;

  /// 当前爻位名称 (初=1, 二=2, ..., 上=6)
  String? get currentLineName {
    if (currentCast < 1 || currentCast > 6) return null;
    const names = ['初', '二', '三', '四', '五', '上'];
    return '${names[currentCast - 1]}爻';
  }

  DivinationState copyWith({
    int? currentCast,
    List<LineData>? lines,
    List<int>? castSequence,
    DivinationResult? result,
  }) {
    return DivinationState(
      currentCast: currentCast ?? this.currentCast,
      lines: lines ?? this.lines,
      castSequence: castSequence ?? this.castSequence,
      result: result ?? this.result,
    );
  }
}

class DivinationNotifier extends StateNotifier<DivinationState> {
  final DivinationLogic _logic = DivinationLogic();

  DivinationNotifier() : super(const DivinationState());

  /// 执行一次投掷
  void castCoins() {
    if (state.isComplete) return;

    final nextIndex = state.currentCast + 1;
    if (nextIndex > 6) return;

    final coinSum = _logic.castThreeCoins();
    final line = LineData.fromCoinSum(coinSum);

    final newLines = [...state.lines, line];
    final newSequence = [...state.castSequence, coinSum];

    if (nextIndex == 6) {
      // 六次完成，计算结果
      final result = _logic.buildResult(newSequence);
      state = state.copyWith(
        currentCast: 6,
        lines: newLines,
        castSequence: newSequence,
        result: result,
      );
    } else {
      state = state.copyWith(
        currentCast: nextIndex,
        lines: newLines,
        castSequence: newSequence,
      );
    }
  }

  /// 重新起卦
  void reset() {
    state = const DivinationState();
  }
}

final divinationProvider =
    StateNotifierProvider<DivinationNotifier, DivinationState>((ref) {
  return DivinationNotifier();
});
