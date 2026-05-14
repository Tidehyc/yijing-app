class DivinationRecord {
  final int? id;
  final DateTime createdAt;
  final String? question;
  final String? notes;
  final int originalHexagramId;
  final int? changingHexagramId;
  final List<int> changingLinePositions;
  final List<int> castSequence; // 6 次投掷的 coinSum (6/7/8/9)
  final String? lunarDate;
  final String? solarDate;
  final bool isDeleted;

  const DivinationRecord({
    this.id,
    required this.createdAt,
    this.question,
    this.notes,
    required this.originalHexagramId,
    this.changingHexagramId,
    this.changingLinePositions = const [],
    required this.castSequence,
    this.lunarDate,
    this.solarDate,
    this.isDeleted = false,
  });

  DivinationRecord copyWith({
    int? id,
    DateTime? createdAt,
    String? question,
    String? notes,
    int? originalHexagramId,
    int? changingHexagramId,
    List<int>? changingLinePositions,
    List<int>? castSequence,
    String? lunarDate,
    String? solarDate,
    bool? isDeleted,
  }) {
    return DivinationRecord(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      question: question ?? this.question,
      notes: notes ?? this.notes,
      originalHexagramId: originalHexagramId ?? this.originalHexagramId,
      changingHexagramId: changingHexagramId ?? this.changingHexagramId,
      changingLinePositions: changingLinePositions ?? this.changingLinePositions,
      castSequence: castSequence ?? this.castSequence,
      lunarDate: lunarDate ?? this.lunarDate,
      solarDate: solarDate ?? this.solarDate,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'created_at': createdAt.toIso8601String(),
    'question': question,
    'notes': notes,
    'original_hexagram_id': originalHexagramId,
    'changing_hexagram_id': changingHexagramId,
    'changing_line_positions': changingLinePositions.join(','),
    'cast_sequence': castSequence.join(','),
    'lunar_date': lunarDate,
    'solar_date': solarDate,
    'is_deleted': isDeleted ? 1 : 0,
  };

  factory DivinationRecord.fromMap(Map<String, dynamic> map) {
    return DivinationRecord(
      id: map['id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      question: map['question'] as String?,
      notes: map['notes'] as String?,
      originalHexagramId: map['original_hexagram_id'] as int,
      changingHexagramId: map['changing_hexagram_id'] as int?,
      changingLinePositions: (map['changing_line_positions'] as String?)?.isNotEmpty == true
          ? (map['changing_line_positions'] as String).split(',').map(int.parse).toList()
          : [],
      castSequence: (map['cast_sequence'] as String).split(',').map(int.parse).toList(),
      lunarDate: map['lunar_date'] as String?,
      solarDate: map['solar_date'] as String?,
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }
}
