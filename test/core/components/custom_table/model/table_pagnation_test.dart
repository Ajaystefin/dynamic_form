import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";

/// ------------------------------------------------------
/// MOCK EasyLocalization .tr()
/// ------------------------------------------------------
extension MockTranslationExtension on String {
  String tr() => this;
}

void main() {
  group("TablePagination", () {
    testWidgets("renders page text correctly", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 0,
              totalPages: 5,
              onPageChanged: _noop,
            ),
          ),
        ),
      );

      expect(find.text("Page 1 of 5"), findsOneWidget);
    });

    testWidgets("first and previous buttons are disabled on first page",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 0,
              totalPages: 5,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      final iconButtons =
          tester.widgetList<IconButton>(find.byType(IconButton)).toList();

      // first_page & previous_page
      expect(iconButtons[0].onPressed, isNull);
      expect(iconButtons[1].onPressed, isNull);

      // next & last should be enabled
      expect(iconButtons[2].onPressed, isNotNull);
      expect(iconButtons[3].onPressed, isNotNull);
    });

    testWidgets("next and last buttons are disabled on last page",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 4,
              totalPages: 5,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      final iconButtons =
          tester.widgetList<IconButton>(find.byType(IconButton)).toList();

      // first & previous enabled
      expect(iconButtons[0].onPressed, isNotNull);
      expect(iconButtons[1].onPressed, isNotNull);

      // next & last disabled
      expect(iconButtons[2].onPressed, isNull);
      expect(iconButtons[3].onPressed, isNull);
    });

    testWidgets("tapping first page triggers callback with page 0",
        (tester) async {
      int? changedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 3,
              totalPages: 5,
              onPageChanged: (page) => changedPage = page,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.first_page));
      await tester.pump();

      expect(changedPage, 0);
    });

    testWidgets("tapping previous page decrements page", (tester) async {
      int? changedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 3,
              totalPages: 5,
              onPageChanged: (page) => changedPage = page,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(changedPage, 2);
    });

    testWidgets("tapping next page increments page", (tester) async {
      int? changedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 2,
              totalPages: 5,
              onPageChanged: (page) => changedPage = page,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(changedPage, 3);
    });

    testWidgets("tapping last page jumps to final page", (tester) async {
      int? changedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 1,
              totalPages: 5,
              onPageChanged: (page) => changedPage = page,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.last_page));
      await tester.pump();

      expect(changedPage, 4);
    });

    testWidgets("semantic labels are present", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 0,
              totalPages: 3,
              onPageChanged: _noop,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel("semantics.table.firstPage"),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel("semantics.table.previousPage"),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel("semantics.table.nextPage"),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel("semantics.table.lastPage"),
        findsOneWidget,
      );
    });
  });
}

/// Dummy callback
void _noop(int _) {}
