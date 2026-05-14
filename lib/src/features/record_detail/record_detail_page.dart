import 'package:flutter/material.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/calligraphy_text.dart';

class RecordDetailPage extends StatelessWidget {
  final int? recordId;
  const RecordDetailPage({super.key, this.recordId});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(title: const Text('记录详情')),
      child: const Center(
        child: CalligraphyText('记录详情 — 开发中', fontSize: 18),
      ),
    );
  }
}
