import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FiTenor extends StatelessWidget {
  const FiTenor({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isRequired = (ServerConstants.generalTradeGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.dcmGroup == viewModel.getFacility.limitGroup ||
        ServerConstants.bilateralLoanGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.sovergianGroup == viewModel.getFacility.limitGroup);
    return LabelWidget(
      label: "facilities.createFacility.tenor".tr(),
      isRequired: isRequired,
      child: CustomTextField(
        prefixIcon: CustomDropdown<Reference>(
          width: 80.w,
          validationMessage: "validation.emptyField".tr(),
          height: null,
          items: viewModel.period,
          selectedItems: viewModel.getFacility.tenorUnit != null
              ? [viewModel.getFacility.tenorUnit]
              : [viewModel.period.first],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.tenorUnit = (selectedValue.first);
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
        inputFormatters: [
          LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.digitsOnly,
        ],
        initialValue: viewModel.getFacility.tenorValue?.toString() ?? "",
        validator: isRequired ? CustomValidator.requiredField : null,
        onSaved: (String? value) {
          final RegExpMatch? match = RegExp(r"\d+").firstMatch(value ?? "");
          viewModel.getFacility.tenorValue =
              match != null ? int.tryParse(match.group(0)!) : null;
        },
        keyboardType: TextInputType.number,
      ),
    );
  }
}
