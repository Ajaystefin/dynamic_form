import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/core/utils/dialog_helper.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpTestApp(
    WidgetTester tester, {
    required Widget child,
    Size size = const Size(1400, 1000),
  }) async {
    await tester.binding.setSurfaceSize(size);

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(
            body: Center(
              child: child,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> openDialog(
    WidgetTester tester,
    String buttonText,
  ) async {
    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();
  }

  Finder closeButtonFinder() {
    return find.ancestor(
      of: find.byIcon(Icons.cancel_outlined),
      matching: find.byType(IconButton),
    );
  }

  Future<void> popTopRouteBeforeDialogBuilds(WidgetTester tester) async {
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    // Try to aboid execution error
    // ignore: cascade_invocations
    navigator.pop();

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group("DialogHelper singleton", () {
    test("DialogHelper.instance returns same singleton instance", () {
      final first = DialogHelper.instance;
      final second = DialogHelper.instance;

      expect(first, same(second));
    });
  });

  group("DialogHelper.showCustomDialog", () {
    testWidgets(
      "renders title, content, divider, actions and default close button",
      (WidgetTester tester) async {
        const contentKey = Key("dialog-content");
        const actionKey1 = Key("action-save");
        const actionKey2 = Key("action-cancel");

        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "Create",
                    content: const Text(
                      "Dialog Body",
                      key: contentKey,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Save",
                          key: actionKey1,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Cancel",
                          key: actionKey2,
                        ),
                      ),
                    ],
                  );
                },
                child: const Text("Open Dialog"),
              );
            },
          ),
        );

        await openDialog(tester, "Open Dialog");

        expect(find.byType(Dialog), findsOneWidget);
        expect(find.text("Create"), findsOneWidget);
        expect(find.byKey(contentKey), findsOneWidget);
        expect(find.byType(Divider), findsOneWidget);
        expect(find.byKey(actionKey1), findsOneWidget);
        expect(find.byKey(actionKey2), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

        await tester.tap(closeButtonFinder());
        await tester.pumpAndSettle();

        expect(find.text("Create"), findsNothing);
      },
    );

    testWidgets(
      "uses custom onClosePressed when provided",
      (WidgetTester tester) async {
        bool onCloseCalled = false;

        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "Custom",
                    content: const Text("Custom Close Body"),
                    barrierDismissible: false,
                    onClosePressed: () {
                      onCloseCalled = true;
                      Navigator.of(context).pop();
                    },
                  );
                },
                child: const Text("Open Custom Close"),
              );
            },
          ),
        );

        await openDialog(tester, "Open Custom Close");

        expect(find.text("Custom"), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

        await tester.tap(closeButtonFinder());
        await tester.pumpAndSettle();

        expect(onCloseCalled, isTrue);
        expect(find.text("Custom"), findsNothing);
      },
    );

    testWidgets(
      "does not render close button when showCloseButton is false",
      (WidgetTester tester) async {
        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "No Close",
                    content: const Text("No Close Body"),
                    showCloseButton: false,
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  );
                },
                child: const Text("Open No Close"),
              );
            },
          ),
        );

        await openDialog(tester, "Open No Close");

        expect(find.text("No Close"), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsNothing);
        expect(find.text("Done"), findsOneWidget);

        await tester.tap(find.text("Done"));
        await tester.pumpAndSettle();

        expect(find.text("No Close"), findsNothing);
      },
    );

    testWidgets(
      "renders dialog without actions when actions is null",
      (WidgetTester tester) async {
        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "No Actions",
                    content: const Text("Only Content"),
                  );
                },
                child: const Text("Open No Actions"),
              );
            },
          ),
        );

        await openDialog(tester, "Open No Actions");

        expect(find.text("No Actions"), findsOneWidget);
        expect(find.text("Only Content"), findsOneWidget);
        expect(find.byType(Row), findsWidgets);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

        await tester.tap(closeButtonFinder());
        await tester.pumpAndSettle();

        expect(find.text("No Actions"), findsNothing);
      },
    );

    testWidgets(
      "uses explicit width when width is provided",
      (WidgetTester tester) async {
        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "Width",
                    content: const Text("Width Body"),
                    width: 420,
                  );
                },
                child: const Text("Open Explicit Width"),
              );
            },
          ),
        );

        await openDialog(tester, "Open Explicit Width");

        expect(find.text("Width"), findsOneWidget);
        expect(find.text("Width Body"), findsOneWidget);

        final containerFinder = find.descendant(
          of: find.byType(Dialog),
          matching: find.byWidgetPredicate(
            (widget) => widget is Container && widget.constraints == null,
          ),
        );

        expect(containerFinder, findsWidgets);

        await tester.tap(closeButtonFinder());
        await tester.pumpAndSettle();

        expect(find.text("Width"), findsNothing);
      },
    );

    testWidgets(
      "uses default width branch when width is null",
      (WidgetTester tester) async {
        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "Default",
                    content: const Text("Default Width Body"),
                  );
                },
                child: const Text("Open Default Width"),
              );
            },
          ),
        );

        await openDialog(tester, "Open Default Width");

        expect(find.text("Default"), findsOneWidget);
        expect(find.text("Default Width Body"), findsOneWidget);

        await tester.tap(closeButtonFinder());
        await tester.pumpAndSettle();

        expect(find.text("Default"), findsNothing);
      },
    );

    testWidgets(
      "barrierDismissible true closes dialog when tapping outside",
      (WidgetTester tester) async {
        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "Dismissible",
                    content: const Text("Dismissible Body"),
                  );
                },
                child: const Text("Open Dismissible"),
              );
            },
          ),
        );

        await openDialog(tester, "Open Dismissible");

        expect(find.text("Dismissible"), findsOneWidget);

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text("Dismissible"), findsNothing);
      },
    );

    testWidgets(
      "barrierDismissible false does not close dialog when tapping outside",
      (WidgetTester tester) async {
        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DialogHelper.showCustomDialog(
                    context: context,
                    title: "Non Dismissible",
                    content: const Text("Non Dismissible Body"),
                    barrierDismissible: false,
                  );
                },
                child: const Text("Open Non Dismissible"),
              );
            },
          ),
        );

        await openDialog(tester, "Open Non Dismissible");

        expect(find.text("Non Dismissible"), findsOneWidget);

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text("Non Dismissible"), findsOneWidget);

        await tester.tap(closeButtonFinder());
        await tester.pumpAndSettle();

        expect(find.text("Non Dismissible"), findsNothing);
      },
    );
  });

  group("DialogHelper.showCommentContentDialog", () {
    testWidgets(
      "executes comment dialog method on desktop and returns false",
      (WidgetTester tester) async {
        bool? result;

        await pumpTestApp(
          tester,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await DialogHelper.showCommentContentDialog(
                    context,
                    "This is a saved comment",
                    "Comment",
                  );
                },
                child: const Text("Open Comment Dialog"),
              );
            },
          ),
        );

        await tester.tap(find.text("Open Comment Dialog"));

        await popTopRouteBeforeDialogBuilds(tester);

        expect(result, isFalse);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      "executes comment dialog method on mobile and returns false",
      (WidgetTester tester) async {
        bool? result;

        await pumpTestApp(
          tester,
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await DialogHelper.showCommentContentDialog(
                    context,
                    "Mobile comment description",
                    "Mobile",
                  );
                },
                child: const Text("Open Mobile Comment"),
              );
            },
          ),
        );

        await tester.tap(find.text("Open Mobile Comment"));

        await popTopRouteBeforeDialogBuilds(tester);

        expect(result, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
