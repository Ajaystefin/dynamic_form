import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/sff_checkbox.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

class SffCustomtable extends StatelessWidget {
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
  final List<SffCategory> categories;
  final List<Reference> categoriesLocalDb;
  final Function(int, bool?) onCheckBoxChanged;
  final Function(int, String) onBriefDescChanged;
  final List<TextEditingController> controllers;
  final bool readOnly;
  final EsgCertificationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    // Ensure controller list aligns
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
      autoFitWidth: true,
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

        // initialize controller text if empty
        if (state.briefDesc != null) {
          controller.text = state.briefDesc!;
        }

        return [
          Center(
            child: SffCheckbox(
              isReadOnly: readOnly,
              key: ValueKey("checkbox_$index"),
              value: state.isSelected == true,
              onChanged: (newVal) => onCheckBoxChanged(index, newVal),
            ),
          ),
          Padding(
            padding: EdgeInsets.zero,
            child: Center(child: Text(referenceCategories.name ?? "")),
          ),
          Center(
            // CustomTextArea shows a toast alert and hard-truncates input
            // when the user exceeds 1000 characters.
            child: CustomTextArea(
              readOnly: readOnly,
              key: ValueKey("textField_$index ${viewModel.fieldVersion}"),
              controller: controller,
              maxLines: 2,
              minLines: 2,
              // Enforce 1000-char limit; _MaxLengthAlertFormatter inside
              // CustomTextArea will display an alert on overflow.
              maxLength: 1000,
              initialValue: state.briefDesc?.capitalizeFirstLetter(),
              autoFocus: false,
              validator: (viewModel.isFI)
                  ? null
                  : (value) {
                      if (state.isSelected == true) {
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
