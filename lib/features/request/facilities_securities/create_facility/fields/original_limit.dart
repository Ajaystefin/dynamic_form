import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class OriginalLimit extends StatelessWidget {
  const OriginalLimit({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.getFacility.originalLimitCCValue?.name?.isNotEmpty ?? false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.originalLimitCCValue;
    return LabelWidget(
      label: "facilities.createFacility.originalLimit".tr(),
      child: CustomTextField(
        key: ValueKey(viewModel.getFacility.limitAmount?.description ?? ""),
        readOnly: true,
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: false,
          validationMessage: "validation.emptyField".tr(),
          height: null,
          width: 70.w,
          items: viewModel.currencyCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.originalLimitCCValue =
                  selectedValue.first;
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
        initialValue: (viewModel.facilityDetail.isNotEmpty
            ? (viewModel.facilityDetail.first.originalLimit?.toString() ?? "")
            : ""),
        filled: true,
        fillColor: !hasData
            ? AppColors.textFieldDisabledFill
            : AppColors.accordionSecondary,
        onSaved: (String? value) {
          viewModel.getFacility.originalLimitCCValue?.description = value ??
              (viewModel.facilityDetail.isNotEmpty
                  ? (viewModel.facilityDetail.first.originalLimit?.toString() ??
                      "")
                  // Read-only: value comes from facility detail,
                  // not from form parameter.
                  : "");
        },
      ),
    );
  }
}
