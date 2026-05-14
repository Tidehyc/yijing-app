import 'package:flutter_test/flutter_test.dart';
import 'package:yijing_app/src/utils/divination_logic.dart';
import 'package:yijing_app/src/models/line_data.dart';

void main() {
  late DivinationLogic logic;

  setUp(() {
    logic = DivinationLogic();
  });

  group('castThreeCoins', () {
    test('returns valid sum between 6 and 9', () {
      for (int i = 0; i < 100; i++) {
        final sum = logic.castThreeCoins();
        expect(sum, anyOf(equals(6), equals(7), equals(8), equals(9)));
      }
    });
  });

  group('LineData.fromCoinSum', () {
    test('6 maps to oldYin', () {
      final line = LineData.fromCoinSum(6);
      expect(line.type, LineType.oldYin);
      expect(line.nature, LineNature.yin);
      expect(line.isChanging, true);
    });

    test('7 maps to youngYang', () {
      final line = LineData.fromCoinSum(7);
      expect(line.type, LineType.youngYang);
      expect(line.nature, LineNature.yang);
      expect(line.isChanging, false);
    });

    test('8 maps to youngYin', () {
      final line = LineData.fromCoinSum(8);
      expect(line.type, LineType.youngYin);
      expect(line.nature, LineNature.yin);
      expect(line.isChanging, false);
    });

    test('9 maps to oldYang', () {
      final line = LineData.fromCoinSum(9);
      expect(line.type, LineType.oldYang);
      expect(line.nature, LineNature.yang);
      expect(line.isChanging, true);
    });

    test('invalid sum throws error', () {
      expect(() => LineData.fromCoinSum(5), throwsArgumentError);
      expect(() => LineData.fromCoinSum(10), throwsArgumentError);
    });
  });

  group('DivinationLogic.buildResult', () {
    test('builds hexagram from 6 coin sums', () {
      final result = logic.buildResult([7, 8, 7, 8, 7, 8]);
      expect(result.lines.length, 6);
      expect(result.castSequence, [7, 8, 7, 8, 7, 8]);
      expect(result.originalHexagramId, isNotNull);
    });

    test('static hexagram (no changing lines)', () {
      final result = logic.buildResult([7, 7, 7, 7, 7, 7]);
      expect(result.isStatic, true);
      expect(result.changingHexagramId, isNull);
      expect(result.changingLinePositions, isEmpty);
    });

    test('changing hexagram with old yang', () {
      final result = logic.buildResult([9, 7, 7, 7, 7, 7]);
      expect(result.isStatic, false);
      expect(result.changingHexagramId, isNotNull);
      expect(result.changingLinePositions, contains(1));
    });

    test('all old yin produces all changing', () {
      final result = logic.buildResult([6, 6, 6, 6, 6, 6]);
      expect(result.isStatic, false);
      expect(result.changingLinePositions.length, 6);
      expect(result.originalHexagramId, 2); // 坤卦
      expect(result.changingHexagramId, 1); // 变乾卦
    });

    test('乾卦 static', () {
      final result = logic.buildResult([7, 7, 7, 7, 7, 7]);
      expect(result.originalHexagramId, 1);
    });

    test('坤卦 static', () {
      final result = logic.buildResult([8, 8, 8, 8, 8, 8]);
      expect(result.originalHexagramId, 2);
    });

    test('rejects non-6 length input', () {
      expect(() => logic.buildResult([7, 8, 7]), throwsArgumentError);
      expect(() => logic.buildResult([]), throwsArgumentError);
    });
  });
}
