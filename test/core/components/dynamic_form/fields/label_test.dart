import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/label.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  Widget createTestWidget({required DynamicField fieldData}) {
    return MaterialApp(
      home: Scaffold(
        body: DynamicFormLabelField(fieldData: fieldData),
      ),
    );
  }

  group("DynamicFormLabelField", () {
    testWidgets("renders the label correctly with correct styles",
        (tester) async {
      final fieldData = DynamicField(
        controlType: FieldType.label,
        key: "testLabelField",
        label: "Section Header Label",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      await tester.pumpWidget(createTestWidget(fieldData: fieldData));

      final textFinder = find.text("Section Header Label");
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, AppStyle.fontSizeLarge);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.color, AppColors.primary);

      // Verify padding
      final paddingFinder =
          find.ancestor(of: textFinder, matching: find.byType(Padding));
      expect(paddingFinder, findsWidgets);

      final paddingWidget = tester.widget<Padding>(paddingFinder.first);
      expect(
        paddingWidget.padding,
        const EdgeInsets.only(top: 8, bottom: 8),
      );
    });
  });
}
