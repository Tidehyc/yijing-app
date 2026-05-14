class CaseReference {
  final int? id;
  final int hexagramId;
  final String source;
  final String sourceType; // "ancient" or "modern"
  final String title;
  final String narrative;
  final String analysis;
  final String? relevance;

  const CaseReference({
    this.id,
    required this.hexagramId,
    required this.source,
    required this.sourceType,
    required this.title,
    required this.narrative,
    required this.analysis,
    this.relevance,
  });

  factory CaseReference.fromJson(Map<String, dynamic> json) {
    return CaseReference(
      id: json['id'] as int?,
      hexagramId: json['hexagram_id'] as int,
      source: json['source'] as String? ?? '',
      sourceType: json['source_type'] as String? ?? 'ancient',
      title: json['title'] as String? ?? '',
      narrative: json['narrative'] as String? ?? '',
      analysis: json['analysis'] as String? ?? '',
      relevance: json['relevance'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'hexagram_id': hexagramId,
    'source': source,
    'source_type': sourceType,
    'title': title,
    'narrative': narrative,
    'analysis': analysis,
    'relevance': relevance,
  };
}
