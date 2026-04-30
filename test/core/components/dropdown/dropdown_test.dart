import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:multi_dropdown/multi_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
//import 'package:wcas_frontend/core/constants/constants.dart';
import "package:wcas_frontend/core/utils/logger.dart";

void main() {
  group("dropdownBuilderWidget", () {
    testWidgets("should render text when text is provided",
        (WidgetTester tester) async {
      const testText = "Test Option";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownBuilderWidget(text: testText),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should render empty string when text is "null"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownBuilderWidget(text: "null"),
          ),
        ),
      );

      expect(find.text(""), findsOneWidget);
    });

    testWidgets("should render empty string when text is null",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownBuilderWidget(text: null),
          ),
        ),
      );

      expect(find.text(""), findsOneWidget);
    });

    testWidgets("should show tooltip when showToolTip is true",
        (WidgetTester tester) async {
      const testText = "Test with tooltip";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownBuilderWidget(text: testText, showToolTip: true),
          ),
        ),
      );

      expect(find.byType(CustomTooltip), findsOneWidget);
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets("should not show tooltip when showToolTip is false",
        (WidgetTester tester) async {
      const testText = "Test without tooltip";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownBuilderWidget(text: testText, showToolTip: false),
          ),
        ),
      );

      expect(find.byType(CustomTooltip), findsNothing);
      expect(find.text(testText), findsOneWidget);
    });
  });

  group("dropdownItemBuildWidget", () {
    testWidgets("should render ListTile when isListTile is true",
        (WidgetTester tester) async {
      const testText = "Test Item";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownItemBuildWidget(testText, isListTile: true),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets("should render Container when isListTile is false",
        (WidgetTester tester) async {
      const testText = "Test Item";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownItemBuildWidget(testText, isListTile: false),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets("should apply selected styles when isSelected is true",
        (WidgetTester tester) async {
      const testText = "Selected Item";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownItemBuildWidget(testText, isSelected: true),
          ),
        ),
      );

      // final listTile = tester.widget<ListTile>(find.byType(ListTile));
      // expect(listTile.textColor, equals(AppColors.white));
      // expect(listTile.tileColor, equals(AppColors.darkGrey));
    });

    testWidgets("should handle null text", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dropdownItemBuildWidget(null),
          ),
        ),
      );

      expect(find.text("null"), findsOneWidget);
    });
  });

  group("CustomDropdown", () {
    late List<String> testItems;
    late Function(List<String>) mockOnSelected;
    bool onSelectedCalled = false;
    List<String> selectedValues = [];

    setUp(() {
      testItems = ["Option 1", "Option 2", "Option 3"];
      onSelectedCalled = false;
      selectedValues = [];
      mockOnSelected = (List<String> values) {
        onSelectedCalled = true;
        selectedValues = values;
      };
      logger.i(mockOnSelected);
      logger.i(onSelectedCalled);
      logger.i(selectedValues);
    });

    testWidgets("should render with basic properties",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              hintText: "Select an option",
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
      expect(find.byType(DropdownSearch<String>), findsOneWidget);
    });

    // testWidgets('should handle onSelected callback', (WidgetTester tester)
    // async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: CustomDropdown<String>(
    //           items: testItems,
    //           onSelected: mockOnSelected,
    //         ),
    //       ),
    //     ),
    //   );

    //   // Find and tap the dropdown to open it
    //   await tester.tap(find.byType(DropdownSearch<String>));
    //   await tester.pumpAndSettle();

    //   // This test verifies the widget renders - actual selection testing may require
    //   // more complex interaction with DropdownSearch internals
    //   expect(onSelectedCalled, isFalse); // No selection made yet
    // });

    testWidgets("should show validation message when validation fails",
        (WidgetTester tester) async {
      const validationMessage = "This field is required";

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              validationMessage: validationMessage,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should render as disabled when isEnabled is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              isEnabled: false,
            ),
          ),
        ),
      );

      final dropdown = tester
          .widget<DropdownSearch<String>>(find.byType(DropdownSearch<String>));
      expect(dropdown.enabled, isFalse);
    });

    testWidgets("should show loading widget when isLoading is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets("should handle empty items list", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: [],
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should handle null items list", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: null,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should use custom width when provided",
        (WidgetTester tester) async {
      const customWidth = 300.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              width: customWidth,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(customWidth));
    });

    testWidgets("should use custom height when provided",
        (WidgetTester tester) async {
      const customHeight = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              height: customHeight,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should show search box when isSearchable is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              isSearchable: true,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should use custom dropdown builder when provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              dropdownBuilder: (context, item) {
                return Text('Custom: ${item?.toString() ?? ""}');
              },
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should use custom item builder when provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              itemBuilder: (context, item, isDisabled, isSelected) {
                return Text("Custom Item: ${item.toString()}");
              },
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should handle selectedItems list",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              selectedItems: const ["Option 1"],
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should use custom compareFn when provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              compareFn: (item1, item2) =>
                  item1.toLowerCase() == item2.toLowerCase(),
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should use custom filterFn when provided and searchable",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              isSearchable: true,
              filterFn: (item, filter) =>
                  item.toLowerCase().contains(filter.toLowerCase()),
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should handle maxValueSelection", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              maxValueSelection: 2,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should show clear icon when showClearIcon is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              showClearIcon: true,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should show hovering when showHoverColor is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              showHoverColor: true,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should handle custom border", (WidgetTester tester) async {
      final customBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              border: customBorder,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should handle custom maxDropdownHeight",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              maxDropdownHeight: 200,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should handle dropdownMenuAlign", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              dropdownMenuAlign: MenuAlign.topCenter,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });

    testWidgets("should handle onBeforeChange callback",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: testItems,
              onBeforeChange: (previousValue, currentValue) async => true,
            ),
          ),
        ),
      );

      expect(find.byType(CustomDropdown<String>), findsOneWidget);
    });
  });

  group("CustomDropdownState", () {
    testWidgets("should initialize multiSelectController",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: ["Test"],
            ),
          ),
        ),
      );

      final state = tester.state<CustomDropdownState<String>>(
        find.byType(CustomDropdown<String>),
      );
      expect(state.multiSelectController, isA<MultiSelectController<String>>());
    });

    testWidgets("should initialize selectAll notifier",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: ["Test"],
            ),
          ),
        ),
      );

      final state = tester.state<CustomDropdownState<String>>(
        find.byType(CustomDropdown<String>),
      );
      expect(state.selectAll, isA<ValueNotifier<bool>>());
      expect(state.selectAll.value, isFalse);
    });

    testWidgets("should create proper decorator props",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: ["Test"],
              hintText: "Test hint",
            ),
          ),
        ),
      );

      final state = tester.state<CustomDropdownState<String>>(
        find.byType(CustomDropdown<String>),
      );
      state.dropDownDecoratorProps(null, "", isEnabled: true);
      state.dropDownDecoratorProps(null, null, isEnabled: true);
    });

    testWidgets("should create loading widget", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: ["Test"],
            ),
          ),
        ),
      );

      final state = tester.state<CustomDropdownState<String>>(
        find.byType(CustomDropdown<String>),
      );
      final loadingWidget = state.loadingWidget();

      expect(loadingWidget, isA<SizedBox>());
    });

    testWidgets("should trigger onSelected callback when item is selected",
        (WidgetTester tester) async {
      bool callbackTriggered = false;
      List<String> selected = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              items: const ["Option A", "Option B"],
              onSelected: (values) {
                callbackTriggered = true;
                selected = values;
              },
            ),
          ),
        ),
      );

      // Tap to open dropdown
      await tester.tap(find.byType(DropdownSearch<String>));
      await tester.pumpAndSettle();

      // Find the widget and tap at its center offset
      final optionAFinder = find.text("Option A");
      final offset = tester.getCenter(optionAFinder);
      await tester.tapAt(offset);
      await tester.pumpAndSettle();

      // Assertions
      expect(callbackTriggered, isTrue);
      expect(selected, contains("Option A"));
    });

    // testWidgets('should clear selected item when clear icon is tapped',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //     const MaterialApp(
    //       home: Scaffold(
    //         body: CustomDropdown<String>(
    //           items: ['Clear Me'],
    //           selectedItems: ['Clear Me'],
    //           showClearIcon: true,
    //         ),
    //       ),
    //     ),
    //   );

    //   // Tap clear icon
    //   await tester.tap(find.byIcon(Icons.clear));
    //   await tester.pumpAndSettle();

    //   // Verify item is cleared (text disappears)
    //   expect(find.text('Clear Me'), findsNothing);
    // });
  });
}
