import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Cancellation Reason field on the Request Information screen.
///
/// Allows users to view or select the reason for cancelling
/// the current request when applicable.
class CancellationReason extends StatelessWidget {
  /// Creates a [CancellationReason].
  const CancellationReason({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages cancellation reason-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<Reference> items = viewModel.cancellationReason;
    final Reference? selectedItem = viewModel.selectedCancellationReason;
    final bool isValid = viewModel.isNewRequest || viewModel.canEdit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label:
              "requestInformation.requestInformation.cancellationReason".tr(),
          isRequired: true,
          child: CustomDropdown<Reference>(
            isEnabled: isValid,
            validationMessage:
                "requestInformation.requestInformation.requiredField".tr(),
            semanticLabel:
                "requestInformation.requestInformation.cancellationReason".tr(),
            items: items,
            selectedItems: selectedItem == null ? null : [selectedItem],
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.onCancellationSelected(selectedValue.first);
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
