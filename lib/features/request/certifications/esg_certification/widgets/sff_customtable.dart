import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
// import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/sff_checkbox.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

/// Custom table used to capture Sustainable Finance Framework categories
/// and their brief descriptions.
class SffCustomtable extends StatelessWidget {
  /// Creates an SFF custom table.
  const SffCustomtable({
    required this.categories,
    required this.categoriesLocalDb,
    required this.onCheckBoxChanged,
    required this.onBriefDescChanged,
    required this.controllers,
    required this.readOnly,
    required this.viewModel,
    super.key,
  });

  /// Selected SFF categories and their values.
  final List<SffCategory> categories;

  /// Master category list from local reference data.
  final List<Reference> categoriesLocalDb;

  /// Callback fired when a checkbox selection changes.
  final Function(int, {bool? value}) onCheckBoxChanged;

  /// Callback fired when a brief description changes.
  final Function(int, String) onBriefDescChanged;

  /// Controllers mapped to each category row.
  final List<TextEditingController> controllers;

  /// Indicates whether the table is read-only.
  final bool readOnly;

  /// ESG certification view model.
  final EsgCertificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> paddedControllers =
        List<TextEditingController>.from(controllers);

    while (paddedControllers.length < categoriesLocalDb.length) {
      paddedControllers.add(TextEditingController(text: ""));
    }

    return CustomRawTable(
      rowHeight: 52,
      key: ValueKey(
        categories
            .map(
              (sffCategoriesList) => "${sffCategoriesList.sffCategory}:"
                  "${sffCategoriesList.isSelected}",
            )
            .join(";"),
      ),
      columns: [
        TableColumn(
          label: Text("certification.esgCertification.checkBox".tr()),
        ),
        TableColumn(
          forcedWidth: 80,
          label: Text(
            "certification.esgCertification.sustainableFinanceCategory".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 150,
          label: Text("certification.esgCertification.briefDescription".tr()),
        ),
      ],
      rows: List.generate(categoriesLocalDb.length, (index) {
        final Reference referenceCategories = categoriesLocalDb[index];
        final SffCategory state = categories.firstWhere(
          (sffCategoriesList) =>
              sffCategoriesList.sffCategory == referenceCategories.name,
          orElse: () => SffCategory(
            sffCategory: referenceCategories.name,
            isSelected: false,
            briefDesc: "",
          ),
        );

        final TextEditingController controller = paddedControllers[index];

        if (state.briefDesc != null) {
          controller.text = state.briefDesc!;
        }

        final bool isRowSelected = state.isSelected ?? false;
        final bool isBriefDescReadOnly = readOnly || !isRowSelected;

        return [
          Center(
            child: SffCheckbox(
              isReadOnly: readOnly,
              key: ValueKey("checkbox_$index"),
              value: state.isSelected ?? false,
              onChanged: (newVal) => onCheckBoxChanged(index, value: newVal),
            ),
          ),
          Padding(
            padding: EdgeInsets.zero,
            child: Center(child: Text(referenceCategories.name ?? "")),
          ),
          Center(
            child: CustomTextField(
              readOnly: isBriefDescReadOnly,
              key: ValueKey("textField_$index ${viewModel.fieldVersion}"),
              controller: controller,
              maxLines: 2,
              minLines: 2,
              // Enforce 1000-char limit; _MaxLengthAlertFormatter inside
              // CustomTextArea
              maxLength: 1000,
              initialValue: state.briefDesc?.capitalizeFirstLetter(),
              validator: (viewModel.isFI)
                  ? null
                  : (value) {
                      if (state.isSelected ?? false) {
                        final String msg =
                            "certification.esgCertification.briefDescRequired"
                                .tr();

                        return CustomValidator.requiredFieldCustomMsg(
                          value,
                          msg,
                        );
                      }

                      // maxLength is already enforced by the formatter;
                      // no need to validate it again here.
                      return null;
                    },
              onSaved: (value) =>
                  onBriefDescChanged(index, value!.capitalizeFirstLetter()),
              onChanged: (value) =>
                  onBriefDescChanged(index, value.capitalizeFirstLetter()),
            ),
          ),
        ];
      }),
    );
  }
}
