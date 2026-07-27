import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/session_conflict_dialog.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets("renders UI correctly", (tester) async {
    await tester.pumpWidget(
      buildTestWidget(const SessionConflictDialog()),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SessionConflictDialog), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
    expect(find.byType(CustomButton), findsOneWidget);
  });

  testWidgets("button tap does not crash", (tester) async {
    await tester.pumpWidget(
      buildTestWidget(const SessionConflictDialog()),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(CustomButton));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets("dialog closes when button pressed", (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                child: const Text("Open"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const SessionConflictDialog(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();

    expect(find.byType(SessionConflictDialog), findsOneWidget);

    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    expect(find.byType(SessionConflictDialog), findsNothing);
  });
}
