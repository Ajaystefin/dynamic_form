import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Dropdown widget for selecting the application type.
class ApplicationTypeDropdown extends StatelessWidget {
  /// Creates an [ApplicationTypeDropdown] widget.
  const ApplicationTypeDropdown({required this.viewModel, super.key});

  /// View model used to provide application type data and selection handling.
  final RequestInformationViewModel viewModel;

  /// Builds the application type dropdown field.
  @override
  Widget build(BuildContext context) {
    final items = viewModel.applicationTypeItems();
    final selectedItem = viewModel.selectedApplicationType;
    return LabelWidget(
      label: "requestInformation.requestInformation.applicationType".tr(),
      child: CustomDropdown<Reference>(
        key: const ValueKey(
          "requestInformation.requestInformation.applicationType",
        ),
        //Globals.request?.isCreateRequest ??
        isEnabled: false,
        validationMessage: "validation.emptyField".tr(),
        semanticLabel:
            "requestInformation.requestInformation.applicationType".tr(),
        items: items,
        selectedItems: selectedItem == null ? null : [selectedItem],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.onSelectApplicationType(selectedValue.first);
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
