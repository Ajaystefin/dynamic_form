import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ControllingLimitNumber extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const ControllingLimitNumber({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final bool isMainLimit = viewModel.subLimit ?? false;

    return LabelWidget(
      label: 'facilities.createFacility.controllingLimitNumber'.tr(),
      isRequired: !isMainLimit,
      child: isMainLimit
          // READ-ONLY field for Main Limit
          ? CustomTextField(
              key: ValueKey(
                  viewModel.facility.controllingLimitNumber ?? ''), // NEW

              maxLength: 8,
              semanticLabel:
                  'facilities.createFacility.controllingLimitNumber'.tr(),
              readOnly: true,
              filled: true,
              initialValue: (!viewModel.showCreateFacilityForm &&
                      viewModel.facilityDetail.isNotEmpty)
                  ? (viewModel.facilityDetail.first.controllingLimitNo)
                  : (viewModel.facility.controllingLimitNumber ?? ""),
            )
          // DROPDOWN for Sub Limit
          : CustomDropdown<Reference>(
              semanticLabel:
                  'facilities.createFacility.controllingLimitNumber'.tr(),
              validationMessage: "common.validation.emptyField".tr(),
              items: viewModel.controllingLimitNumbers,
              selectedItems: [
                // Keep selected item in sync; if not found in list, still show the text
                if ((viewModel.facility.controllingLimitNumber ?? "")
                    .trim()
                    .isNotEmpty)
                  viewModel.controllingLimitNumbers.firstWhere(
                    (r) =>
                        (r.name ?? '').trim() ==
                        viewModel.facility.controllingLimitNumber!.trim(),
                    orElse: () => Reference(
                        name: viewModel.facility.controllingLimitNumber),
                  )
              ],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel.facility.controllingLimitNumber =
                      selectedValue.first.name;
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
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
    );
  }
}
