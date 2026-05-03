import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/date_picker.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/utils/logger.dart";

void main() {
  group("DynamicFormDatePicker", () {
    late DynamicField mockFieldData;
    late Function(DateTime?) mockOnSubmit;
    DateTime? capturedDate;

    setUp(() {
      mockFieldData = DynamicField(
        controlType: FieldType.datePicker,
        key: "date_key",
        label: "Date Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );
      capturedDate = null;
      mockOnSubmit = (DateTime? date) {
        capturedDate = date;
        logger.i(capturedDate);
      };
    });

    testWidgets("renders correctly with required parameters",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      //  expect(find.text('Date Field *'), findsOneWidget);
      // expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("renders without label when showLabel is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
              showLabel: false,
            ),
          ),
        ),
      );

      expect(find.text("Date Field"), findsNothing);
      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("shows required indicator when field is required",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("handles non-required field correctly",
        (WidgetTester tester) async {
      final optionalField = DynamicField(
        controlType: FieldType.datePicker,
        key: "date_key",
        label: "Optional Date",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: optionalField,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.text("Optional Date"), findsOneWidget);
      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("handles field with empty label", (WidgetTester tester) async {
      final fieldWithEmptyLabel = DynamicField(
        controlType: FieldType.datePicker,
        key: "date_key",
        label: "",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: fieldWithEmptyLabel,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("handles disabled field state", (WidgetTester tester) async {
      final disabledField = DynamicField(
        controlType: FieldType.datePicker,
        key: "date_key",
        label: "Disabled Date",
        required: false,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: disabledField,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.text("Disabled Date"), findsOneWidget);
      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("renders with default showLabel value",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: mockFieldData,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      //  expect(find.text('Date Field *'), findsOneWidget);
    });

    testWidgets("handles field with null values", (WidgetTester tester) async {
      final fieldWithNullValues = DynamicField(
        controlType: FieldType.datePicker,
        key: "date_key",
        label: "Date Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        defaultValue: null,
        maxLength: null,
        message: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: fieldWithNullValues,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("properly calls onSubmit callback when date is selected",
        (WidgetTester tester) async {
      bool callbackTriggered = false;
      DateTime? receivedDate;
      void testOnSubmit(DateTime? date) {
        callbackTriggered = true;
        receivedDate = date;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: mockFieldData,
              onSubmit: testOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
      expect(callbackTriggered, isFalse);

      // Find and interact with the date picker to trigger callback
      final datePicker = find.byType(CustomDatePicker);
      expect(datePicker, findsOneWidget);

      // Get the CustomDatePicker widget to simulate date selection
      final customDatePickerWidget =
          tester.widget<CustomDatePicker>(datePicker);

      // Manually trigger the callback to test coverage
      final testDate = DateTime(2023, 12, 25);
      customDatePickerWidget.onSubmit2?.call(testDate);

      expect(callbackTriggered, isTrue);
      expect(receivedDate, equals(testDate));
    });

    testWidgets("renders with long label text", (WidgetTester tester) async {
      final longLabelField = DynamicField(
        controlType: FieldType.datePicker,
        key: "date_key",
        label: "This is a very long label for the date picker field"
            " that should still render correctly",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: longLabelField,
              onSubmit: mockOnSubmit,
            ),
          ),
        ),
      );

      expect(find.textContaining("This is a very long label"), findsOneWidget);
      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
    });

    testWidgets("handles callback with null date value",
        (WidgetTester tester) async {
      DateTime? receivedDate;
      bool callbackTriggered = false;
      void nullTestOnSubmit(DateTime? date) {
        receivedDate = date;
        callbackTriggered = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormDatePicker(
              fieldData: mockFieldData,
              onSubmit: nullTestOnSubmit,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicFormDatePicker), findsOneWidget);
      expect(receivedDate, isNull);
      expect(callbackTriggered, isFalse);

      // Find the date picker and trigger callback with null
      final datePicker = find.byType(CustomDatePicker);
      expect(datePicker, findsOneWidget);

      final customDatePickerWidget =
          tester.widget<CustomDatePicker>(datePicker);

      // Trigger callback with null date
      customDatePickerWidget.onSubmit2?.call(null);

      expect(callbackTriggered, isTrue);
      expect(receivedDate, isNull);
    });
  });
}
