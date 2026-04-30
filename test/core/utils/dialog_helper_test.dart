// dialog_helper_test.dart
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/core/utils/dialog_helper.dart"; // DialogHelper under test

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("DialogHelper singleton & API", () {
    test("DialogHelper.instance returns the same singleton", () {
      final a = DialogHelper.instance;
      final b = DialogHelper.instance;
      expect(a, same(b)); // both refs point to the _singleton
    });
  });

  group("showCustomDialog – rendering & close behaviors", () {
    Future<void> pumpApp(WidgetTester tester, {required Widget child}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: child)),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
        "renders title, header, divider, body & actions; default close pops",
        (tester) async {
      const contentKey = Key("dialog-content");
      const actionKey1 = Key("action-1");
      const actionKey2 = Key("action-2");

      await pumpApp(
        tester,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              DialogHelper.showCustomDialog(
                context: context,
                title: "Create Facility",
                content: const Text("Body", key: contentKey),
                // pass actions to exercise the `if (actions != null)` block
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("Save", key: actionKey1),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Cancel", key: actionKey2),
                  ),
                ],
              );
            },
            child: const Text("Open"),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Title appears in header
      expect(find.text("Create Facility"), findsOneWidget);

      // Body content is present
      expect(find.byKey(contentKey), findsOneWidget);

      // Divider just below header exists
      // We rely on presence of a Divider widget (thickness & color set in code)
      expect(find.byType(Divider), findsOneWidget);

      // Actions render
      expect(find.byKey(actionKey1), findsOneWidget);
      expect(find.byKey(actionKey2), findsOneWidget);

      // Default close button (cancel icon) should pop the dialog
      final closeIcon = find.byIcon(Icons.cancel_outlined);
      expect(closeIcon, findsOneWidget);
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.text("Create Facility"), findsNothing);
    });

    testWidgets("onClosePressed custom handler is called and pops",
        (tester) async {
      bool onCloseCalled = false;

      await pumpApp(
        tester,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              DialogHelper.showCustomDialog(
                context: context,
                title: "Custom Close",
                content: const Text("CC Body"),
                barrierDismissible: false,
                onClosePressed: () {
                  onCloseCalled = true; // should be set by custom handler
                  Navigator.of(context).pop(); // explicit pop from handler
                },
              );
            },
            child: const Text("Open CC"),
          ),
        ),
      );

      await tester.tap(find.text("Open CC"));
      await tester.pumpAndSettle();
      expect(find.text("Custom Close"), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cancel_outlined));
      await tester.pumpAndSettle();

      expect(onCloseCalled, isTrue);
      expect(find.text("Custom Close"), findsNothing);
    });

    testWidgets("explicit width path is used when width is provided",
        (tester) async {
      // We don’t assert pixel sizes (vary by device/test env),
      // but we exercise the `width ?? Scale.scaleHorizontally(600)` line by
      // passing a width to use the explicit branch.
      await pumpApp(
        tester,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              DialogHelper.showCustomDialog(
                context: context,
                title: "Sized Dialog",
                content: const Text("Sized Body"),
                width: 320, // exercises explicit width branch
              );
            },
            child: const Text("Open Sized"),
          ),
        ),
      );

      await tester.tap(find.text("Open Sized"));
      await tester.pumpAndSettle();

      // Ensure dialog opened and content visible (branch executed)
      expect(find.text("Sized Dialog"), findsOneWidget);
      expect(find.text("Sized Body"), findsOneWidget);

      // Close it (clean up)
      await tester.tap(find.byIcon(Icons.cancel_outlined));
      await tester.pumpAndSettle();
      expect(find.text("Sized Dialog"), findsNothing);
    });
  });
}
