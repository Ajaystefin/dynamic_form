import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';


class LimitDescriptions extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;

  const LimitDescriptions({
    super.key,
 required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final String selectedTypeCode =
        (viewModel.facility.facilityTypeSelectedValue?.reference1 ?? '')
            .trim()
            .toUpperCase();
    final bool isIslamic =
        viewModel.selectedProductTypeOption?.id ==
        ServerConstants.productTypeIslamicID;
    final String fallbackCode = isIslamic ? 'I' : 'C';
    final String codeForDescriptions =
        selectedTypeCode.isNotEmpty ? selectedTypeCode : fallbackCode;

    return LabelWidget(
      label: "facilities.facilitySummary.limitDescription".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.facility.facilityTypeSelectedValue != null,
        items: viewModel.facilityDescriptions
            .where((e) =>
                (e.reference1 ?? "").trim().toUpperCase() == codeForDescriptions)
            .toList(),
        validationMessage: "validation.emptyField".tr(),
        selectedItems: viewModel.facility.facilityDescription == null
            ? null
            : [viewModel.facility.facilityDescription],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facilityTypeDescriptionsSelected(selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: false,
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
