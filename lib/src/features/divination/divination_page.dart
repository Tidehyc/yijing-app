import 'package:flutter/material.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/calligraphy_text.dart';

class DivinationPage extends StatelessWidget {
  const DivinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(title: const Text('起卦')),
      child: const Center(
        child: CalligraphyText('起卦页面 — 开发中', fontSize: 18),
      ),
    );
  }
}
