import 'package:flutter_test/flutter_test.dart';
import 'package:yijing_app/app.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const YijingApp());
    expect(find.text('易经占卜'), findsOneWidget);
    expect(find.text('开始起卦'), findsOneWidget);
    expect(find.text('历史记录'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
