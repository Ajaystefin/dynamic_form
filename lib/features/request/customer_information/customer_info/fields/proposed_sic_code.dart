import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Proposed SIC code field for the customer information screen.
class ProposedSicCodeFeild extends StatelessWidget {
  /// Creates a proposed SIC code field.
  const ProposedSicCodeFeild({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final String initialValue =
    // viewModel.customerInformation?.proposedSICCode ?? "";
    // final bool isValid = (viewModel.canEdit) ? true :
    // (initialValue.trim().isNotEmpty) ? false : true;
    return LabelWidget(
      isRequired: !viewModel.isFI,
      label:
          "customerInformation.customerInformation.proposedSicCodeFeild".tr(),
      child: CustomDropdown<Reference>(
        key: const ValueKey(
          "customerInformation.customerInformation.proposedSicCodeFeild",
        ),
        semanticLabel:
            "customerInformation.customerInformation.proposedSicCodeFeild".tr(),
        isEnabled: viewModel.canEdit || viewModel.otherCACCPBDPRolesCheck(),
        isSearchable: true,
        validationMessage:
            (viewModel.isFI) ? null : "common.validation.emptyField".tr(),
        items: viewModel.referenceData[ReferenceDataKeys.sicCodeList] ?? [],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            "${item.name} - ${item.description}",
            isSelected: isSelected ?? false,
          );
        },
        filterFn: (Reference item, String filter) {
          return (item.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        onSelected: (selectedValue) {
          viewModel.onSelectPropsedSicCode(selectedValue);
        },
        dropdownBuilder: (context, item) {
          final String description =
              item?.description != null ? " - ${item?.description}" : "";
          return dropdownBuilderWidget(
            text: "${item?.name}$description",
            showToolTip: true,
          );
        },
        selectedItems: viewModel.selectedProposedSicCode != null
            ? [viewModel.selectedProposedSicCode]
            : null,
      ),
    );
  }
}
