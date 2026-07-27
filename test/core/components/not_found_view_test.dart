import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/not_found_view.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("NotFoundView", () {
    Widget createNotFoundViewWidget() {
      return const MaterialApp(
        home: NotFoundView(),
      );
    }

    // Helper to set a default reasonable screen size for tests
    void setDefaultScreenSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
    }

    // ====== UNIT TESTS (No UI rendering) ======
    group("Unit Tests", () {
      test("NotFoundView constructor creates instance", () {
        const widget = NotFoundView();
        expect(widget, isA<NotFoundView>());
        expect(widget.key, isNull);
      });

      test("NotFoundView has proper widget properties", () {
        const widget = NotFoundView(key: Key("test"));
        expect(widget.key, equals(const Key("test")));
        expect(widget, isA<StatelessWidget>());
      });

      test("NotFoundView can be created with super.key", () {
        const widget = NotFoundView(key: Key("super-key"));
        expect(widget.key, isNotNull);
        expect(widget.key, equals(const Key("super-key")));
      });
    });

    // ====== WIDGET RENDERING TESTS ======
    group("Build Method Coverage", () {
      testWidgets("build method executes successfully without errors",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(find.byType(NotFoundView), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets("renders Scaffold with proper body structure",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets("applies correct padding based on screen size",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final paddingWidget = tester.widget<Padding>(
          find
              .descendant(
                of: find.byType(Scaffold),
                matching: find.byType(Padding),
              )
              .first,
        );

        expect(
          paddingWidget.padding,
          equals(const EdgeInsets.only(left: 240, top: 180)),
        );
      });
    });

    // ====== TEXT AND CONTENT VERIFICATION ======
    group("Content Verification", () {
      testWidgets("displays oops text", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(
          find.text("common.components.notFoundView.oops"),
          findsOneWidget,
        );
      });

      testWidgets("displays not found text", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(
          find.text("common.components.notFoundView.notFound"),
          findsOneWidget,
        );
      });

      testWidgets("displays guide text", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(
          find.text("common.components.notFoundView.guide"),
          findsOneWidget,
        );
      });

      testWidgets("displays action button text", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(
          find.text("common.components.notFoundView.actionButton"),
          findsOneWidget,
        );
      });

      testWidgets("oops text has correct style", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final textWidget = tester
            .widget<Text>(find.text("common.components.notFoundView.oops"));
        expect(textWidget.style?.fontSize, equals(24));
        expect(textWidget.style?.color, equals(AppColors.darkGrey));
        expect(textWidget.style?.fontWeight, equals(FontWeight.w700));
      });

      testWidgets("not found text has correct style",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final textWidget = tester
            .widget<Text>(find.text("common.components.notFoundView.notFound"));
        expect(textWidget.style, equals(AppStyle.boldLabel));
      });

      testWidgets("action button text has correct style",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final textWidget = tester.widget<Text>(
          find.text("common.components.notFoundView.actionButton"),
        );
        expect(textWidget.style?.fontSize, equals(18));
        expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
        expect(textWidget.style?.color, equals(AppColors.primary));
      });
    });

    // ====== WIDGET STRUCTURE VERIFICATION ======
    group("Widget Structure", () {
      testWidgets("creates proper widget hierarchy",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets("column has correct alignment", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final columnWidget = tester.widget<Column>(find.byType(Column));
        expect(columnWidget.mainAxisAlignment, equals(MainAxisAlignment.start));
        expect(
          columnWidget.crossAxisAlignment,
          equals(CrossAxisAlignment.start),
        );
      });

      testWidgets("renders Gap widgets", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(find.byType(Gap), findsNWidgets(3));
      });

      testWidgets("action button row has correct size",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final rowWidget = tester.widget<Row>(
          find.descendant(
            of: find.byType(InkWell),
            matching: find.byType(Row),
          ),
        );
        expect(rowWidget.mainAxisSize, equals(MainAxisSize.min));
      });

      testWidgets("displays chevron icon", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final iconWidget =
            tester.widget<Icon>(find.byIcon(Icons.chevron_right_outlined));
        expect(iconWidget.color, equals(AppColors.primary));
      });
    });

    // ====== INTERACTION TESTS ======
    group("User Interactions", () {
      testWidgets("InkWell is tappable", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final inkWell = find.byType(InkWell);
        expect(inkWell, findsOneWidget);

        final inkWellWidget = tester.widget<InkWell>(inkWell);
        expect(inkWellWidget.onTap, isNotNull);
      });

      testWidgets("tapping InkWell does not crash",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final inkWell = find.byType(InkWell);

        await tester.tap(inkWell);
        await tester.pump();

        expect(find.byType(NotFoundView), findsOneWidget);
      });

      testWidgets("action button area contains both text and icon",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final inkWell = find.byType(InkWell);
        expect(inkWell, findsOneWidget);

        expect(
          find.descendant(
            of: inkWell,
            matching: find.text("common.components.notFoundView.actionButton"),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: inkWell,
            matching: find.byIcon(Icons.chevron_right_outlined),
          ),
          findsOneWidget,
        );
      });
    });

    // ====== RESPONSIVE LAYOUT TESTS ======
    group("Responsive Layout", () {
      testWidgets("adapts padding for large screen",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(2000, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final paddingWidget = tester.widget<Padding>(
          find
              .descendant(
                of: find.byType(Scaffold),
                matching: find.byType(Padding),
              )
              .first,
        );

        expect(
          paddingWidget.padding,
          equals(const EdgeInsets.only(left: 400, top: 320)),
        );
      });

      testWidgets("adapts padding for medium screen",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1600, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final paddingWidget = tester.widget<Padding>(
          find
              .descendant(
                of: find.byType(Scaffold),
                matching: find.byType(Padding),
              )
              .first,
        );

        expect(
          paddingWidget.padding,
          equals(const EdgeInsets.only(left: 320, top: 200)),
        );
      });
    });

    // ====== COMPREHENSIVE COVERAGE TESTS ======
    group("Coverage Verification", () {
      testWidgets("executes all major code paths", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(
          find.text("common.components.notFoundView.oops"),
          findsOneWidget,
        );
        expect(
          find.text("common.components.notFoundView.notFound"),
          findsOneWidget,
        );
        expect(
          find.text("common.components.notFoundView.guide"),
          findsOneWidget,
        );
        expect(
          find.text("common.components.notFoundView.actionButton"),
          findsOneWidget,
        );

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(Gap), findsNWidgets(3));
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_outlined), findsOneWidget);
      });

      testWidgets("all TextStyle properties are applied",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final oopsText = tester
            .widget<Text>(find.text("common.components.notFoundView.oops"));
        expect(oopsText.style?.fontSize, isNotNull);
        expect(oopsText.style?.color, isNotNull);
        expect(oopsText.style?.fontWeight, isNotNull);

        final notFoundText = tester
            .widget<Text>(find.text("common.components.notFoundView.notFound"));
        expect(notFoundText.style, isNotNull);

        final actionText = tester.widget<Text>(
          find.text("common.components.notFoundView.actionButton"),
        );
        expect(actionText.style?.fontSize, isNotNull);
        expect(actionText.style?.fontWeight, isNotNull);
        expect(actionText.style?.color, isNotNull);
      });

      testWidgets("verifies complete widget tree", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(NotFoundView), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.body, isNotNull);
      });
    });

    // ====== EDGE CASES ======
    group("Edge Cases", () {
      testWidgets("column children are in correct order",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final column = tester.widget<Column>(find.byType(Column));
        expect(column.children.length, equals(7));

        expect(column.children[0], isA<Text>());
        expect(column.children[1], isA<Gap>());
        expect(column.children[2], isA<Text>());
        expect(column.children[3], isA<Gap>());
        expect(column.children[4], isA<Text>());
        expect(column.children[5], isA<Gap>());
        final semantics = column.children[6] as Semantics;
        expect(semantics.child, isA<InkWell>());
      });
    });

    // ====== ACCESSIBILITY TESTS ======
    group("Accessibility", () {
      testWidgets("widget tree is semantically correct",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        expect(
          find.text("common.components.notFoundView.oops"),
          findsOneWidget,
        );
        expect(
          find.text("common.components.notFoundView.notFound"),
          findsOneWidget,
        );
        expect(
          find.text("common.components.notFoundView.guide"),
          findsOneWidget,
        );
        expect(
          find.text("common.components.notFoundView.actionButton"),
          findsOneWidget,
        );
      });

      testWidgets("InkWell provides proper touch target",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createNotFoundViewWidget());

        final inkWell = find.byType(InkWell);
        expect(inkWell, findsOneWidget);

        final inkWellWidget = tester.widget<InkWell>(inkWell);
        expect(inkWellWidget.onTap, isNotNull);
      });
    });
  });
}
