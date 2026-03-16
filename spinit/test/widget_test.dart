import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spinit/main.dart';

void main() {
  testWidgets('SpinIt app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SpinItApp()));
    expect(find.text('SpinIt'), findsOneWidget);
  });
}
