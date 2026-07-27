import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Trade licence issuing authority field for the customer information screen.
class TradeLicenceIssuingAuthorityField extends StatelessWidget {
  /// Creates a trade licence issuing authority field.
  const TradeLicenceIssuingAuthorityField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final String initialValue =
    //     viewModel.customerInformation?.tlIssuingAuthority ?? "";
    // final bool isValid = viewModel.canEdit && initialValue.trim().isNotEmpty;
    return LabelWidget(
      label: "customerInformation.customerInformation.tlIssuingAuthority".tr(),
      child: CustomDropdown<Reference>(
        key: const ValueKey(
          "customerInformation.customerInformation.tlIssuingAuthority",
        ),
        semanticLabel:
            "customerInformation.customerInformation.tlIssuingAuthority".tr(),
        isEnabled: viewModel.canEdit,
        items:
            viewModel.referenceData[ReferenceDataKeys.tlIssuingAuthorityList] ??
                [],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: false,
            isSelected: isSelected ?? false,
          );
        },
        onSelected: (selectedValue) {
          viewModel.customerInformation?.tlIssuingAuthority =
              selectedValue[0].name;
          viewModel.selectedTlIssuingAuthority = selectedValue.first;
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: true),
        selectedItems: viewModel.selectedTlIssuingAuthority != null
            ? [viewModel.selectedTlIssuingAuthority]
            : null,
      ),
    );
  }
}
