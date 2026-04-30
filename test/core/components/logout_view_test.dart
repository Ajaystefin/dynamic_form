import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/logout_view.dart";
import "package:wcas_frontend/core/constants/constants.dart";

// Mock EasyLocalization extension
extension MockTranslationExtension on String {
  String tr() => this;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("LogoutView", () {
    Widget createLogoutViewWidget() {
      return const MaterialApp(
        home: LogoutView(),
      );
    }

    // Helper to set a default reasonable screen size for tests
    void setDefaultScreenSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
    }

    // ====== UNIT TESTS (No UI rendering) ======
    group("Unit Tests", () {
      test("LogoutView constructor creates instance", () {
        const widget = LogoutView();
        expect(widget, isA<LogoutView>());
        expect(widget.key, isNull);
      });

      test("LogoutView has proper widget properties", () {
        const widget = LogoutView(key: Key("test"));
        expect(widget.key, equals(const Key("test")));
        expect(widget, isA<StatelessWidget>());
      });

      test("LogoutView can be created with super.key", () {
        const widget = LogoutView(key: Key("super-key"));
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

        await tester.pumpWidget(createLogoutViewWidget());

        expect(find.byType(LogoutView), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets("renders Scaffold with proper body structure",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets("applies correct padding based on screen size",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

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

    // ====== WIDGET STRUCTURE VERIFICATION ======
    group("Widget Structure", () {
      testWidgets("creates proper widget hierarchy",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets("column has correct alignment", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

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

        await tester.pumpWidget(createLogoutViewWidget());

        expect(find.byType(Gap), findsNWidgets(3));
      });

      testWidgets("action button row has correct size",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

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

        await tester.pumpWidget(createLogoutViewWidget());

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

        await tester.pumpWidget(createLogoutViewWidget());

        final inkWell = find.byType(InkWell);
        expect(inkWell, findsOneWidget);

        final inkWellWidget = tester.widget<InkWell>(inkWell);
        expect(inkWellWidget.onTap, isNotNull);
      });

      testWidgets("tapping InkWell does not crash",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

        final inkWell = find.byType(InkWell);

        await tester.tap(inkWell);
        await tester.pump();

        expect(find.byType(LogoutView), findsOneWidget);
      });
    });

    // ====== RESPONSIVE LAYOUT TESTS ======
    group("Responsive Layout", () {
      testWidgets("adapts padding for large screen",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(2000, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

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

        await tester.pumpWidget(createLogoutViewWidget());

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
      testWidgets("verifies complete widget tree", (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(LogoutView), findsOneWidget);
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

        await tester.pumpWidget(createLogoutViewWidget());

        final column = tester.widget<Column>(find.byType(Column));
        expect(column.children.length, equals(7));

        expect(column.children[0], isA<Text>());
        expect(column.children[1], isA<Gap>());
        expect(column.children[2], isA<Text>());
        expect(column.children[3], isA<Gap>());
        expect(column.children[4], isA<Text>());
        expect(column.children[5], isA<Gap>());
        expect(column.children[6], isA<InkWell>());
      });
    });

    // ====== ACCESSIBILITY TESTS ======
    group("Accessibility", () {
      testWidgets("InkWell provides proper touch target",
          (WidgetTester tester) async {
        setDefaultScreenSize(tester);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(createLogoutViewWidget());

        final inkWell = find.byType(InkWell);
        expect(inkWell, findsOneWidget);

        final inkWellWidget = tester.widget<InkWell>(inkWell);
        expect(inkWellWidget.onTap, isNotNull);
      });
    });
  });
}
