import 'package:flutter/material.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/calligraphy_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(title: const Text('设置')),
      child: const Center(
        child: CalligraphyText('设置页面 — 开发中', fontSize: 18),
      ),
    );
  }
}
