import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/sff_checkbox.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/esg_certification.dart';

class SffCustomtable extends StatelessWidget {
  final List<SffCategory> categories;
  final List<Reference> categoriesLocalDb;
  final Function(int, bool?) onCheckBoxChanged;
  final Function(int, String) onBriefDescChanged;
  final List<TextEditingController> controllers;
  final bool readOnly;
  const SffCustomtable({
    super.key,
    required this.categories,
    required this.categoriesLocalDb,
    required this.onCheckBoxChanged,
    required this.onBriefDescChanged,
    required this.controllers,
    required this.readOnly,
  });
  @override
  Widget build(BuildContext context) {
    // Ensure controller list aligns
    final paddedControllers = List<TextEditingController>.from(controllers);
    while (paddedControllers.length < categoriesLocalDb.length) {
      paddedControllers.add(TextEditingController(text: ''));
    }

    return CustomRawTable(
      rowHeight: 52,
      key: ValueKey(
        categories
            .map((sffCategoriesList) =>
                '${sffCategoriesList.sffCategory}:${sffCategoriesList.isSelected}')
            .join(';'),
      ),
      autoFitWidth: true,
      columns: [
        TableColumn(
            label: Text('certification.esgCertification.checkBox'.tr())),
        TableColumn(
            forcedWidth: 80,
            label: Text(
                'certification.esgCertification.sustainableFinanceCategory'
                    .tr())),
        TableColumn(
            forcedWidth: 150,
            label:
                Text('certification.esgCertification.briefDescription'.tr())),
      ],
      rows: List.generate(categoriesLocalDb.length, (index) {
        final referenceCategories = categoriesLocalDb[index];
        final state = categories.firstWhere(
          (sffCategoriesList) =>
              sffCategoriesList.sffCategory == referenceCategories.name,
          orElse: () => SffCategory(
              sffCategory: referenceCategories.name,
              isSelected: false,
              briefDesc: ''),
        );
        final controller = paddedControllers[index];

        // initialize controller text if empty
        if (controller.text.isEmpty && state.briefDesc != null) {
          controller.text = state.briefDesc!;
        }

        return [
          Center(
            child: SffCheckbox(
              isReadOnly: readOnly,
              key: ValueKey('checkbox_$index'),
              value: state.isSelected == true,
              onChanged: (newVal) => onCheckBoxChanged(index, newVal),
            ),
          ),
          Padding(
            padding: EdgeInsets.zero,
            child: Center(child: Text(referenceCategories.name ?? '')),
          ),
          Center(
            child: CustomTextField(
              readOnly: readOnly,
              key: ValueKey('textField_$index'),
              controller: controller,
              maxLines: 2,
              minLines: 2,
              initialValue: state.briefDesc?.capitalizeFirstLetter(),
              autoFocus: false,
              validator: (value) {
                if (state.isSelected == true) {
                  final msg =
                      'certification.esgCertification.briefDescRequired'.tr();
                  return CustomValidator.requiredFieldCustomMsg(value, msg);
                }
                return CustomValidator.maxLength(value, 1000);
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
