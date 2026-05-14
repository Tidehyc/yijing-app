import 'line_data.dart';

/// 八卦模型
class Trigram {
  final String name;
  final List<LineNature> lines; // 3 lines, bottom to top (index 0 = bottom)
  final String element; // 五行
  final String direction; // 方位

  const Trigram({
    required this.name,
    required this.lines,
    required this.element,
    required this.direction,
  });

  static const Trigram qian = Trigram(
    name: '乾', lines: [LineNature.yang, LineNature.yang, LineNature.yang],
    element: '金', direction: '西北',
  );
  static const Trigram kun = Trigram(
    name: '坤', lines: [LineNature.yin, LineNature.yin, LineNature.yin],
    element: '土', direction: '西南',
  );
  static const Trigram zhen = Trigram(
    name: '震', lines: [LineNature.yang, LineNature.yin, LineNature.yin],
    element: '木', direction: '东',
  );
  static const Trigram xun = Trigram(
    name: '巽', lines: [LineNature.yin, LineNature.yang, LineNature.yang],
    element: '木', direction: '东南',
  );
  static const Trigram kan = Trigram(
    name: '坎', lines: [LineNature.yin, LineNature.yang, LineNature.yin],
    element: '水', direction: '北',
  );
  static const Trigram li = Trigram(
    name: '离', lines: [LineNature.yang, LineNature.yin, LineNature.yang],
    element: '火', direction: '南',
  );
  static const Trigram gen = Trigram(
    name: '艮', lines: [LineNature.yin, LineNature.yin, LineNature.yang],
    element: '土', direction: '东北',
  );
  static const Trigram dui = Trigram(
    name: '兑', lines: [LineNature.yang, LineNature.yang, LineNature.yin],
    element: '金', direction: '西',
  );

  static const List<Trigram> values = [qian, kun, zhen, xun, kan, li, gen, dui];

  /// 从三爻(自下而上)查找八卦
  factory Trigram.fromLines(List<LineNature> lines) {
    return values.firstWhere((t) =>
      t.lines[0] == lines[0] && t.lines[1] == lines[1] && t.lines[2] == lines[2],
    );
  }

  /// 从三个二进制位查找(0=阴,1=阳)
  factory Trigram.fromBinary(List<int> bits) {
    final lines = bits.map((b) => b == 1 ? LineNature.yang : LineNature.yin).toList();
    return Trigram.fromLines(lines);
  }

  @override
  String toString() => name;
}

/// 六十四卦模型
class Hexagram {
  final int id; // 1-64 文王卦序
  final String nameZh;
  final String namePinyin;
  final Trigram upperTrigram;
  final Trigram lowerTrigram;
  final List<LineData> lines; // 6 lines, index 0 = 初爻 (bottom)
  final String palace;
  final String wuxing;

  const Hexagram({
    required this.id,
    required this.nameZh,
    required this.namePinyin,
    required this.upperTrigram,
    required this.lowerTrigram,
    required this.lines,
    required this.palace,
    required this.wuxing,
  });

  /// 卦象是否为静卦(无动爻)
  bool get isStatic => lines.every((l) => !l.isChanging);

  /// 动爻位置列表 (1-6, 初爻=1, 上爻=6)
  List<int> get changingLinePositions {
    final positions = <int>[];
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isChanging) positions.add(i + 1);
    }
    return positions;
  }

  /// 六位二进制码 (阳=1, 阴=0, 自下而上)
  String get binaryCode {
    return lines.map((l) => l.nature == LineNature.yang ? '1' : '0').join();
  }

  /// 计算变卦（翻转所有动爻）
  Hexagram? toChangingHexagram(Hexagram Function(String binaryCode) lookup) {
    if (isStatic) return null;
    final changedCode = lines.map((l) {
      if (l.isChanging) {
        return l.changedNature == LineNature.yang ? '1' : '0';
      }
      return l.nature == LineNature.yang ? '1' : '0';
    }).join();
    return lookup(changedCode);
  }

  @override
  String toString() => 'Hexagram($id $nameZh)';
}
