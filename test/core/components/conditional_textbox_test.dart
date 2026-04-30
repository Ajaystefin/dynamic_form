import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/conditional_textbox.dart";

void main() {
  group("CustomConditionalTextbox", () {
    testWidgets("starts disabled and enables textbox when checkbox toggled",
        (tester) async {
      String? saved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomConditionalTextbox(
                onSaved: (v) => saved = saved,
                hintText: "Type here",
              ),
            ),
          ),
        ),
      );

      // Initially readOnly
      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);

      // Toggle checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final enabledField = tester.widget<TextField>(find.byType(TextField));
      expect(enabledField.readOnly, isFalse);
    });
  });
}
