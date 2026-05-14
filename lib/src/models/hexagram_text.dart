class HexagramText {
  final int hexagramId;
  final String shallowInterpretation;
  final String judgment;
  final String judgmentVernacular;
  final String tuanZhuan;
  final String tuanZhuanVernacular;
  final String xiangZhuan;
  final String xiangZhuanVernacular;
  final String overallVerdict;
  final List<LineText> lineTexts;

  const HexagramText({
    required this.hexagramId,
    required this.shallowInterpretation,
    required this.judgment,
    required this.judgmentVernacular,
    required this.tuanZhuan,
    required this.tuanZhuanVernacular,
    required this.xiangZhuan,
    required this.xiangZhuanVernacular,
    required this.overallVerdict,
    required this.lineTexts,
  });

  factory HexagramText.fromJson(Map<String, dynamic> json) {
    return HexagramText(
      hexagramId: json['id'] as int,
      shallowInterpretation: json['shallow_interpretation'] as String? ?? '',
      judgment: json['judgment'] as String? ?? '',
      judgmentVernacular: json['judgment_vernacular'] as String? ?? '',
      tuanZhuan: json['tuan_zhuan'] as String? ?? '',
      tuanZhuanVernacular: json['tuan_zhuan_vernacular'] as String? ?? '',
      xiangZhuan: json['xiang_zhuan'] as String? ?? '',
      xiangZhuanVernacular: json['xiang_zhuan_vernacular'] as String? ?? '',
      overallVerdict: json['overall_verdict'] as String? ?? '',
      lineTexts: (json['lines'] as List<dynamic>?)
              ?.map((l) => LineText.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LineText {
  final int lineNumber;
  final String lineName;
  final String lineText;
  final String lineTextVernacular;
  final String xiaoXiang;
  final String xiaoXiangVernacular;
  final String changingMeaning;

  const LineText({
    required this.lineNumber,
    required this.lineName,
    required this.lineText,
    required this.lineTextVernacular,
    required this.xiaoXiang,
    required this.xiaoXiangVernacular,
    required this.changingMeaning,
  });

  factory LineText.fromJson(Map<String, dynamic> json) {
    return LineText(
      lineNumber: json['number'] as int,
      lineName: json['name'] as String? ?? '',
      lineText: json['text'] as String? ?? '',
      lineTextVernacular: json['vernacular'] as String? ?? '',
      xiaoXiang: json['xiao_xiang'] as String? ?? '',
      xiaoXiangVernacular: json['xiao_xiang_vernacular'] as String? ?? '',
      changingMeaning: json['changing_meaning'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap(int hexagramId) => {
    'hexagram_id': hexagramId,
    'line_number': lineNumber,
    'line_name': lineName,
    'line_text': lineText,
    'line_text_vernacular': lineTextVernacular,
    'xiao_xiang': xiaoXiang,
    'xiao_xiang_vernacular': xiaoXiangVernacular,
    'changing_meaning': changingMeaning,
  };
}
