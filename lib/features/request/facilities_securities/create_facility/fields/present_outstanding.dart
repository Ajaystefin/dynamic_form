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

class PresentOutstanding extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const PresentOutstanding({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.facility.presentOutstandingCCValue?.name?.isNotEmpty ?? false;

    final bool hasCountryCodes = viewModel.countryCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.facility.presentOutstandingCCValue;

    return LabelWidget(
      label: 'facilities.createFacility.presentOutstanding'.tr(),
      child: CustomTextField(
        key: ValueKey(
            viewModel.facility.outstandingAmount?.description ?? ''), // NEW
        readOnly: true,
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: false,
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.countryCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.countryCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.facility.presentOutstandingCCValue =
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
        initialValue: viewModel.showCreateFacilityForm
            ? (viewModel.facility.outstandingAmount?.description ?? "")
            : (viewModel.facilityDetail.isNotEmpty
                ? (viewModel.facilityDetail.first.presentOutstanding?.toString() ?? "")
                : ""),
        filled: true,
        fillColor: !hasData
            ? AppColors.textFieldDisabledFill
            : AppColors.accordionSecondary,

        onSaved: (String? value) {
          viewModel.facility.presentOutstandingCCValue?.description = value;
        },
      ),
    );
  }
}
