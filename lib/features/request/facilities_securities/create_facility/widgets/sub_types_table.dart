import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sub_types_checkbox.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/allocate_limit_dialog_box.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/conditions_dialog_box.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/tenor.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class FacilitySubTypeTable extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  final List<FacilitySubTypes> facilitySubtypes;
  const FacilitySubTypeTable({
    super.key,
    required this.viewModel,
    required this.facilitySubtypes,
  });

  @override
  Widget build(BuildContext context) {
    final bool canClick =
        Utils.isGroupApplication() && viewModel.isAnnualReview;

    final columns = <TableColumn>[
      TableColumn(
        forcedWidth: 140.w,
        label: const Text('Sub types'),
      ),
      TableColumn(
        forcedWidth: 110.w,
        label: const Text('Committment A/c No'),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text('Current Outstanding '),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text('Past Dues'),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text('Existing Limits'),
      ),
      TableColumn(
        forcedWidth: 140.w,
        label: const Text('Proposed Limit'),
      ),
      TableColumn(
        forcedWidth: 200.w,
        label: const Text('Tenor'),
      ),
      TableColumn(
        forcedWidth: 120.w,
        label: const Text('Benchmark'),
      ),
      TableColumn(
        forcedWidth: 200.w,
        label: const Text('Spread/Commission'),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text('Allocate Limits'),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: const Text('Conditions'),
      ),
    ];

    return CustomRawTable(
        key: UniqueKey(),
        columns: columns,
        autoFitWidth: true,
        rowHeight: 50,
        rows: List.generate((facilitySubtypes).length, (index) {
          return [
            SubtypesCheckbox(
              viewModel: viewModel,
              facilitySubType: facilitySubtypes[index],
            ),
            CustomDropdown<String>(
                selectedItems: !viewModel.showCreateFacilityForm
                    ? [viewModel.facilityDetail.first.commitmentAccountNumber]
                    : null,
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {}
                },
                items: viewModel.commitmentAccountNumberItems,
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return dropdownItemBuildWidget(
                    item,
                    isSelected: isSelected,
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data ?? "",
                    style: const TextStyle(fontSize: 14),
                  );
                }),
            CustomTextField(
              initialValue:
                  "${facilitySubtypes[index].currentOutstanding ?? ""}",
            ),
            CustomTextField(
              initialValue: "${facilitySubtypes[index].pastDues ?? ""}",
            ),
            CustomTextField(
              initialValue: "${facilitySubtypes[index].existingAmounts ?? ""}",
            ),
            CustomTextField(
              prefixIcon: CustomDropdown<Reference>(
                validationMessage: "",
                width: 70.w,
                height: null,
                items: viewModel.countryCodes,
                selectedItems: [
                  viewModel.facility.proposedLimitValue ??
                      viewModel.countryCodes.first
                ],
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {
                    viewModel.facility.proposedLimitValue =
                        (selectedValue.first);
                  }
                },
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return dropdownMultiItemBuildWidget(
                    item.name,
                    isSelected: isSelected,
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.name ?? "",
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
              // initialValue: viewModel.facility.proposedLimitValue?.description,
              keyboardType: TextInputType.number,
              onChanged: (String? value) {},
            ),
            //tenor days ---editable
            CustomTextField(
              width: 180.w,
              prefixIcon: CustomDropdown<Reference>(
                width: 120.w,
                height: null,
                items: viewModel.period,
                selectedItems: const [
                  // viewModel.matchOrFirstByName(viewModel.period, f.tenorUnit)
                ],
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {
                    final sel = selectedValue.first;
                    // f.tenorUnit = sel.name;
                    // f.isEdited = true;
                    viewModel.facility.proposedLimitValue =
                        sel; // keep UI binding
                  }
                },
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return dropdownMultiItemBuildWidget(
                    item.name,
                    isSelected: isSelected,
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.name ?? "",
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
              initialValue: "",
              // (f.tenorValue != null) ? "${f.tenorValue}" : "",
              keyboardType: TextInputType.number,
              // validator:
              //     !viewModel.showFacilityFi ? CustomValidator.requiredField : null,
              onChanged: (String? value) {
                // final match = RegExp(r'\d+').firstMatch(value ?? "");
                // f.tenorValue =
                //     match != null ? int.tryParse(match.group(0)!) : null;
                // f.isEdited = true;
              },
            ),

            //benchmark
            //benchmark -------editable
            CustomDropdown<Reference>(
              items: viewModel.benchmark,
              selectedItems: const [
                // viewModel.matchOrFirstById(viewModel.benchmark, f.index)
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  final sel = selectedValue.first;
                  // f.index = sel.id?.toString() ?? sel.name ?? "";
                  // f.isEdited = true;
                  viewModel.facility.proposedLimitValue = sel;
                }
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(
                  item.name,
                  isSelected: isSelected,
                );
              },
              dropdownBuilder: (context, data) {
                return Text(
                  data?.name ?? "",
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),

            //spread -------editable
            CustomTextField(
              width: 150.w,
              prefixIcon: CustomDropdown<Reference>(
                width: 80.w,
                height: null,
                items: viewModel.marginSign,
                selectedItems: const [
                  // viewModel.matchOrFirstByRef1(
                  //     viewModel.marginSign, f.marginSign)
                ],
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {
                    final sel = selectedValue.first;
                    // f.marginSign = sel.reference1;
                    // f.isEdited = true;
                    viewModel.facility.proposedLimitValue = sel;
                  }
                },
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return dropdownMultiItemBuildWidget(
                    item.reference1,
                    isSelected: isSelected,
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.reference1 ?? "",
                    style: const TextStyle(fontSize: 20),
                  );
                },
              ),
              initialValue: "",
              // f.marginValue != null ? "${f.marginValue ?? ''}" : "",
              keyboardType: TextInputType.number,
              onChanged: (String? value) {
                // extract decimal number from a string: "+ 2.5" -> 2.5
                // final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(value ?? "");
                // f.marginValue =
                //     match != null ? num.tryParse(match.group(0)!) : null;
                // f.isEdited = true;
              },
            ),

            TextButton(
              onPressed: canClick
                  ? () {
                      DialogHelper.showCustomDialog(
                        barrierDismissible: false,
                        title: "facilities.createFacility.limitAllocation".tr(),
                        content: BlocProvider.value(
                          value: viewModel,
                          child: AllocateLimitDialogBox(viewModel: viewModel),
                        ),
                        context: context,
                      );
                    }
                  : null, // disables the button when condition is false
              child: const Text(
                "click here",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.darkBlue,
                  fontSize: AppStyle.fontSizeSmall,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                DialogHelper.showCustomDialog(
                  width: 700.w,
                  barrierDismissible: false,
                  title: "facilities.createFacility.limitAllocation".tr(),
                  content: BlocProvider.value(
                    value: viewModel,
                    child: ConditionsDialogBox(
                      viewModel: viewModel,
                    ),
                  ),
                  context: context,
                );
              },
              child: const Text(
                ("click here"),
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkBlue,
                    fontSize: AppStyle.fontSizeSmall),
              ),
            ),
          ];
        }));
  }
}
