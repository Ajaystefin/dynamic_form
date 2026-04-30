import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";

class ConditionTable extends StatelessWidget {
  const ConditionTable({required this.viewModel, super.key});
  final SecurityPerfectionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final hasSelectedCondition =
        (viewModel.securityDeferral.condition ?? []).any((c) => c.isChecked);

    return LabelWidget(
      label: "requestInformation.securityPerfection.forCondition".tr(),
      child: CustomRawTable(
        key: UniqueKey(),
        columns: [
          const TableColumn(label: Text("")),
          TableColumn(
            label: Text(
              "requestInformation.securityPerfection.conditionNumber".tr(),
            ),
          ),
          TableColumn(
            label: Text(
              "requestInformation.securityPerfection.conditionDescription".tr(),
            ),
          ),
          TableColumn(
            label: addAsteriskIf(
              hasSelectedCondition,
              "requestInformation.securityPerfection.conditionDeferral".tr(),
            ),
          ),
        ],
        rows: List.generate((viewModel.securityDeferral.condition ?? []).length,
            (index) {
          final info = (viewModel.securityDeferral.condition ?? [])[index];

          return [
            CustomCheckbox(
              value: info.isChecked,
              onChange: (value) {
                info.isChecked = value!;
                viewModel.updateTableStateChanges(
                  "cd",
                  value,
                  index,
                ); // triggers rebuild
              },
            ),
            Text(info.number.toString()),
            Text(info.description.toString()),
            info.isChecked
                ? CustomDatePicker(
                    key: UniqueKey(),
                    initialDateTime: info.deferralDate,
                    blockedDates: const [],
                    onSubmit2: (date) {
                      info.deferralDate = date;
                    },
                    validator: CustomValidator.date,
                  )
                : const CustomTextField(
                    initialValue: "",
                    filled: true,
                    readOnly: true,
                    fillColor: AppColors.textFieldDisabledFill,
                  ),
          ];
        }),
      ),
    );
  }

  Widget addAsteriskIf(bool required, String text) {
    if (!viewModel.isFI) {
      if (viewModel.canEdit) {
        if (!required) return Text(text);
        return Text.rich(
          TextSpan(
            text: text,
            children: const [
              TextSpan(text: " *", style: TextStyle(color: AppColors.failure)),
            ],
          ),
          softWrap: true,
        );
      } else {
        return Text(text);
      }
    } else {
      return Text(text);
    }
  }
}
