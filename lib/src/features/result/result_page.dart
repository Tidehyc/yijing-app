import 'package:flutter/material.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/calligraphy_text.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(title: const Text('卦象结果')),
      child: const Center(
        child: CalligraphyText('结果页面 — 开发中', fontSize: 18),
      ),
    );
  }
}
