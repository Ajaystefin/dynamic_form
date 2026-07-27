import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Dropdown field for selecting request status.
class RequestStatusField extends StatelessWidget {
  /// Creates a [RequestStatusField].
  const RequestStatusField({
    required this.viewModel,
    super.key,
    this.width,
  });

  /// View model used to manage advanced search values.
  final AdvancedSearchViewModel viewModel;

  /// Optional width for the field.
  final double? width;

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));

    return LabelWidget(
      key: UniqueKey(),
      isRequired: true,
      label: "dashboard.advancedSearch.requestStatus".tr(),
      child: CustomDropdown<Reference>(
        showClearIcon: false,
        semanticLabel: "dashboard.advancedSearch.requestStatus".tr(),
        key: ValueKey(viewModel.selectedRequestStatus?.id),
        validationMessage: "common.validation.pleaseEnter".tr() +
            "dashboard.advancedSearch.requestStatus".tr(),
        items:
            viewModel.referenceData[ReferenceDataKeys.advanceRequestType] ?? [],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
          );
        },
        onSelected: (selectedValue) {
          viewModel.selectedRequestStatus = selectedValue.first;
        },
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        selectedItems: viewModel.selectedRequestStatus != null
            ? [viewModel.selectedRequestStatus]
            : null,
      ),
    );
  }
}
