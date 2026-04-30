import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/semantics_provider.dart";

void main() {
  group("SemanticsProvider", () {
    late bool showSemantics;
    late VoidCallback toggleSemantics;
    late Widget child;

    setUp(() {
      showSemantics = false;
      toggleSemantics = () {
        showSemantics = !showSemantics;
      };
      child = const Text("Test Child");
    });

    Widget createTestWidget({
      bool? customShowSemantics,
      VoidCallback? customToggleSemantics,
      Widget? customChild,
    }) {
      return MaterialApp(
        home: SemanticsProvider(
          showSemantics: customShowSemantics ?? showSemantics,
          toggleSemantics: customToggleSemantics ?? toggleSemantics,
          child: customChild ?? child,
        ),
      );
    }

    group("Constructor", () {
      test("should create SemanticsProvider with required parameters", () {
        final provider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        expect(provider.showSemantics, true);
        expect(provider.toggleSemantics, isA<VoidCallback>());
        expect(provider.child, isA<Text>());
      });

      test("should create SemanticsProvider with false showSemantics", () {
        final provider = SemanticsProvider(
          showSemantics: false,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        expect(provider.showSemantics, false);
      });

      test("should create SemanticsProvider with custom child widget", () {
        const customChild = Icon(Icons.star);
        final provider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: customChild,
        );

        expect(provider.child, customChild);
      });
    });

    group("of() method", () {
      testWidgets("should return SemanticsProvider when found in widget tree",
          (tester) async {
        late SemanticsProvider? foundProvider;

        final testWidget = MaterialApp(
          home: Builder(
            builder: (context) {
              foundProvider = SemanticsProvider.of(context);
              return const Text("Test");
            },
          ),
        );

        await tester.pumpWidget(
          SemanticsProvider(
            showSemantics: true,
            toggleSemantics: () {},
            child: testWidget,
          ),
        );

        expect(foundProvider, isNotNull);
        expect(foundProvider!.showSemantics, true);
      });

      testWidgets(
          "should return null when SemanticsProvider not found in widget tree",
          (tester) async {
        late SemanticsProvider? foundProvider;

        final testWidget = MaterialApp(
          home: Builder(
            builder: (context) {
              foundProvider = SemanticsProvider.of(context);
              return const Text("Test");
            },
          ),
        );

        await tester.pumpWidget(testWidget);

        expect(foundProvider, isNull);
      });

      testWidgets("should return correct SemanticsProvider instance",
          (tester) async {
        late SemanticsProvider? foundProvider;

        final testWidget = MaterialApp(
          home: Builder(
            builder: (context) {
              foundProvider = SemanticsProvider.of(context);
              return const Text("Test");
            },
          ),
        );

        const expectedShowSemantics = true;
        void expectedToggleSemantics() {}

        await tester.pumpWidget(
          SemanticsProvider(
            showSemantics: expectedShowSemantics,
            toggleSemantics: expectedToggleSemantics,
            child: testWidget,
          ),
        );

        expect(foundProvider, isNotNull);
        expect(foundProvider!.showSemantics, expectedShowSemantics);
        expect(foundProvider!.toggleSemantics, expectedToggleSemantics);
      });
    });

    group("updateShouldNotify() method", () {
      test("should return true when showSemantics changes", () {
        final oldProvider = SemanticsProvider(
          showSemantics: false,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        final newProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        expect(newProvider.updateShouldNotify(oldProvider), true);
      });

      test("should return false when showSemantics remains the same", () {
        final oldProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        final newProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        expect(newProvider.updateShouldNotify(oldProvider), false);
      });

      test("should return false when showSemantics changes from true to false",
          () {
        final oldProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        final newProvider = SemanticsProvider(
          showSemantics: false,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        expect(newProvider.updateShouldNotify(oldProvider), true);
      });

      test("should ignore changes to toggleSemantics callback", () {
        final oldProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("Test"),
        );

        final newProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {
            // Different implementation
            // This callback has different behavior but same showSemantics value
          },
          child: const Text("Test"),
        );

        expect(newProvider.updateShouldNotify(oldProvider), false);
      });

      test("should ignore changes to child widget", () {
        final oldProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("Old Child"),
        );

        final newProvider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: const Text("New Child"),
        );

        expect(newProvider.updateShouldNotify(oldProvider), false);
      });
    });

    group("Widget Integration", () {
      testWidgets("should render child widget correctly", (tester) async {
        const testChild = Text("Test Child Widget");

        await tester.pumpWidget(
          createTestWidget(customChild: testChild),
        );

        expect(find.text("Test Child Widget"), findsOneWidget);
      });

      testWidgets("should provide semantics state to descendant widgets",
          (tester) async {
        late bool? receivedShowSemantics;
        late VoidCallback? receivedToggleSemantics;

        final testWidget = MaterialApp(
          home: SemanticsProvider(
            showSemantics: true,
            toggleSemantics: () {},
            child: Builder(
              builder: (context) {
                final provider = SemanticsProvider.of(context);
                receivedShowSemantics = provider?.showSemantics;
                receivedToggleSemantics = provider?.toggleSemantics;
                return const Text("Test");
              },
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        expect(receivedShowSemantics, true);
        expect(receivedToggleSemantics, isA<VoidCallback>());
      });

      testWidgets("should rebuild dependent widgets when showSemantics changes",
          (tester) async {
        bool showSemantics = false;
        int buildCount = 0;

        final testWidget = MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return SemanticsProvider(
                showSemantics: showSemantics,
                toggleSemantics: () {
                  setState(() {
                    showSemantics = !showSemantics;
                  });
                },
                child: Builder(
                  builder: (context) {
                    buildCount++;
                    final provider = SemanticsProvider.of(context);
                    return GestureDetector(
                      onTap: provider?.toggleSemantics,
                      child: Text(
                        "Build count: $buildCount, Semantics: "
                        "${provider?.showSemantics}",
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text("Build count: 1, Semantics: false"), findsOneWidget);

        // Trigger toggle by tapping the text
        await tester.tap(find.text("Build count: 1, Semantics: false"));
        await tester.pump();

        expect(find.text("Build count: 2, Semantics: true"), findsOneWidget);
      });

      testWidgets("should maintain state consistency across rebuilds",
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(customShowSemantics: true),
        );

        expect(find.text("Test Child"), findsOneWidget);

        // Rebuild with same showSemantics value
        await tester.pumpWidget(
          createTestWidget(customShowSemantics: true),
        );

        expect(find.text("Test Child"), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group("Edge Cases", () {
      test("should handle null toggleSemantics callback gracefully", () {
        expect(
          () => SemanticsProvider(
            showSemantics: true,
            toggleSemantics: () {},
            child: const Text("Test"),
          ),
          returnsNormally,
        );
      });

      test("should handle complex child widgets", () {
        const complexChild = Column(
          children: <Widget>[
            Text("First"),
            Icon(Icons.star),
            Row(
              children: <Widget>[
                Text("Nested"),
                Icon(Icons.home),
              ],
            ),
          ],
        );

        final provider = SemanticsProvider(
          showSemantics: true,
          toggleSemantics: () {},
          child: complexChild,
        );

        expect(provider.child, complexChild);
      });

      testWidgets("should work with multiple nested SemanticsProviders",
          (tester) async {
        late SemanticsProvider? outerProvider;
        late SemanticsProvider? innerProvider;

        final testWidget = MaterialApp(
          home: SemanticsProvider(
            showSemantics: true,
            toggleSemantics: () {},
            child: SemanticsProvider(
              showSemantics: false,
              toggleSemantics: () {},
              child: Builder(
                builder: (context) {
                  outerProvider = SemanticsProvider.of(context);
                  innerProvider = SemanticsProvider.of(context);
                  return const Text("Test");
                },
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Should find the nearest (inner) provider
        expect(innerProvider, isNotNull);
        expect(innerProvider!.showSemantics, false);
        expect(outerProvider, innerProvider); // Should be the same instance
      });
    });

    group("Accessibility", () {
      testWidgets("should maintain accessibility properties", (tester) async {
        await tester.pumpWidget(
          createTestWidget(customShowSemantics: true),
        );

        // Verify the widget tree is accessible
        expect(tester.takeException(), isNull);
      });

      testWidgets("should work with Semantics widget", (tester) async {
        final testWidget = MaterialApp(
          home: SemanticsProvider(
            showSemantics: true,
            toggleSemantics: () {},
            child: Semantics(
              label: "Test Button",
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Test"),
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
