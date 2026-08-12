import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campusflow/app.dart';

void main() {
  testWidgets('App shell shows Evim tab by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CampusFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CampusFlow'), findsOneWidget);
    expect(find.text('Evim — yakında'), findsOneWidget);
    expect(find.text('Evim'), findsWidgets);
    expect(find.text('Keşfet'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
