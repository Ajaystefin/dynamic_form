part of "constants.dart";

/// Application-wide style constants.
class AppStyle {
  /// Default field width.
  static double fieldWidth = 250;

  /// Standard spacing.
  static const double spacing = 10;

  /// Small spacing.
  static const double spacingSmall = 5;

  /// Large spacing.
  static const double spacingLarge = 20;

  /// Form spacing.
  static const double spacingForm = 50;

  /// Column spacing.
  static const double spacingColum = 25;

  /// Bold label style.
  static const TextStyle boldLabel = TextStyle(fontWeight: FontWeight.bold);

  /// Bold error label style.
  static const TextStyle boldErrorLabel = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.alertToastFailure,
  );

  /// Default column name width.
  static const double columnName = 11;

  /// Table header text style.
  static const TextStyle tableHeaderStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 15);

  /// Table suffix header text style.
  static const TextStyle tableSuffixHeaderStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  /// Document name text style.
  static const TextStyle documentNameStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.highlightedTextColor,
  );

  /// Document subtype text style.
  static const TextStyle documentSubTypeStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  /// Highlighted text style.
  static const TextStyle highlightedText = TextStyle(
    fontSize: 12,
    color: AppColors.highlightedTextColor,
  );

  /// Highlighted gray text style.
  static const TextStyle highlightedGrayText = TextStyle(
    fontSize: 12,
    color: AppColors.darkGrey,
  );

  /// Single-row column header height.
  static const double singleRowColumnHeaderHeight = 30;

  /// Group borrowers text field width.
  static const double groupBorrowersTextField = 200;

  /// Group borrowers RIM section width.
  static const double groupBorrowersRimSection = 400;

  /// Custom text editor widget width.
  static const double customTextEditorWidget = 250;

  /// Custom remark editor widget width.
  static const double customTextEditorWidgetForRemark = 700;

  /// Link contract form spacing.
  static const double linkContractFormSpacing = 16;

  /// Link contract proceed button size.
  static const double linkContractProceedButton = 30;

  /// Link contract scope field width.
  static const double linkContractScopeField = 550;

  /// Multi-select dropdown height.
  static const double multiSelectDropdownHeight = 84;

  /// Multi-select dropdown spacing.
  static const double multiSelectDropdownSpacing = 4;

  /// Multi-select dropdown run spacing.
  static const double multiSelectDropdownRunSpacing = 4;

  /// Small font size.
  static const double fontSizeSmall = 12;

  /// Medium font size.
  static const double fontSizeMedium = 14;

  /// Large font size.
  static const double fontSizeLarge = 16;
}

/// Returns a list of application styles used for testing and coverage.
List<dynamic> testStyles() {
  return [
    AppStyle.fieldWidth,
    AppStyle.spacing,
    AppStyle.spacingSmall,
    AppStyle.spacingLarge,
    AppStyle.spacingForm,
    AppStyle.spacingColum,
    AppStyle.boldLabel,
    AppStyle.columnName,
    AppStyle.tableHeaderStyle,
    AppStyle.tableSuffixHeaderStyle,
    AppStyle.singleRowColumnHeaderHeight,
    AppStyle.groupBorrowersTextField,
    AppStyle.groupBorrowersRimSection,
    AppStyle.customTextEditorWidget,
    AppStyle.linkContractFormSpacing,
    AppStyle.linkContractProceedButton,
    AppStyle.linkContractScopeField,
    AppStyle.fontSizeSmall,
    AppStyle.fontSizeMedium,
    AppStyle.fontSizeLarge,
  ];
}
