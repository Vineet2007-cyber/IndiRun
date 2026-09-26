import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/app.dart';

void main() {
  testWidgets('IndiRunApp renders and shows branding and home action', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IndiRunApp(),
      ),
    );

    // Initial pump and settling
    await tester.pumpAndSettle();

    // Verify app title branding is present
    expect(find.text('IndiRun'), findsOneWidget);

    // Verify primary run action is present on home screen
    expect(find.text('START RUN'), findsNothing); // label is capitalized in title case
    expect(find.text('Start Run'), findsOneWidget);
  });
}
