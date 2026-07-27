import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/loading_page.dart";

void main() {
  testWidgets("LoadingPage builds correctly and shows SizedBox", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoadingPage(),
      ),
    );

    expect(find.byType(LoadingPage), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
