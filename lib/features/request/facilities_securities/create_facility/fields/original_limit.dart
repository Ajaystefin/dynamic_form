import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class OriginalLimit extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const OriginalLimit({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.facility.originalLimitCCValue?.name?.isNotEmpty ?? false;

    final bool hasCountryCodes = viewModel.countryCodes.isNotEmpty;
    final Reference? selectedCurrency = viewModel.facility.originalLimitCCValue;
    return LabelWidget(
      label: 'facilities.createFacility.originalLimit'.tr(),
      child: CustomTextField(
          key: ValueKey(viewModel.facility.limitAmount?.description ?? ''),
          readOnly: true,
          prefixIcon: CustomDropdown<Reference>(
            isEnabled: false,
            validationMessage: "validation.emptyField".tr(),
            height: null,
            width: 70.w,
            items: viewModel.countryCodes,
            selectedItems: (selectedCurrency != null)
                ? [selectedCurrency]
                : (hasCountryCodes ? [viewModel.countryCodes.first] : []),
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.facility.originalLimitCCValue = (selectedValue.first);
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
          initialValue: viewModel.showCreateFacilityForm
              ?""
              : (viewModel.facilityDetail.isNotEmpty
                  ? (viewModel.facilityDetail.first.originalLimit?.toString() ?? "")
                  : ""),
          filled: true,
          fillColor: !hasData
              ? AppColors.textFieldDisabledFill
              : AppColors.accordionSecondary,
          onSaved: (String? value) {
            viewModel.facility.originalLimitCCValue?.description = value;
          }),
    );
  }
}
