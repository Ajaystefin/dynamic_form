import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("AppColors", () {
    test("all color constants have the expected values", () {
      // Primary and secondary
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.secondary, isA<Color>());
      expect(AppColors.scaffoldBackground, isA<Color>());
      expect(AppColors.scaffoldBorder, isA<Color>());
      expect(AppColors.loginBackground, isA<Color>());
      expect(AppColors.failure, isA<Color>());
      expect(AppColors.alertToastFailure, isA<Color>());
      expect(AppColors.alertToastSuccess, isA<Color>());
      expect(AppColors.failureLogin, isA<Color>());
      expect(AppColors.success, isA<Color>());
      expect(AppColors.warning, isA<Color>());
      expect(AppColors.mediumGreen, isA<Color>());
      expect(AppColors.goldenYellow, isA<Color>());
      expect(AppColors.white, isA<Color>());
      expect(AppColors.lightGoldenYellow, isA<Color>());
      expect(AppColors.darkTooltip, isA<Color>());
      expect(AppColors.defaultTextColor, isA<Color>());
      expect(AppColors.dialogHeaderColor, isA<Color>());
      expect(AppColors.dialogTitleColor, isA<Color>());
      expect(AppColors.darkBlue, isA<Color>());
      expect(AppColors.darkGreen, isA<Color>());
      expect(AppColors.lightBlue, isA<Color>());
      expect(AppColors.lightWarning, isA<Color>());
      expect(AppColors.lightSuccess, isA<Color>());
      expect(AppColors.lightFailure, isA<Color>());
      expect(AppColors.textFieldColor, isA<Color>());
      expect(AppColors.textFieldBorder, isA<Color>());
      expect(AppColors.textFieldDisabledFill, isA<Color>());
      expect(AppColors.buttonBackground, isA<Color>());
      expect(AppColors.disabledButton, isA<Color>());
      expect(AppColors.accordionPrimary, isA<Color>());
      expect(AppColors.accordionSecondary, isA<Color>());
      expect(AppColors.black, isA<Color>());
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.tableActivatedColor, isA<Color>());
      expect(AppColors.tableActivatedColor, isA<Color>());
      expect(AppColors.tableCellColorGroupedRow, isA<Color>());
      expect(AppColors.highlightedTextColor, isA<Color>());
      expect(AppColors.tableBackgroundColor, isA<Color>());
      expect(AppColors.tableHeadingColor, isA<Color>());
      expect(AppColors.tablefontColor, isA<Color>());
      expect(AppColors.overdueColor, isA<Color>());
      expect(AppColors.darkGrey, isA<Color>());
      expect(AppColors.highlightedTextColor, isA<Color>());
      expect(AppColors.customToolTipBg, isA<Color>());
      expect(AppColors.institutional, isA<Color>());
      expect(AppColors.business, isA<Color>());
      expect(AppColors.corporate, isA<Color>());
      expect(AppColors.otherBusinessSegment, isA<Color>());
      expect(AppColors.applicationOverdue, isA<Color>());
      expect(AppColors.dueForReview, isA<Color>());
      expect(AppColors.recentApplication, isA<Color>());
      expect(AppColors.applicationSegment, isA<Color>());
      expect(AppColors.applicationSegment, isA<Color>());
      expect(AppColors.financialInstitutionCF, isA<Color>());
      expect(AppColors.limeGreen, isA<Color>());
      expect(AppColors.teal, isA<Color>());
    });
  });
}
