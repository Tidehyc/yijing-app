import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiConfig {
  final String apiUrl;
  final String apiKey;
  final String model;

  const AiConfig({
    this.apiUrl = '',
    this.apiKey = '',
    this.model = '',
  });

  bool get isConfigured => apiUrl.isNotEmpty && apiKey.isNotEmpty && model.isNotEmpty;

  AiConfig copyWith({String? apiUrl, String? apiKey, String? model}) {
    return AiConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
    );
  }
}

class AiConfigNotifier extends StateNotifier<AiConfig> {
  AiConfigNotifier() : super(const AiConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AiConfig(
      apiUrl: prefs.getString('ai_api_url') ?? '',
      apiKey: prefs.getString('ai_api_key') ?? '',
      model: prefs.getString('ai_model') ?? '',
    );
  }

  Future<void> save(AiConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_api_url', config.apiUrl);
    await prefs.setString('ai_api_key', config.apiKey);
    await prefs.setString('ai_model', config.model);
    state = config;
  }
}

final aiConfigProvider = StateNotifierProvider<AiConfigNotifier, AiConfig>((ref) {
  return AiConfigNotifier();
});
