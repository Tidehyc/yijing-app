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

    final url = apiUrl.endsWith('/chat/completions')
        ? apiUrl
        : apiUrl.endsWith('/')
            ? '${apiUrl}chat/completions'
            : '$apiUrl/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': 2048,
          'messages': [
            {
              'role': 'system',
              'content': '你是一位精通《易经》的占卜解卦师，擅长结合卦象为用户的具体问题提供详细、有深度的解读。请使用古风文雅但不晦涩的中文，既保留易经的韵味，又让现代人能够理解。',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'];
          return message['content'] as String? ?? 'AI 返回为空';
        }
        return data.toString();
      } else {
        final body = utf8.decode(response.bodyBytes);
        if (response.statusCode == 401 || response.statusCode == 403) {
          return 'API 密钥无效，请检查设置中的 AI 配置。';
        }
        if (response.statusCode == 404) {
          return 'API 地址不存在 (404)。请检查 API 地址是否正确，通常格式为: https://api.deepseek.com/v1';
        }
        return 'AI 请求失败 (${response.statusCode}): ${body.length > 200 ? body.substring(0, 200) : body}';
      }
    } catch (e) {
      return '网络请求失败: $e';
    }
  }

  String _buildPrompt(String hexagramName, String hexagramInfo, String question) {
    return '''请根据以下卦象信息，针对用户的具体问题，给出一段详细、有深度的解读。

【卦象信息】
$hexagramInfo

【用户所问之事】
$question

请按照以下结构回答：
1. 卦象总论 — 结合卦名"$hexagramName"，总体分析此卦对此事的启示
2. 动爻分析 — 如果有动爻，逐条分析动爻的变化对此事的影响
3. 吉凶判断 — 给出综合判断和建议
4. 行动指南 — 给出3-5条具体的行动建议

总字数控制在500-800字。''';
  }
}
