import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilityProposedByCC extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityProposedByCC({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // final bool hasData =
    //     viewModel.facility.proposedLimitValue?.toString().isNotEmpty ?? false;
    final bool hasCountryCodes = viewModel.countryCodes.isNotEmpty;
    final Reference? selectedCurrency = viewModel.facility.originalLimitCCValue;
    return LabelWidget(
      label: 'facilities.createFacility.proposedByCC'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: false,
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.countryCodes,
          // selectedItems: [
          //   viewModel.facility.proposedByCC ?? viewModel.countryCodes.first
          // ],
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.countryCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.facility.proposedByCC = (selectedValue.first);
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
        initialValue: (!viewModel.showCreateFacilityForm &&
                viewModel.facilityDetail.isNotEmpty)
            ? (viewModel.facilityDetail.first.proposedByCc?.toString() ?? "")
            : "",
        filled: true, //hasdata
        readOnly: true,
        // fillColor: !hasData
        //     ? AppColors.textFieldDisabledFill
        //     : AppColors.accordionSecondary,
        validator //: hasData ? null
            : CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.facility.proposedByCC?.description = value;
        },
      ),
    );
  }
}
