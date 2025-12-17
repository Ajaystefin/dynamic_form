import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_group.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';


class LimitTypes extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;

  const LimitTypes({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.facilitySummary.limit".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        items: viewModel.selectedProductTypeOption?.id ==
                ServerConstants.productTypeIslamicID
            ? viewModel.facilityTypes
                // .where((e) => (e.reference1 ?? "").trim().toUpperCase() == "I")
                .where((e) {
                  final code = (e.reference1 ?? "").trim().toUpperCase();
                  return code == "I" || code == "B"; 
                })
                .distinctBy((e) => e.reference4?.trim())
                .toList()
            : viewModel.facilityTypes
                .where((e) {
                  final code = (e.reference1 ?? "").trim().toUpperCase();
                  return code == "C" || code == "B"; 
                })
                .distinctBy((e) => e.reference4?.trim())
                .toList(),
        selectedItems: viewModel.facility.facilityTypeSelectedValue == null
            ? null
            : [viewModel.facility.facilityTypeSelectedValue],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.selectLimittedGroup(selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.reference4,
            isSelected: isSelected,
            isListTile: false,
          );
        },
        validationMessage: "validation.emptyField".tr(),
        dropdownBuilder: (context, data) {
          return Text(
            data?.reference4 ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
