import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketledger/main.dart';

void main() {
  testWidgets('PocketLedger App smoke test', (WidgetTester tester) async {
    // Build our app and trigger an initial frame
    await tester.pumpWidget(
      const ProviderScope(
        child: PocketLedgerApp(),
      ),
    );

    // Verify PocketLedgerApp renders
    expect(find.byType(PocketLedgerApp), findsOneWidget);

    // Advance time past splash timer without waiting for infinite spinner
    await tester.pump(const Duration(seconds: 1));
  });
}
