import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/utils/logger.dart";

void main() {
  group("RowData", () {
    test("creates instance with required parameters", () {
      final rowData = RowData(
        isFilterRow: false,
        id: "1",
        cells: [const Text("Cell 1"), const Text("Cell 2")],
        dropdownValues: ["value1", "value2"],
      );

      expect(rowData.id, "1");
      expect(rowData.cells.length, 2);
      expect(rowData.dropdownValues.length, 2);
      expect(rowData.rowColor, isNull);
    });

    test("creates instance with optional rowColor", () {
      final rowData = RowData(
        isFilterRow: false,
        id: "2",
        cells: [const Text("Cell")],
        dropdownValues: ["value"],
        rowColor: Colors.red,
      );

      expect(rowData.rowColor, Colors.red);
    });
  });

  group("RowModel", () {
    test("creates instance with required widget parameter", () {
      final rowModel = RowModel(
        isFilterRow: false,
        widget: [const Text("Widget 1"), const Text("Widget 2")],
      );

      expect(rowModel.widget.length, 2);
      expect(rowModel.color, isNull);
    });

    test("creates instance with optional color parameter", () {
      final rowModel = RowModel(
        isFilterRow: false,
        widget: [const Text("Widget")],
        color: Colors.blue,
      );

      expect(rowModel.color, Colors.blue);
    });
  });

  group("StackedHeader", () {
    test("creates instance with default values", () {
      final header = StackedHeader();

      expect(header.startIndex, -1);
      expect(header.endIndex, -1);
      expect(header.width, isNull);
      expect(header.widget, isNull);
    });

    test("creates instance with custom values", () {
      const widget = Text("Header");
      final header = StackedHeader(
        startIndex: 0,
        endIndex: 2,
        width: 100,
        widget: widget,
      );

      expect(header.startIndex, 0);
      expect(header.endIndex, 2);
      expect(header.width, 100.0);
      expect(header.widget, widget);
    });

    test("width can be set after creation", () {
      final header = StackedHeader();
      header.width = 150.0;

      expect(header.width, 150.0);
    });
  });

  group("TableColumn", () {
    test("creates instance with default values", () {
      const column = TableColumn(
        label: Text("Column"),
      );

      expect(column.isStacked, false);
      expect(column.width, isNull);
      expect(column.forcedWidth, isNull);
    });

    test("creates instance with custom values", () {
      const column = TableColumn(
        label: Text("Custom Column"),
        width: 200,
        forcedWidth: 180,
        isStacked: true,
        numeric: true,
        tooltip: "Test tooltip",
      );

      expect(column.isStacked, true);
      expect(column.width, 200.0);
      expect(column.forcedWidth, 180.0);
      expect(column.numeric, true);
      expect(column.tooltip, "Test tooltip");
    });

    test("inherits from DataColumn", () {
      const column = TableColumn(label: Text("Column"));
      expect(column, isA<DataColumn>());
    });
  });

  group("TablePagination", () {
    testWidgets("renders pagination controls", (WidgetTester tester) async {
      bool pageChanged = false;
      int newPage = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 0,
              totalPages: 5,
              onPageChanged: (page) {
                pageChanged = true;
                newPage = page;
                logger.i(pageChanged);
                logger.i(newPage);
              },
            ),
          ),
        ),
      );

      expect(find.text("Page 1 of 5"), findsOneWidget);
      expect(find.byIcon(Icons.first_page), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.last_page), findsOneWidget);
    });

    testWidgets("first and previous buttons disabled on first page",
        (WidgetTester tester) async {
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

      final firstPageButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.first_page),
          matching: find.byType(IconButton),
        ),
      );
      final previousButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_left),
          matching: find.byType(IconButton),
        ),
      );

      expect(firstPageButton.onPressed, isNull);
      expect(previousButton.onPressed, isNull);
    });

    testWidgets("last and next buttons disabled on last page",
        (WidgetTester tester) async {
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

      final nextButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(IconButton),
        ),
      );
      final lastButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.last_page),
          matching: find.byType(IconButton),
        ),
      );

      expect(nextButton.onPressed, isNull);
      expect(lastButton.onPressed, isNull);
    });

    testWidgets("calls onPageChanged when buttons are tapped",
        (WidgetTester tester) async {
      int? changedToPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TablePagination(
              currentPage: 2,
              totalPages: 5,
              onPageChanged: (page) => changedToPage = page,
            ),
          ),
        ),
      );

      await tester.tap(
        find.ancestor(
          of: find.byIcon(Icons.first_page),
          matching: find.byType(IconButton),
        ),
      );
      expect(changedToPage, 0);

      await tester.tap(
        find.ancestor(
          of: find.byIcon(Icons.chevron_left),
          matching: find.byType(IconButton),
        ),
      );
      expect(changedToPage, 1);

      await tester.tap(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(IconButton),
        ),
      );
      expect(changedToPage, 3);

      await tester.tap(
        find.ancestor(
          of: find.byIcon(Icons.last_page),
          matching: find.byType(IconButton),
        ),
      );
      expect(changedToPage, 4);
    });
  });

  group("Filter Functions", () {
    test("addFilter adds filter row at correct intervals", () {
      final rows = [
        [const Text("Row 1")],
        [const Text("Row 2")],
        [const Text("Row 3")],
        [const Text("Row 4")],
      ];
      final filterRow = [const Text("Row 3")];

      final result = addFilter(
        rows: rows,
        filterRow: filterRow,
        rowsPerPage: 2,
      );

      expect(result.length, 3);
    });

    test("addFilter removes last filter row if it's at the end", () {
      final rows = [
        [const Text("Row 1")],
        [const Text("Row 2")],
      ];
      final filterRow = [const Text("Filter")];

      final result = addFilter(
        rows: rows,
        filterRow: filterRow,
        rowsPerPage: 2,
      );

      expect(result.length, 2);
      expect(result.last, isNot(filterRow));
    });

    test("addFilterForRowModel adds filter row at correct intervals", () {
      final rows = [
        RowModel(isFilterRow: false, widget: [const Text("Row 1")]),
        RowModel(isFilterRow: false, widget: [const Text("Row 2")]),
        RowModel(isFilterRow: false, widget: [const Text("Row 3")]),
        RowModel(isFilterRow: false, widget: [const Text("Row 4")]),
      ];
      final filterRow =
          RowModel(isFilterRow: false, widget: [const Text("Filter")]);

      final result = addFilterForRowModel(
        rows: rows,
        filterRow: filterRow,
        rowsPerPage: 2,
      );

      expect(result.length, 6);
    });

    test("addFilterForRowModel removes last filter row if it's at the end", () {
      final rows = [
        RowModel(isFilterRow: false, widget: [const Text("Row 1")]),
        RowModel(isFilterRow: false, widget: [const Text("Row 2")]),
      ];
      final filterRow =
          RowModel(isFilterRow: false, widget: [const Text("Filter")]);

      final result = addFilterForRowModel(
        rows: rows,
        filterRow: filterRow,
        rowsPerPage: 2,
      );

      expect(result.length, 3);
      expect(result.last, isNot(filterRow));
    });
  });
}
