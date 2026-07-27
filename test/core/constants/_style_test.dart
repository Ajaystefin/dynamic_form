import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("AppStyle", () {
    test("spacing constants have correct values", () {
      testStyles();
      expect(AppStyle.spacing, 10);
      expect(AppStyle.spacingSmall, 5);
      expect(AppStyle.spacingLarge, 20);
      expect(AppStyle.spacingForm, 50);
      expect(AppStyle.spacingColum, 25);
    });

    test("text style constants have correct fontWeight and fontSize", () {
      // boldLabel
      const TextStyle bold = AppStyle.boldLabel;
      expect(bold.fontWeight, FontWeight.bold);
      expect(bold.fontSize, isNull);

      // tableHeaderStyle
      const TextStyle header = AppStyle.tableHeaderStyle;
      expect(header.fontWeight, FontWeight.bold);
      expect(header.fontSize, 15);

      // tableSuffixHeaderStyle
      const TextStyle suffix = AppStyle.tableSuffixHeaderStyle;
      expect(suffix.fontWeight, FontWeight.bold);
      expect(suffix.fontSize, 12);
    });

    test("columnName and fieldWidth constants", () {
      expect(AppStyle.columnName, 11);
      expect(AppStyle.fieldWidth, 250);
    });

    test("layout dimension constants", () {
      expect(AppStyle.singleRowColumnHeaderHeight, 30);
      expect(AppStyle.groupBorrowersTextField, 200);
      expect(AppStyle.groupBorrowersRimSection, 400);
      expect(AppStyle.customTextEditorWidget, 250);
      expect(AppStyle.linkContractFormSpacing, 16);
      expect(AppStyle.linkContractProceedButton, 30);
      expect(AppStyle.linkContractScopeField, 550);
    });

    test("font size constants", () {
      expect(AppStyle.fontSizeSmall, 12);
      expect(AppStyle.fontSizeMedium, 14);
      expect(AppStyle.fontSizeLarge, 16);
    });
  });
}
