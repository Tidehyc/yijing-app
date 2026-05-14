import 'dart:math';
import '../models/line_data.dart';
import 'hexagram_lookup.dart';

class DivinationLogic {
  final Random _random = Random();

  /// 投掷三枚铜钱，返回总和 (6/7/8/9)
  int castThreeCoins() {
    // 每枚铜钱正面=3 (阳), 反面=2 (阴)
    final c1 = _random.nextBool() ? 3 : 2;
    final c2 = _random.nextBool() ? 3 : 2;
    final c3 = _random.nextBool() ? 3 : 2;
    return c1 + c2 + c3;
  }

  /// 从六次投掷结果构建完整的卦象
  DivinationResult buildResult(List<int> coinSums) {
    if (coinSums.length != 6) {
      throw ArgumentError('Exactly 6 coin casts required, got ${coinSums.length}');
    }

    final lines = coinSums.map((sum) => LineData.fromCoinSum(sum)).toList();
    final binaryCode = lines.map((l) => l.nature == LineNature.yang ? '1' : '0').join();
    final originalId = lookupHexagramId(binaryCode);

    if (originalId == null) {
      throw StateError('Failed to lookup hexagram for binary code: $binaryCode');
    }

    final changingPositions = <int>[];
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isChanging) changingPositions.add(i + 1);
    }

    int? changingId;
    if (changingPositions.isNotEmpty) {
      final changedCode = lines.map((l) {
        if (l.isChanging) {
          return l.changedNature == LineNature.yang ? '1' : '0';
        }
        return l.nature == LineNature.yang ? '1' : '0';
      }).join();
      changingId = lookupHexagramId(changedCode);
    }

    return DivinationResult(
      lines: lines,
      castSequence: coinSums,
      originalHexagramId: originalId,
      changingHexagramId: changingId,
      changingLinePositions: changingPositions,
    );
  }
}

class DivinationResult {
  final List<LineData> lines;
  final List<int> castSequence;
  final int originalHexagramId;
  final int? changingHexagramId;
  final List<int> changingLinePositions;

  const DivinationResult({
    required this.lines,
    required this.castSequence,
    required this.originalHexagramId,
    this.changingHexagramId,
    this.changingLinePositions = const [],
  });

  bool get isStatic => changingHexagramId == null;
}
