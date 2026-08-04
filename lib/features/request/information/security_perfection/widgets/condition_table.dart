import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/features/request/information/security_perfection/state.dart";
import "package:wcas_frontend/models/request/security_covenant_condition.dart";

/// Displays the security deferral conditions table.
class ConditionTable extends StatelessWidget {
  /// Creates a [ConditionTable] widget.
  const ConditionTable({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used by the widget.
  final SecurityPerfectionViewModel viewModel;

  /// State used by the widget.
  final SecurityPerfectionState state;

  @override
  Widget build(BuildContext context) {
    final List<SecurityCovenantCondition> conditions =
        viewModel.securityDeferral.condition ?? [];
    final bool hasSelectedCondition = conditions.any((c) => c.isChecked);
    final double rowHeight = conditions.isEmpty
        ? 40
        : conditions
            .map((e) => viewModel.getRowHeight(e.description?.toString() ?? ""))
            .reduce((a, b) => a > b ? a : b);

    return LabelWidget(
      label: "requestInformation.securityPerfection.forCondition".tr(),
      child: CustomRawTable(
        rowHeight: rowHeight,
        rowTextMaxLineLimit: false,
        key: ValueKey(state.refreshKey),
        columns: [
          const TableColumn(label: Text("")),
          TableColumn(
            label: Text(
              "requestInformation.securityPerfection.conditionNumber".tr(),
            ),
          ),
          TableColumn(
            forcedWidth: 300.w,
            label: Text(
              "requestInformation.securityPerfection.conditionDescription".tr(),
            ),
          ),
          TableColumn(
            label: addAsteriskIf(
              isRequired: hasSelectedCondition,
              "requestInformation.securityPerfection.conditionDeferral".tr(),
            ),
          ),
        ],
        rows: List.generate((viewModel.securityDeferral.condition ?? []).length,
            (index) {
          final info = (viewModel.securityDeferral.condition ?? [])[index];

          return [
            CustomCheckbox(
              value: info.selected,
              onChange: ({value}) {
                final bool checked = value ?? false;
                // UI field
                info
                  ..isChecked = checked
                  ..selected = checked;
                logger.i(
                  "Checkbox changed at index $index -> "
                  "isChecked=${info.isChecked}, selected=${info.selected}",
                );

                viewModel.updateTableStateChanges(
                  "cd",
                  value: checked,
                  index,
                ); // triggers rebuild
              },
            ),
            Text(info.number.toString()),
            Text(info.description.toString(), textAlign: TextAlign.start),
            if (info.isChecked)
              CustomDatePicker(
                key: UniqueKey(),
                initialDateTime: info.deferralDate,
                blockedDates: const [],
                onSubmit2: (date) {
                  info.deferralDate = date;
                },
                validator: (!viewModel.isFI)
                    ? (value) {
                        if (info.isChecked =
                            true && (value == null || value.isEmpty)) {
                          return "common.validation.emptyDate".tr();
                        }
                        return null;
                      }
                    : null,
              )
            else
              const CustomTextField(
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

  ///
  Widget addAsteriskIf(
    String text, {
    required bool isRequired,
  }) {
    if (!viewModel.isFI) {
      if (viewModel.canEdit) {
        if (!isRequired) {
          return Text(text);
        }
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
