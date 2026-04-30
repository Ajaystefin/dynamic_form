import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/logger.dart";

void main() {
  setUpAll(() {
    // Initialize easy_localization for testing
    EasyLocalization.logger.enableLevels = [];
  });

  group("CustomRadioButton Widget Tests", () {
    testWidgets("renders radio buttons with options",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Option 1", "Option 2", "Option 3"],
              selectedValue: "Option 1",
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(Radio<String>), findsNWidgets(3));
      expect(find.text("Option 1"), findsOneWidget);
      expect(find.text("Option 2"), findsOneWidget);
      expect(find.text("Option 3"), findsOneWidget);
    });

    testWidgets("calls onChanged when radio button is tapped",
        (WidgetTester tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["A", "B"],
              selectedValue: "A",
              onChanged: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      // Tap second radio button
      final radios = find.byType(Radio<String>);
      await tester.tap(radios.at(1));
      await tester.pump();
      expect(selectedValue, "B");
    });

    testWidgets("renders single option correctly", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Single Option"],
              selectedValue: "Single Option",
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(Radio<String>), findsOneWidget);
      expect(find.text("Single Option"), findsOneWidget);
    });

    testWidgets("renders empty options with disabled radio",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const [],
              selectedValue: "",
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(Radio<int>), findsOneWidget);
      final radio = tester.widget<Radio<int>>(find.byType(Radio<int>));
      expect(radio.onChanged, isNull); // Should be disabled
    });

    testWidgets("renders horizontally when scrollDirection is horizontal",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["A", "B", "C"],
              selectedValue: "A",
              onChanged: (value) {},
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(Radio<String>), findsNWidgets(3));
    });

    testWidgets("applies custom colors", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Test"],
              selectedValue: "Test",
              onChanged: (value) {},
              selectedColor: Colors.red,
              unselectedColor: Colors.blue,
            ),
          ),
        ),
      );

      final radio = tester.widget<Radio<String>>(find.byType(Radio<String>));
      final fillColor = radio.fillColor;
      expect(fillColor, isNotNull);
    });

    testWidgets("disables radio buttons when isEnabled is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Disabled"],
              selectedValue: "Disabled",
              onChanged: (value) {},
              isEnabled: false,
            ),
          ),
        ),
      );

      final radio = tester.widget<Radio<String>>(find.byType(Radio<String>));
      expect(radio.onChanged, isNull);
    });

    testWidgets(
        "should show tooltip when isRequired is true and has validation error",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Option 1", "Option 2"],
              selectedValue: "Option 1",
              onChanged: (value) {},
              isRequired: true,
            ),
          ),
        ),
      );

      expect(find.byType(CustomTooltip), findsOneWidget);
    });

    testWidgets("should not show tooltip when isRequired is false",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Option 1"],
              selectedValue: "Option 1",
              onChanged: (value) {},
              isRequired: false,
            ),
          ),
        ),
      );

      expect(find.byType(CustomTooltip), findsNothing);
    });

    testWidgets("should handle custom validator function",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Valid", "Invalid"],
              selectedValue: "Invalid",
              onChanged: (value) {},
              validator: (value) {
                if (value == "Invalid") {
                  return "This option is not allowed";
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Just verify the widget accepts a validator function
      expect(find.byType(CustomRadioButton<String>), findsOneWidget);
    });

    testWidgets("should pass validation with valid selection",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomRadioButton<String>(
                options: const ["Valid", "Invalid"],
                selectedValue: "Valid",
                onChanged: (value) {},
                validator: (value) {
                  if (value == "Invalid") {
                    return "This option is not allowed";
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      final form =
          Form.of(tester.element(find.byType(CustomRadioButton<String>)));
      final isValid = form.validate();

      expect(isValid, isTrue);
    });

    testWidgets("should show required field error when nothing selected",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomRadioButton<String?>(
                options: const ["Option 1", "Option 2"],
                selectedValue: null,
                onChanged: (value) {},
                isRequired: true,
              ),
            ),
          ),
        ),
      );

      final form =
          Form.of(tester.element(find.byType(CustomRadioButton<String?>)));
      final isValid = form.validate();

      expect(isValid, isFalse);
    });

    testWidgets("should use custom text style when provided",
        (WidgetTester tester) async {
      const customStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Styled Text"],
              selectedValue: "Styled Text",
              onChanged: (value) {},
              textStyle: customStyle,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text("Styled Text"));
      expect(textWidget.style, equals(customStyle));
    });

    testWidgets("should use custom itemBuilder when provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Custom Item"],
              selectedValue: "Custom Item",
              onChanged: (value) {},
              itemBuilder: (context, option, isSelected, isEnabled) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text("Custom Item"), findsOneWidget);
    });

    testWidgets("should handle error state with custom colors",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String?>(
              options: const ["Option 1"],
              selectedValue: null,
              onChanged: (value) {},
              isRequired: true,
              validator: (value) => "Custom error message",
            ),
          ),
        ),
      );

      // Trigger validation by building the form field
      await tester.pump();

      final radio = tester.widget<Radio<String?>>(find.byType(Radio<String?>));
      final fillColor = radio.fillColor;
      expect(fillColor, isNotNull);
    });

    testWidgets("should apply correct fill colors for different states",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Selected", "Unselected"],
              selectedValue: "Selected",
              onChanged: (value) {},
              selectedColor: Colors.green,
              unselectedColor: Colors.orange,
            ),
          ),
        ),
      );

      final radios =
          tester.widgetList<Radio<String>>(find.byType(Radio<String>));

      for (final radio in radios) {
        expect(radio.fillColor, isNotNull);
      }
    });

    testWidgets("should handle disabled state with null option",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String?>(
              options: const [null, "Valid Option"],
              selectedValue: null,
              onChanged: (value) {},
              isEnabled: false,
            ),
          ),
        ),
      );

      expect(find.text("Disabled"), findsOneWidget);
      expect(find.text("Valid Option"), findsOneWidget);
    });

    testWidgets("should handle FormField integration correctly",
        (WidgetTester tester) async {
      String? savedValue;
      logger.i(savedValue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomRadioButton<String>(
                options: const ["Save Test"],
                selectedValue: "Save Test",
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      final formFields =
          tester.widgetList<FormField<String>>(find.byType(FormField<String>));
      expect(formFields.isNotEmpty, isTrue);
    });

    testWidgets("should trigger onChanged callback with correct value",
        (WidgetTester tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["First", "Second"],
              selectedValue: "First",
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // Tap the second radio button
      final radios = find.byType(Radio<String>);
      await tester.tap(radios.at(1));
      await tester.pump();

      expect(changedValue, equals("Second"));
    });

    testWidgets(
        "should handle ListView for vertical scrolling with multiple options",
        (WidgetTester tester) async {
      final manyOptions = List.generate(10, (index) => "Option ${index + 1}");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: manyOptions,
              selectedValue: "Option 1",
              onChanged: (value) {},
              scrollDirection: Axis.vertical,
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Radio<String>), findsNWidgets(10));
    });

    testWidgets("should handle Wrap for horizontal layout",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String>(
              options: const ["Horizontal 1", "Horizontal 2", "Horizontal 3"],
              selectedValue: "Horizontal 1",
              onChanged: (value) {},
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(Radio<String>), findsNWidgets(3));
    });

    testWidgets("should handle different data types correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<int>(
              options: const [1, 2, 3],
              selectedValue: 2,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.text("1"), findsOneWidget);
      expect(find.text("2"), findsOneWidget);
      expect(find.text("3"), findsOneWidget);
      expect(find.byType(Radio<int>), findsNWidgets(3));
    });

    testWidgets("should maintain state consistency during validation",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomRadioButton<String>(
                options: const ["Valid Choice"],
                selectedValue: "Valid Choice",
                onChanged: (value) {},
                validator: (value) => null, // Always valid
              ),
            ),
          ),
        ),
      );

      final form =
          Form.of(tester.element(find.byType(CustomRadioButton<String>)));
      expect(form.validate(), isTrue);

      // Ensure the widget state is still consistent
      expect(find.text("Valid Choice"), findsOneWidget);
      expect(find.byType(Radio<String>), findsOneWidget);
    });

    testWidgets("should handle tooltip properties correctly",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRadioButton<String?>(
              options: const ["Test"],
              selectedValue: null,
              onChanged: (value) {},
              isRequired: true,
            ),
          ),
        ),
      );

      final tooltip = tester.widget<CustomTooltip>(
        find.byType(CustomTooltip),
      );

      expect(tooltip.decoration, isNotNull);
      expect(tooltip.textStyle, isNotNull);
    });
  });
}
