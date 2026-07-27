import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/features/request/information/security_perfection/state.dart";
import "package:wcas_frontend/features/request/information/security_perfection/widgets/linked_facilities.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";

/// Displays the security perfection table.
class SecurityPerfectionTable extends StatelessWidget {
  /// Creates a [SecurityPerfectionTable] widget.
  const SecurityPerfectionTable({
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
    final hasSelectedSecurity =
        (viewModel.securityDeferral.securityDeferralList ?? [])
            .any((c) => c.selected ?? false);

    return LabelWidget(
      label: "requestInformation.securityPerfection.title".tr(),
      child: CustomRawTable(
        key: ValueKey(state.refreshKey),
        columns: [
          const TableColumn(label: CustomSelectableText(text: "")),
          TableColumn(
            label: Text(
              "requestInformation.securityPerfection.securityNumber".tr(),
            ),
          ),
          TableColumn(
            label: Text(
              "requestInformation.securityPerfection.securityDescription".tr(),
            ),
          ),
          TableColumn(
            label: Text(
              "requestInformation.securityPerfection.securityAmount".tr(),
            ),
          ),
          TableColumn(
            label: addAsteriskIf(
              isRequired: hasSelectedSecurity,
              "requestInformation.securityPerfection.dateLabel".tr(),
            ),
          ),
          //  TableColumn(
          //   label:
          // Text('requestInformation.securityPerfection.dateLabel'.tr()),
          // ),
          TableColumn(
            label: Text("requestInformation.securityPerfection.deferral".tr()),
          ),
        ],
        rows: List.generate(
            (viewModel.securityDeferral.securityDeferralList ?? []).length,
            (index) {
          final info =
              (viewModel.securityDeferral.securityDeferralList ?? [])[index];

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
                  "s",
                  value: checked,
                  index,
                );
              },
            ),
            Text(info.securityNo.toString()),
            Text(info.securityType.toString()),
            Text(info.proposed.toString()),
            if (info.selected ?? false)
              CustomDatePicker(
                initialDateTime: info.dateDeferral,
                blockedDates: const [],
                onSubmit2: (date) {
                  info.dateDeferral = date;
                },
                validator: (value) {
                  if (info.selected =
                      true && (value == null || value.isEmpty)) {
                    return "common.validation.emptyDate".tr();
                  }
                  return null;
                },
              )
            else
              const CustomTextField(
                initialValue: "",
                filled: true,
                readOnly: true,
                fillColor: AppColors.textFieldDisabledFill,
              ),
            attachIcon(isChecked: info.isChecked, viewModel, context, info),
          ];
        }),
      ),
    );
  }

  /// Returns the linked facilities attachment icon.
  Widget attachIcon(
    SecurityPerfectionViewModel viewModel,
    BuildContext context,
    SecurityDeferral info, {
    required bool isChecked,
  }) {
    return Center(
      child: InkWell(
        onTap: () {
          isChecked
              ? //show dialog for given data
              DialogHelper.showCustomDialog(
                  barrierDismissible: false,
                  title:
                      "requestInformation.securityPerfection.linkedFacilities"
                          .tr(),
                  content: LinkedFacilities(viewModel: viewModel, info: info),
                  context: context,
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if ((info.facilityDetails ?? []).isNotEmpty)
                          CustomButton(
                            label: "requestInformation.securityPerfection.save"
                                .tr(),
                            onPressed: () {
                              viewModel.onSavePressedLinkedFacilities(context);
                            },
                          ),
                        if ((info.facilityDetails ?? []).isNotEmpty)
                          const Gap(
                            direction: Axis.horizontal,
                          ),
                        CustomButton(
                          label: "requestInformation.securityPerfection.cancel"
                              .tr(),
                          onPressed: () {
                            // viewModel.onCancelButtonPressed(context);
                            context.pop();
                          },
                        ),
                      ],
                    ),
                  ],
                )
              : logger.i("noclick");
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textFieldBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.attach_file,
            size: 16,
            color: AppColors.buttonBackground,
          ),
        ),
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
