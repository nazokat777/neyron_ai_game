import 'package:flutter_test/flutter_test.dart';
import 'package:neyron_ai/main.dart';

void main() {
  testWidgets('Neyron AI app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NeyronAiApp());
    await tester.pump();
    // Splash screen should show "Neyron AI" title
    expect(find.text('Neyron AI'), findsOneWidget);
  });
}
