import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/multi_check_box.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

void main() {
  group("DynamicFormMultiCheckBox Tests", () {
    late DynamicField defaultField;
    late Map<String, dynamic> defaultDocument;

    setUp(() {
      defaultField = DynamicField(
        key: "test_multi",
        controlType: FieldType.checkbox,
        label: "Test Multi",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
          Option(key: "opt2", pairValue: "Option 2"),
        ],
      );
      defaultDocument = {};
    });

    Widget createWidget({
      DynamicField? fieldData,
      Map<String, dynamic>? document,
      Function(List<String>)? onChanged,
      Function(List<String>?)? onSaved,
      String? Function(List<String>?)? validation,
      GlobalKey<FormState>? formKey,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: DynamicFormMultiCheckBox(
              fieldData: fieldData ?? defaultField,
              document: document ?? defaultDocument,
              onChanged: onChanged ?? (_) {},
              onSaved: onSaved ?? (_) {},
              validation: validation,
            ),
          ),
        ),
      );
    }

    testWidgets("initializes correctly with empty document",
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      expect(find.text("Test Multi"), findsOneWidget);
      expect(find.byType(CustomCheckbox), findsNWidgets(2));

      // Both options should be unchecked
      final checkboxes = tester
          .widgetList<CustomCheckbox>(find.byType(CustomCheckbox))
          .toList();
      expect(checkboxes[0].value, isFalse);
      expect(checkboxes[1].value, isFalse);
    });

    testWidgets("initializes correctly with existing list data",
        (WidgetTester tester) async {
      final doc = {
        "test_multi": ["opt1"],
      };
      await tester.pumpWidget(createWidget(document: doc));

      final checkboxes = tester
          .widgetList<CustomCheckbox>(find.byType(CustomCheckbox))
          .toList();
      expect(checkboxes[0].value, isTrue); // opt1
      expect(checkboxes[1].value, isFalse); // opt2
    });

    testWidgets("handles document values that are not lists",
        (WidgetTester tester) async {
      final doc = {"test_multi": "opt1"}; // Not a list
      await tester.pumpWidget(createWidget(document: doc));

      final checkboxes = tester
          .widgetList<CustomCheckbox>(find.byType(CustomCheckbox))
          .toList();
      expect(checkboxes[0].value, isFalse);
      expect(checkboxes[1].value, isFalse);
    });

    testWidgets("didUpdateWidget reinitializes if key changes",
        (WidgetTester tester) async {
      final key1 = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormMultiCheckBox(
              key: key1,
              fieldData: defaultField,
              document: const {
                "test_multi": ["opt1"],
              },
              onChanged: (_) {},
              onSaved: (_) {},
            ),
          ),
        ),
      );

      var checkboxes = tester
          .widgetList<CustomCheckbox>(find.byType(CustomCheckbox))
          .toList();
      expect(checkboxes[0].value, isTrue);

      final newField = DynamicField(
        key: "new_multi",
        controlType: FieldType.checkbox,
        label: "Test Multi",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
          Option(key: "opt2", pairValue: "Option 2"),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormMultiCheckBox(
              key: key1,
              fieldData: newField,
              document: const {
                "new_multi": ["opt2"],
              },
              onChanged: (_) {},
              onSaved: (_) {},
            ),
          ),
        ),
      );

      checkboxes = tester
          .widgetList<CustomCheckbox>(find.byType(CustomCheckbox))
          .toList();
      expect(checkboxes[0].value, isFalse);
      expect(checkboxes[1].value, isTrue);
    });

    testWidgets("toggling options triggers onChanged with updated list",
        (WidgetTester tester) async {
      List<String>? changedTo;
      await tester.pumpWidget(
        createWidget(
          onChanged: (val) => changedTo = val,
        ),
      );

      final checkboxes = find.byType(Checkbox);

      // Tap option 1
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      expect(changedTo, equals(["opt1"]));

      // Tap option 2
      await tester.tap(checkboxes.last);
      await tester.pumpAndSettle();

      expect(changedTo, equals(["opt1", "opt2"]));

      // Untap option 1
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      expect(changedTo, equals(["opt2"]));
    });

    testWidgets("form validation fails if required and empty",
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final requiredField = DynamicField(
        key: "required_multi",
        controlType: FieldType.checkbox,
        label: "Required Multi",
        required: true,
        message: "This multi field is required!",
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
        ],
      );

      await tester.pumpWidget(
        createWidget(
          fieldData: requiredField,
          formKey: formKey,
        ),
      );

      // Trigger validation
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text("This multi field is required!"), findsOneWidget);
    });

    testWidgets("form validation fails if required and empty (default message)",
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final requiredField = DynamicField(
        key: "required_multi",
        controlType: FieldType.checkbox,
        label: "Required Multi",
        required: true,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
        ],
      );

      await tester.pumpWidget(
        createWidget(
          fieldData: requiredField,
          formKey: formKey,
        ),
      );

      // Trigger validation
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text("Required Multi is required"), findsOneWidget);
    });

    testWidgets("custom validation function is called",
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        createWidget(
          formKey: formKey,
          validation: (val) => "Custom error from function",
        ),
      );

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text("Custom error from function"), findsOneWidget);
    });

    testWidgets("onSaved callback is triggered correctly",
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      List<String>? savedValues;

      await tester.pumpWidget(
        createWidget(
          document: {
            "test_multi": ["opt1"],
          },
          formKey: formKey,
          onSaved: (val) => savedValues = val,
        ),
      );

      formKey.currentState!.save();
      expect(savedValues, equals(["opt1"]));
    });

    testWidgets("renders CMO field exponent correctly",
        (WidgetTester tester) async {
      final cmoField = DynamicField(
        key: "cmo_multi",
        controlType: FieldType.checkbox,
        label: "CMO Multi",
        required: false,
        isCMOUpdate: true,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(createWidget(fieldData: cmoField));

      final labelWidget = tester.widget<LabelWidget>(find.byType(LabelWidget));
      expect(labelWidget.exponent, "#");
    });

    testWidgets("honors isDisable property for CustomCheckboxes",
        (WidgetTester tester) async {
      final disabledField = DynamicField(
        key: "disabled_multi",
        controlType: FieldType.checkbox,
        label: "Disabled Multi",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: true,
        optionList: [
          Option(key: "opt1", pairValue: "Option 1"),
        ],
      );

      await tester.pumpWidget(createWidget(fieldData: disabledField));

      final checkbox =
          tester.widget<CustomCheckbox>(find.byType(CustomCheckbox));
      expect(checkbox.isEnabled, isFalse);
    });

    testWidgets("no label rendered if label is empty",
        (WidgetTester tester) async {
      final emptyLabelField = DynamicField(
        key: "empty_label",
        controlType: FieldType.checkbox,
        label: "",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(createWidget(fieldData: emptyLabelField));
      expect(find.byType(LabelWidget), findsNothing);
    });

    testWidgets("handles empty optionList gracefully",
        (WidgetTester tester) async {
      final emptyOptionsField = DynamicField(
        key: "empty_options",
        controlType: FieldType.checkbox,
        label: "Empty",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(createWidget(fieldData: emptyOptionsField));
      expect(find.byType(CustomCheckbox), findsNothing);
    });

    testWidgets("option with missing pairValue uses key as label",
        (WidgetTester tester) async {
      final keyOnlyOptionsField = DynamicField(
        key: "key_only_options",
        controlType: FieldType.checkbox,
        label: "Key Only",
        required: false,
        rowData: 0,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "KeyBasedLabel", pairValue: null),
        ],
      );

      await tester.pumpWidget(createWidget(fieldData: keyOnlyOptionsField));
      expect(find.text("KeyBasedLabel"), findsOneWidget);
    });
  });
}
