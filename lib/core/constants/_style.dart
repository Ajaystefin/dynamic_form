part of 'constants.dart';

class AppStyle {
  static double fieldWidth = 250;
  static const double spacing = 10;
  static const double spacingSmall = 5;
  static const double spacingLarge = 20;
  static const double spacingForm = 50;
  static const double spacingColum = 25;
  static const TextStyle boldLabel = TextStyle(fontWeight: FontWeight.bold);
  static const double columnName = 11;
  static const TextStyle tableHeaderStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
  static const TextStyle tableSuffixHeaderStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
  static const TextStyle documentNameStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AppColors.highlightedTextColor);
  static const TextStyle documentSubTypeStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle highlightedText =
      TextStyle(fontSize: 12,  color: AppColors.highlightedTextColor,);

  static const double singleRowColumnHeaderHeight = 30;
  static const double groupBorrowersTextField = 200; //need to be removed later
  static const double groupBorrowersRimSection = 400; //need to be removed later
  static const double customTextEditorWidget = 250;
  static const double linkContractFormSpacing = 16;
  static const double linkContractProceedButton = 30;
  static const double linkContractScopeField = 550;

  static const double multiSelectDropdownHeight = 100;
  static const double multiSelectDropdownSpacing = 4;
  static const double multiSelectDropdownRunSpacing = 4;

  static const double fontSizeSmall = 12;
  static const double fontSizeMedium = 14;
  static const double fontSizeLarge = 16;
}

void testStyles() {
  AppStyle.fieldWidth;
  AppStyle.spacing;
  AppStyle.spacingSmall;
  AppStyle.spacingLarge;
  AppStyle.spacingForm;
  AppStyle.spacingColum;
  AppStyle.boldLabel;
  AppStyle.columnName;
  AppStyle.tableHeaderStyle;
  AppStyle.tableSuffixHeaderStyle;
  AppStyle.singleRowColumnHeaderHeight;
  AppStyle.groupBorrowersTextField;
  AppStyle.groupBorrowersRimSection;
  AppStyle.customTextEditorWidget;
  AppStyle.linkContractFormSpacing;
  AppStyle.linkContractProceedButton;
  AppStyle.linkContractScopeField;
  AppStyle.fontSizeSmall;
  AppStyle.fontSizeMedium;
  AppStyle.fontSizeLarge;
}
