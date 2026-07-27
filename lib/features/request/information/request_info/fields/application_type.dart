import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Application Type selection field on the
/// Request Information screen.
///
/// Allows users to view or select the application type
/// associated with the current request.
class ApplicationTypeDropdown extends StatelessWidget {
  /// Creates an [ApplicationTypeDropdown].
  const ApplicationTypeDropdown({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages application type selection.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.applicationTypeItems();
    final selectedItem = viewModel.selectedApplicationType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
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
                viewModel.onApplicationTypeSelected(selectedValue.first);
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
        ),
      ],
    );
  }
}
