import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CommonCurrencyConvertField extends StatelessWidget {
  const CommonCurrencyConvertField({
    required this.viewModel,
    required this.textController,
    super.key,
  });
  final CreateFacilityViewModel viewModel;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      inputFormatters: [
        LengthLimitingTextInputFormatter(15),
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorFormatter(),
      ],
      controller: textController,
      prefixIcon: CustomDropdown<Reference>(
        width: 70.w,
        validationMessage: "validation.emptyField".tr(),
        height: null,
        items: viewModel.currencyCodes,
        selectedItems: [
          viewModel.currencyCodes
              .where((code) => code.name == ServerConstants.aedCurrency)
              .first,
        ],
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
      readOnly: true,
      filled: true,
      initialValue: "0",
    );
  }
}
