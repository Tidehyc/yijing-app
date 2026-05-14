import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../services/audio_service.dart';
import '../../services/ai_config_service.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiUrlCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  bool _configLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    final config = ref.read(aiConfigProvider);
    _apiUrlCtrl.text = config.apiUrl;
    _apiKeyCtrl.text = config.apiKey;
    _modelCtrl.text = config.model;
    _configLoaded = true;
  }

  @override
  void dispose() {
    _apiUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAiConfig() async {
    await ref.read(aiConfigProvider.notifier).save(AiConfig(
      apiUrl: _apiUrlCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 配置已保存', style: TextStyle(fontFamily: 'KaiTi'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.antiquePaper,
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
            // 音效
            const CalligraphyText('音效设置', fontSize: 14, color: AppColors.inkGray),
            const SizedBox(height: 8),
            AntiqueCard(
              child: Column(children: [
                _soundRow(Icons.music_note, '背景音乐', '古筝',
                    ref.watch(audioSettingsProvider).bgMusicEnabled,
                    () => ref.read(audioSettingsProvider.notifier).toggleBgMusic()),
                const Divider(color: AppColors.silkBeige),
                _soundRow(Icons.volume_up, '音效', '铜钱碰撞声',
                    ref.watch(audioSettingsProvider).sfxEnabled,
                    () => ref.read(audioSettingsProvider.notifier).toggleSfx()),
              ]),
            ),
            const SizedBox(height: 24),

            // AI 配置
            const CalligraphyText('AI 解卦配置', fontSize: 14, color: AppColors.inkGray),
            const SizedBox(height: 4),
            const CalligraphyText('（支持兼容 Anthropic 协议的 API）', fontSize: 12, color: AppColors.inkLight),
            const SizedBox(height: 8),
            AntiqueCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('API 地址'),
                _buildField(_apiUrlCtrl, 'https://api.deepseek.com/anthropic/v1/messages'),
                const SizedBox(height: 12),
                _fieldLabel('API Key'),
                _buildField(_apiKeyCtrl, 'sk-...', obscure: true),
                const SizedBox(height: 12),
                _fieldLabel('模型名称'),
                _buildField(_modelCtrl, 'deepseek-v4-pro[1m]'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAiConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cinnabarRed,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontFamily: 'KaiTi', fontSize: 16),
                    ),
                    child: const Text('保存 AI 配置'),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // 关于
            const CalligraphyText('关于', fontSize: 14, color: AppColors.inkGray),
            const SizedBox(height: 8),
            AntiqueCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const CalligraphyText('易经占卜', fontSize: 18, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                const CalligraphyText('v1.0.0', fontSize: 14, color: AppColors.inkGray),
                const SizedBox(height: 12),
                const CalligraphyText(
                  '基于六爻铜钱起卦法，为您提供传统易经占卜体验。\n卦辞、爻辞、彖传、象传源自《周易》原文。\nAI 解卦支持接入第三方大模型 API。\n纯本地应用，您的起卦数据仅保存在本设备中。',
                  fontSize: 14, color: AppColors.inkGray, height: 1.8,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.antiquePaperDark, borderRadius: BorderRadius.circular(8)),
                  child: const CalligraphyText('天行健，君子以自强不息\n地势坤，君子以厚德载物',
                    fontSize: 14, color: AppColors.sealRed, textAlign: TextAlign.center, height: 1.8),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => CalligraphyText(text, fontSize: 14, color: AppColors.inkGray);
  Widget _buildField(TextEditingController ctrl, String hint, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontFamily: 'FangSong', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'FangSong', fontSize: 12, color: AppColors.inkLight),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _soundRow(IconData icon, String title, String sub, bool enabled, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, color: enabled ? AppColors.cinnabarRed : AppColors.inkLight, size: 28),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CalligraphyText(title, fontSize: 16),
          CalligraphyText(sub, fontSize: 12, color: AppColors.inkLight),
        ])),
        Switch(value: enabled, onChanged: (_) => onTap(), activeTrackColor: AppColors.cinnabarRed),
      ]),
    );
  }
}
