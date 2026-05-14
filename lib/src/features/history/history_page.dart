import 'package:flutter/material.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/calligraphy_text.dart';

class HistoryListPage extends StatelessWidget {
  const HistoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(title: const Text('历史记录')),
      child: const Center(
        child: CalligraphyText('历史记录 — 开发中', fontSize: 18),
      ),
    );
  }
}
