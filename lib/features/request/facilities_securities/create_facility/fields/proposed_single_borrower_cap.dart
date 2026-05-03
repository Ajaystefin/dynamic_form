import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ProposedSingleBorrowerCap extends StatelessWidget {
  const ProposedSingleBorrowerCap({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Make the field reset when limitCapType changes by including it in the key
    final String capTypeKey =
        viewModel.getFacility.limitCapType?.toString() ?? "none";
    final bool isRequired = viewModel.isFIFlow ? false : true;
    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCCValue;
    return LabelWidget(
      label: !Utils.isGroupApplication()
          ? "facilities.createFacility.proposedCompanyCap".tr()
          : "facilities.createFacility.proposedGroupCap".tr(),
      isRequired: true,
      child: CustomTextField(
        key: ValueKey("propCap:$capTypeKey"),
        validator: isRequired ? CustomValidator.requiredField : null,
        readOnly: false, // <-- always enabled
        filled: false, // <-- simple
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
          ThousandsSeparatorFormatter(),
        ],
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

        // Keep it simple: show whatever we currently hold in VM
        initialValue: (viewModel.getFacility.proposedLimit != null &&
                viewModel.getFacility.proposedLimit! > 0)
            ? viewModel.getFacility.proposedLimit!.toString()
            : "",
        onChanged: (String? value) {
          final String raw = (value ?? "").replaceAll(",", "").trim();
          viewModel.proposedCapRaw = raw;
          viewModel.proposedCapEdited = true;
          viewModel.getFacility.proposedLimit = int.tryParse(raw);
          viewModel.getFacility.proposedLimitAED =
              viewModel.getFacility.proposedLimit;
        },
      ),
    );
  }
}
