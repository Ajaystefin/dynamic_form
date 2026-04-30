import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class PresentCompanyCap extends StatelessWidget {
  const PresentCompanyCap({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.getFacility.presentOutstandingCCValue?.name?.isNotEmpty ??
            false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCCValue;

// NEW: derive the text we show (so we can also feed it into the key)
    final String presentValue = (viewModel.facilityDetail.isNotEmpty)
        ? (viewModel.facilityDetail.first.presentLimit?.toString() ?? "")
        : "";

    return LabelWidget(
      label: !Utils.isGroupApplication()
          ? "facilities.createFacility.presentCompanyCap".tr()
          : "facilities.createFacility.presentGroupCap".tr(),
      child: CustomTextField(
        key:
            ValueKey('presCap:${presentValue}_${selectedCurrency?.name ?? ""}'),
        // NEW
        readOnly: true,
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: false,
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.presentOutstandingCCValue =
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

        // Use the same computed value for the field text
        initialValue: presentValue,

        filled: true,
        fillColor: !hasData
            ? AppColors.textFieldDisabledFill
            : AppColors.accordionSecondary,

        onSaved: (String? value) {
          viewModel.getFacility.presentOutstandingCCValue?.description = value;
        },
      ),
    );
  }
}
