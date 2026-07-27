import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// IFRS staging dropdown field for the customer information screen.
class IfrsStaging extends StatelessWidget {
  /// Creates an IFRS staging field.
  const IfrsStaging({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "customerInformation.customerInformation.ifrsStaging".tr(),
      child: CustomDropdown<Reference>(
        key: const ValueKey(
          "customerInformation.customerInformation.ifrsStaging",
        ),
        semanticLabel:
            "customerInformation.customerInformation.ifrsStaging".tr(),
        isEnabled: viewModel.canEdit,
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.referenceData[ReferenceDataKeys.ifrsStaging] ?? [],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        onSelected: (selectedValue) {
          viewModel.customerInformation?.ifrsStaging = selectedValue[0].name;
          viewModel.selectedIfrsStaging = selectedValue.first;
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        selectedItems: viewModel.selectedIfrsStaging != null
            ? [viewModel.selectedIfrsStaging]
            : null,
      ),
    );
  }
}
