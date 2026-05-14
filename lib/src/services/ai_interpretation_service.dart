import 'dart:convert';
import 'package:http/http.dart' as http;

class AiInterpretationService {
  final String apiUrl;
  final String apiKey;
  final String model;

  AiInterpretationService({
    required this.apiUrl,
    required this.apiKey,
    required this.model,
  });

  Future<String> interpret({
    required String hexagramName,
    required String hexagramInfo,
    required String question,
  }) async {
    final prompt = _buildPrompt(hexagramName, hexagramInfo, question);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': model,
        'max_tokens': 2048,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['content'] as List<dynamic>;
      final text = content
          .whereType<Map<String, dynamic>>()
          .where((c) => c['type'] == 'text')
          .map((c) => c['text'] as String)
          .join('\n');
      return text;
    } else {
      final body = response.body;
      if (response.statusCode == 401 || response.statusCode == 403) {
        return 'API 密钥无效，请检查设置中的 AI 配置。';
      }
      return 'AI 请求失败 (${response.statusCode})。请检查网络和 API 配置。';
    }
  }

  String _buildPrompt(String hexagramName, String hexagramInfo, String question) {
    return '''你是一位精通《易经》的占卜解卦师。请根据以下卦象信息，针对用户的具体问题，给出一段详细、有深度的解读。

【卦象信息】
$hexagramInfo

【用户所问之事】
$question

请按照以下结构回答：
1. 卦象总论 — 结合卦名"$hexagramName"，总体分析此卦对此事的启示
2. 动爻分析 — 如果有动爻，逐条分析动爻的变化对此事的影响
3. 吉凶判断 — 给出综合判断和建议
4. 行动指南 — 给出3-5条具体的行动建议

请使用古风文雅但不晦涩的中文，既保留易经的韵味，又让现代人能够理解。在解读中适当引用卦辞爻辞原文。总字数控制在500-800字。''';
  }
}
