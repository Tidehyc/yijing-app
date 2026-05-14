import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../services/audio_service.dart';
import '../../widgets/antique_card.dart';
import '../../widgets/calligraphy_text.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.antiquePaper,
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
            const CalligraphyText('音效设置', fontSize: 14, color: AppColors.inkGray),
            const SizedBox(height: 8),
            AntiqueCard(
              child: Column(
                children: [
                  _buildSoundToggle(
                    icon: Icons.music_note,
                    title: '背景音乐',
                    subtitle: '古筝',
                    enabled: ref.watch(audioSettingsProvider).bgMusicEnabled,
                    onToggle: (val) {
                      ref.read(audioSettingsProvider.notifier).toggleBgMusic();
                    },
                  ),
                  const Divider(color: AppColors.silkBeige),
                  _buildSoundToggle(
                    icon: Icons.volume_up,
                    title: '音效',
                    subtitle: '铜钱碰撞声',
                    enabled: ref.watch(audioSettingsProvider).sfxEnabled,
                    onToggle: (val) {
                      ref.read(audioSettingsProvider.notifier).toggleSfx();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const CalligraphyText('关于', fontSize: 14, color: AppColors.inkGray),
            const SizedBox(height: 8),
            AntiqueCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CalligraphyText('易经占卜', fontSize: 18, fontWeight: FontWeight.bold),
                  const SizedBox(height: 4),
                  const CalligraphyText('v1.0.0', fontSize: 14, color: AppColors.inkGray),
                  const SizedBox(height: 12),
                  const CalligraphyText(
                    '基于六爻铜钱起卦法，为您提供传统易经占卜体验。\n'
                    '卦辞、爻辞、彖传、象传源自《周易》原文。\n'
                    '纯本地应用，您的起卦数据仅保存在本设备中。',
                    fontSize: 14,
                    color: AppColors.inkGray,
                    height: 1.8,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.antiquePaperDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const CalligraphyText(
                      '天行健，君子以自强不息\n地势坤，君子以厚德载物',
                      fontSize: 14,
                      color: AppColors.sealRed,
                      textAlign: TextAlign.center,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required ValueChanged<bool> onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: enabled ? AppColors.cinnabarRed : AppColors.inkLight, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalligraphyText(title, fontSize: 16),
                CalligraphyText(subtitle, fontSize: 12, color: AppColors.inkLight),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeTrackColor: AppColors.cinnabarRed,
          ),
        ],
      ),
    );
  }
}
