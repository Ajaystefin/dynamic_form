import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/company_cap_present.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_cap_group_level.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_cap_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_caps_description.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/original_company_cap.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/proposed_company_cap.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/proposed_single_borrower_cap.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class LimitCaps extends StatelessWidget {
  const LimitCaps({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: !Utils.isGroupApplication()
          ? [
              //single borrower
              const Gap(),
              FormRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LimitCapsDescription(viewModel: viewModel),
                  LimitNumber(viewModel: viewModel),
                  LimitCapType(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OriginalCompanyCap(viewModel: viewModel),
                  PresentCompanyCap(viewModel: viewModel),
                  ProposedSingleBorrowerCap(viewModel: viewModel),
                ],
              ),
              const Gap(),
              const Gap(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    label: "common.save".tr(),
                    isLoading: viewModel.state.isSaveLoading,
                    onPressed: viewModel.isApiError
                        ? null
                        : () {
                            viewModel.saveSingleBorrowerLimitCaps(false);
                          },
                  ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  CustomButton(
                    label: "common.saveAndContinue".tr(),
                    isLoading: viewModel.state.isButtonLoading,
                    onPressed: viewModel.isApiError
                        ? null
                        : () {
                            viewModel.saveSingleBorrowerLimitCaps(true);
                          },
                  ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  CustomButton(
                    label: "common.cancel".tr(),
                    onPressed: () {
                      viewModel.cancelOnPressed();
                    },
                  ),
                ],
              ),
            ]
          : [
              //group borrower
              const Gap(),
              FormRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LimitCapsDescription(viewModel: viewModel),
                  LimitNumber(viewModel: viewModel),
                  LimitCapType(viewModel: viewModel),
                ],
              ),
              const Gap(),
              LabelWidget(
                label: "Limit Caps at Entity Level",
                child: CustomRawTable(
                  key: UniqueKey(),
                  columns: getProjectTableColumns(),
                  rows: getProjectTableRows(viewModel: viewModel),
                ),
              ),
              const Gap(),
              FormRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LimitCapGroupLevel(viewModel: viewModel),
                  const SizedBox(),
                  const SizedBox(),
                ],
              ),
              const Gap(),
              FormRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OriginalCompanyCap(viewModel: viewModel),
                  PresentCompanyCap(viewModel: viewModel),
                  ProposedCompanyCap(viewModel: viewModel),
                ],
              ),
              const Gap(),
              const Gap(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    label: "common.save".tr(),
                    isLoading: viewModel.state.isSaveLoading,
                    onPressed: viewModel.isApiError
                        ? null
                        : () {
                            viewModel.saveGroupBorrowerLimitCaps(false);
                          },
                  ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  CustomButton(
                    label: "common.saveAndContinue".tr(),
                    isLoading: viewModel.state.isSaveAndContinueLoading,
                    onPressed: viewModel.isApiError
                        ? null
                        : () {
                            viewModel.saveGroupBorrowerLimitCaps(true);
                          },
                  ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  CustomButton(
                    label: "common.cancel".tr(),
                    onPressed: () {
                      viewModel.cancelOnPressed();
                    },
                  ),
                ],
              ),
            ],
    );
  }
}

List<TableColumn> getProjectTableColumns() {
  return [
    TableColumn(
      forcedWidth: 50.w,
      label: const Text("Customer"),
    ),
    TableColumn(
      forcedWidth: 50.w,
      label: const Text("Original Company Cap"),
    ),
    TableColumn(
      forcedWidth: 50.w,
      label: const Text("Present Company Cap"),
    ),
    TableColumn(
      forcedWidth: 50.w,
      label: const Text("Proposed Company Cap"),
    ),
  ];
}

List<List<Widget>> getProjectTableRows({
  required CreateFacilityViewModel viewModel,
}) {
  final customers = viewModel.limitCapsCustomerList ?? [];

  return List.generate(customers.length, (index) {
    final customer = customers[index];

    final int? rimNo = customer.customerRimNo;
    final String rimStr = rimNo?.toString() ?? "";
    final String original =
        (viewModel.groupCapsOriginalByRim[rimNo] ?? 0).toString();
    final String present =
        (viewModel.groupCapsPresentByRim[rimNo] ?? 0).toString();
    final String amount = viewModel.getGroupCapsAllocationDisplay(rimNo);

    return <Widget>[
      CustomTextField(
        readOnly: true,
        filled: true,
        initialValue: rimStr,
      ),
      CustomTextField(
        readOnly: true,
        filled: true,
        initialValue: original,
      ),
      CustomTextField(
        readOnly: true,
        filled: true,
        initialValue: present,
      ),
      CustomTextField(
        initialValue: amount,
        keyboardType: TextInputType.number,
        errorText: viewModel.groupCapRowError[customer.customerRimNo ?? -1],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ],
        onChanged: (value) {
          viewModel.setGroupCapsAllocation(
            customer.customerRimNo,
            value,
          );
        },
      ),
    ];
  });
}
