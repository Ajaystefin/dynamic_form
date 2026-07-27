import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Reason for Deferral field on the Request Information screen.
///
/// Allows users to view or select the reason for deferring
/// the current request when applicable.
class ReasonForDeferral extends StatelessWidget {
  /// Creates a [ReasonForDeferral].
  const ReasonForDeferral({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages deferral reason-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<Reference> items = viewModel.reasonForDeferral;

    final int? selectedId = viewModel.selectedDeferralCode?.id ??
        viewModel.applicationDetails?.deferralReasonCode;

    final List<Reference> selectedItems = (selectedId == null)
        ? const <Reference>[]
        : items.where((r) => r.id == selectedId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.reasonForDeferral".tr(),
          isRequired: !viewModel.isFI,
          child: CustomDropdown<Reference>(
            key: const ValueKey(
              "requestInformation.requestInformation.reasonForDeferral",
            ),
            isEnabled: viewModel.canEdit,
            // isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            semanticLabel:
                "requestInformation.requestInformation.reasonForDeferral".tr(),
            validationMessage:
                (viewModel.isFI) ? null : "validation.emptyField".tr(),
            items: items,
            selectedItems: selectedItems,
            onSelected: (selectedValue) {
              if (selectedValue.isNotEmpty) {
                viewModel.onReasonForDeferralSelected(selectedValue.first);
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
