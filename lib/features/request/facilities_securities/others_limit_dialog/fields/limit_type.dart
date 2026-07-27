import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_group.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and selecting the limit type.
class LimitType extends StatelessWidget {
  /// Creates a limit type widget.
  const LimitType({
    required this.viewModel,
    super.key,
  });

  /// View model containing others limit dialog data and actions.
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isIslamic = viewModel.selectedProductTypeOption?.id ==
        ServerConstants.productTypeIslamicID;

    final List<Reference> limitTypeItems = viewModel.limitTypes
        .where(
          (referenceItem) =>
              (referenceItem.name ?? "").trim().toLowerCase() ==
              (isIslamic ? "islamic" : "conventional"),
        )
        .where((referenceItem) {
          final int? referenceId = referenceItem.id is num
              ? (referenceItem.id! as num).toInt()
              : int.tryParse("${referenceItem.id}");

          final String referenceLabel =
              (referenceItem.reference1 ?? "").trim().toLowerCase();

          final bool isLimitCaps = referenceLabel.contains("limit caps");
          final bool isExcludedLimitCaps =
              (referenceId == ServerConstants.excludedLimit ||
                      referenceId == ServerConstants.excludedLimitCap) &&
                  isLimitCaps;

          return (referenceId != ServerConstants.facilityLinkageLimitCaps) &&
              !isExcludedLimitCaps;
        })
        .distinctBy(
          (referenceItem) =>
              (referenceItem.reference1 ?? "").trim().toUpperCase(),
        )
        .toList();

    return LabelWidget(
      label: "facilities.facilitySummary.limit".tr(),
      isRequired: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown<Reference>(
            showEditIcon: true,
            items: limitTypeItems,
            selectedItems: viewModel.facility.facilityTypeSelectedValue == null
                ? null
                : [viewModel.facility.facilityTypeSelectedValue],

            /// Dropdown selection handling
            onSelected: (selectedValues) {
              if (selectedValues.isNotEmpty) {
                final Reference selectedLimitType = selectedValues.first;
                viewModel.onLimitTypeSelected(selectedLimitType);
              }
            },

            /// Called when user clicks edit icon
            onEditModeActivated: viewModel.activateLimitTypeEditMode,

            /// Called while user types in edit mode
            onTextChanged: viewModel.onLimitTypeEditTextChanged,

            /// Called when user submits / completes edit mode text
            onEditComplete: viewModel.onLimitTypeEditCompleted,

            /// Clears both dropdown value and custom edit text
            onClear: (_) {
              viewModel.clearLimitTypeValue();
            },

            /// Reuse controller from ViewModel so typed value can be tracked
            editController: viewModel.limitTypeEditController,

            itemBuilder: (context, item, {isDisabled, isSelected}) {
              return dropdownItemBuildWidget(
                item.reference1,
                isSelected: isSelected ?? false,
                isListTile: false,
              );
            },

            /// Keep built-in dropdown validation for normal dropdown mode
            validationMessage: "common.validation.emptyField".tr(),

            /// Show selected dropdown label OR custom edit-mode value
            dropdownBuilder: (context, selectedItem) {
              final String displayText = selectedItem?.reference1 ??
                  selectedItem?.name ??
                  viewModel.reference.reference4 ??
                  "";

              return Text(
                displayText,
                style: const TextStyle(fontSize: 14),
              );
            },
          ),

          /// Manual validation message for edit mode
          if (viewModel.showLimitTypeRequiredError) ...[
            const SizedBox(height: 6),
            Text(
              "common.validation.emptyField".tr(),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
