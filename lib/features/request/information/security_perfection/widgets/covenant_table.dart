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

/// Displays the security deferral covenants table.
class CovenantTable extends StatelessWidget {
  /// Creates a [CovenantTable] widget.
  const CovenantTable({
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
    final List<SecurityCovenantCondition> covenants =
        viewModel.securityDeferral.covenant ?? [];
    final bool hasSelectedCovenant = covenants.any((c) => c.isChecked);
    final double rowHeight = covenants.isEmpty
        ? 40
        : covenants
            .map((e) => viewModel.getRowHeight(e.description?.toString() ?? ""))
            .reduce((a, b) => a > b ? a : b);

    return LabelWidget(
      label: "requestInformation.securityPerfection.forCovenant".tr(),
      child: CustomRawTable(
        rowHeight: rowHeight,
        rowTextMaxLineLimit: false,
        key: ValueKey(state.refreshKey),
        columns: [
          const TableColumn(label: Text("")),
          TableColumn(
            label: Text(
              "requestInformation.securityPerfection.covenantNumber".tr(),
            ),
          ),
          TableColumn(
            forcedWidth: 300.w,
            label: Text(
              "requestInformation.securityPerfection.covenantDescription".tr(),
            ),
          ),
          TableColumn(
            label: addAsteriskIf(
              isRequired: hasSelectedCovenant,
              "requestInformation.securityPerfection.covenantDeferral".tr(),
            ),
          ),
        ],
        rows: List.generate((viewModel.securityDeferral.covenant ?? []).length,
            (index) {
          final info = (viewModel.securityDeferral.covenant ?? [])[index];

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
                  "c",
                  value: checked,
                  index,
                ); // triggers rebuild
              },
            ),
            Text(info.number.toString()),
            Text(
              info.description.toString(),
              textAlign: TextAlign.start,
            ),
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

  /// Adds a required-field asterisk to [text] when required.
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
