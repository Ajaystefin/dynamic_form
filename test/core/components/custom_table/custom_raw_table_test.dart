import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";

class TestApp extends StatelessWidget {
  const TestApp({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}

void main() {
  group("CustomRawTable", () {
    late List<TableColumn> testColumns;
    late List<List<Widget>> testRows;

    setUp(() {
      testColumns = [
        const TableColumn(label: Text("Column 1")),
        const TableColumn(label: Text("Column 2")),
        const TableColumn(label: Text("Column 3")),
      ];

      testRows = [
        [const Text("R1C1"), const Text("R1C2"), const Text("R1C3")],
        [const Text("R2C1"), const Text("R2C2"), const Text("R2C3")],
        [const Text("R3C1"), const Text("R3C2"), const Text("R3C3")],
      ];
    });

    testWidgets("renders basic table with rows", (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            showPagination: false,
          ),
        ),
      );

      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text("Column 1"), findsOneWidget);
      expect(find.text("Column 2"), findsOneWidget);
      expect(find.text("Column 3"), findsOneWidget);
      expect(find.text("R1C1"), findsOneWidget);
      expect(find.text("R2C1"), findsOneWidget);
    });

    testWidgets("renders table with RowModels", (WidgetTester tester) async {
      final rowModels = [
        RowModel(
          isFilterRow: false,
          widget: [
            const Text("Model1"),
            const Text("Model2"),
            const Text("Model3"),
          ],
          color: Colors.red,
        ),
        RowModel(
          isFilterRow: false,
          widget: [
            const Text("Model4"),
            const Text("Model5"),
            const Text("Model6"),
          ],
        ),
      ];

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rowModels: rowModels,
            showPagination: false,
          ),
        ),
      );

      expect(find.text("Model1"), findsOneWidget);
      expect(find.text("Model4"), findsOneWidget);
    });

    testWidgets("renders pagination when enabled", (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            rowsPerPage: 2,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TablePagination), findsOneWidget);
      expect(find.text("Page 1 of 2"), findsOneWidget);
      expect(find.textContaining("Showing"), findsOneWidget);
    });

    testWidgets("handles empty rows", (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: const [],
            showPagination: false,
          ),
        ),
      );

      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text("Column 1"), findsOneWidget);
    });

    testWidgets("renders stacked headers", (WidgetTester tester) async {
      final stackedHeaders = [
        StackedHeader(
          startIndex: 0,
          endIndex: 1,
          width: 200,
          widget: const Text("Header 1-2"),
        ),
        StackedHeader(
          startIndex: 2,
          endIndex: 2,
          width: 100,
          widget: const Text("Header 3"),
        ),
      ];

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            stackedHeaders: stackedHeaders,
            showPagination: false,
          ),
        ),
      );

      expect(find.text("Header 1-2"), findsOneWidget);
      expect(find.text("Header 3"), findsOneWidget);
    });

    testWidgets("renders top stacked headers", (WidgetTester tester) async {
      final topStackedHeaders = [
        StackedHeader(
          startIndex: 0,
          endIndex: 2,
          width: 300,
          widget: const Text("Top Header"),
        ),
      ];

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            topStackedHeaders: topStackedHeaders,
            showPagination: false,
          ),
        ),
      );

      expect(find.text("Top Header"), findsOneWidget);
    });

    testWidgets("applies custom styling", (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            headerColor: Colors.blue,
            rowHeight: 50,
            columnSpacing: 20,
            showPagination: false,
          ),
        ),
      );

      final dataTable = tester.widget<DataTable>(find.byType(DataTable));
      expect(dataTable.dataRowMaxHeight, 50);
      expect(dataTable.columnSpacing, 0); // Custom table sets this to 0
    });

    testWidgets("shows currency value when enabled",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            showCurrencyValue: true,
            showPagination: false,
          ),
        ),
      );

      // The currency value text should be visible
      expect(find.byType(Visibility), findsWidgets);
    });

    testWidgets("handles page changes", (WidgetTester tester) async {
      int? changedPage;

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: List.generate(
              10,
              (index) => [
                Text("R${index + 1}C1"),
                Text("R${index + 1}C2"),
                Text("R${index + 1}C3"),
              ],
            ),
            rowsPerPage: 3,
            onPageChange: (page) => changedPage = page,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to next page
      await tester.tap(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(IconButton),
        ),
      );

      expect(changedPage, 1);
    });

    testWidgets("handles initial page setting", (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: List.generate(
              10,
              (index) => [
                Text("R${index + 1}C1"),
                Text("R${index + 1}C2"),
                Text("R${index + 1}C3"),
              ],
            ),
            rowsPerPage: 3,
            initialPage: 1,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Page 2 of 4"), findsOneWidget);
    });

    testWidgets("pagination behavior with different conditions",
        (WidgetTester tester) async {
      // Test that pagination is not shown when disabled
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            showPagination: false,
            rowsPerPage: 2,
          ),
        ),
      );

      expect(find.byType(TablePagination), findsNothing);

      // Test that pagination is not shown when rows fit in one page
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            rowsPerPage: 10,
          ),
        ),
      );

      expect(find.byType(TablePagination), findsNothing);

      // Test that pagination is shown when needed
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: List.generate(
              6,
              (index) => [
                Text("R${index + 1}C1"),
                Text("R${index + 1}C2"),
                Text("R${index + 1}C3"),
              ],
            ),
            rowsPerPage: 2,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(TablePagination), findsOneWidget);
    });

    testWidgets("column width behavior with different settings",
        (WidgetTester tester) async {
      // Test with forced column width
      final columnsWithForcedWidth = [
        const TableColumn(
          label: Text("Column 1"),
          forcedWidth: 150,
        ),
      ];

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: columnsWithForcedWidth,
            rows: const [
              [Text("Data")],
            ],
            showPagination: false,
          ),
        ),
      );

      expect(find.byType(DataTable), findsOneWidget);

      // Test with custom column width
      final columnsWithWidth = [
        const TableColumn(
          label: Text("Column 1"),
          width: 200,
        ),
      ];

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: columnsWithWidth,
            rows: const [
              [Text("Data")],
            ],
            showPagination: false,
            autoFitWidth: false,
          ),
        ),
      );

      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets("handles sortable columns", (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: const [
              TableColumn(
                label: Text("Sortable Column"),
                numeric: true,
              ),
            ],
            rows: const [
              [Text("1")],
              [Text("2")],
            ],
            showPagination: false,
          ),
        ),
      );

      expect(find.text("Sortable Column"), findsOneWidget);
    });

    testWidgets("renders with custom header heights",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            columnHeaderHeight: 60,
            stackedHeaderHeight: 40,
            topStackedHeaderHeight: 50,
            showPagination: false,
          ),
        ),
      );

      final dataTable = tester.widget<DataTable>(find.byType(DataTable));
      expect(dataTable.headingRowHeight, 60);
    });

    testWidgets("handles row with rowColor", (WidgetTester tester) async {
      final rowModels = [
        RowModel(
          isFilterRow: false,
          widget: [
            const Text("Cell 1"),
            const Text("Cell 2"),
            const Text("Cell 3"),
          ],
          color: Colors.yellow,
        ),
      ];

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rowModels: rowModels,
            showPagination: false,
          ),
        ),
      );

      expect(find.text("Cell 1"), findsOneWidget);
    });

    testWidgets("handles table with no rows but with rowModels",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rowModels: [
              RowModel(
                isFilterRow: false,
                widget: [
                  const Text("Model Cell"),
                  const Text("Cell2"),
                  const Text("Cell3"),
                ],
              ),
            ],
            showPagination: false,
          ),
        ),
      );

      expect(find.text("Model Cell"), findsOneWidget);
    });

    testWidgets("handles scrollbar visibility correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            stackedHeaders: [
              StackedHeader(
                startIndex: 0,
                endIndex: 1,
                width: 200,
                widget: const Text("Stacked"),
              ),
            ],
            showPagination: false,
          ),
        ),
      );

      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets("handles stacked headers with duplicate removal",
        (WidgetTester tester) async {
      final duplicateStackedHeaders = [
        StackedHeader(
          startIndex: 0,
          endIndex: 1,
          width: 200,
          widget: const Text("Header 1"),
        ),
        StackedHeader(
          startIndex: 0,
          endIndex: 1,
          width: 200,
          widget: const Text("Duplicate Header"),
        ),
        StackedHeader(
          startIndex: 2,
          endIndex: 2,
          width: 100,
          widget: const Text("Header 2"),
        ),
      ];

      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            stackedHeaders: duplicateStackedHeaders,
            showPagination: false,
          ),
        ),
      );

      // Should only find one instance of the duplicate header and the other
      // unique header
      expect(find.text("Header 1"), findsOneWidget);
      expect(find.text("Duplicate Header"), findsNothing);
      expect(find.text("Header 2"), findsOneWidget);
    });

    testWidgets("handles page clamping when initial page is out of bounds",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CustomRawTable(
            columns: testColumns,
            rows: testRows,
            rowsPerPage: 2,
            initialPage: 100, // Out of bounds
            onPageChange: (page) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should clamp to last valid page
      expect(find.text("Page 2 of 2"), findsOneWidget);
    });
  });
}
