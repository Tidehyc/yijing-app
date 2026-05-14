/// 单爻数据模型
enum LineType {
  /// 少阳 (7) — 阳爻，不变
  youngYang,

  /// 少阴 (8) — 阴爻，不变
  youngYin,

  /// 老阳 (9) — 阳爻，将变为阴
  oldYang,

  /// 老阴 (6) — 阴爻，将变为阳
  oldYin,
}

enum LineNature { yang, yin }

class LineData {
  final LineType type;
  final int coinSum;

  const LineData({
    required this.type,
    required this.coinSum,
  });

  LineNature get nature => (type == LineType.youngYang || type == LineType.oldYang)
      ? LineNature.yang
      : LineNature.yin;

  bool get isChanging =>
      type == LineType.oldYang || type == LineType.oldYin;

  /// 动爻变化后的爻象
  LineNature get changedNature => isChanging
      ? (nature == LineNature.yang ? LineNature.yin : LineNature.yang)
      : nature;

  String get label {
    switch (type) {
      case LineType.youngYang:
        return '少阳';
      case LineType.youngYin:
        return '少阴';
      case LineType.oldYang:
        return '老阳';
      case LineType.oldYin:
        return '老阴';
    }
  }

  /// 从三枚铜钱总和创建
  /// 6=老阴, 7=少阳, 8=少阴, 9=老阳
  factory LineData.fromCoinSum(int sum) {
    return switch (sum) {
      6 => const LineData(type: LineType.oldYin, coinSum: 6),
      7 => const LineData(type: LineType.youngYang, coinSum: 7),
      8 => const LineData(type: LineType.youngYin, coinSum: 8),
      9 => const LineData(type: LineType.oldYang, coinSum: 9),
      _ => throw ArgumentError('Invalid coin sum: $sum (must be 6,7,8,9)'),
    };
  }

  /// 随机生成一爻
  factory LineData.random() {
    final rng = DateTime.now().microsecondsSinceEpoch % 1000;
    final c1 = (rng % 2 == 0) ? 3 : 2;
    final c2 = ((rng ~/ 10) % 2 == 0) ? 3 : 2;
    final c3 = ((rng ~/ 100) % 2 == 0) ? 3 : 2;
    return LineData.fromCoinSum(c1 + c2 + c3);
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'coinSum': coinSum,
  };

  factory LineData.fromJson(Map<String, dynamic> json) {
    return LineData(
      type: LineType.values.firstWhere((e) => e.name == json['type']),
      coinSum: json['coinSum'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LineData && other.type == type && other.coinSum == coinSum;

  @override
  int get hashCode => type.hashCode ^ coinSum.hashCode;

  @override
  String toString() => 'LineData(type: $type, coinSum: $coinSum)';
}
