import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing the facility limit type.
class LimitType extends StatelessWidget {
  /// Creates a limit type widget.
  const LimitType({required this.viewModel, super.key});

  /// View model containing limit type data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isMain = viewModel.subLimit ?? false;

    return LabelWidget(
      label: "facilities.createFacility.limitType".tr(),
      isRequired: !(ServerConstants.fixedIncomeGroup ==
              viewModel.getFacility.limitGroup ||
          ServerConstants.corporateCrossBorderGroup ==
              viewModel.getFacility.limitGroup ||
          ServerConstants.treasuryGroup == viewModel.getFacility.limitGroup),
      child: CustomDropdown<String>(
        semanticLabel: "facilities.createFacility.limitType".tr(),
        isEnabled:
            Globals.request?.applicationSubType == ServerConstants.manualEntry,

        validationMessage: "validation.emptyField".tr(),
        items: viewModel.limitTypeFacility, // ["Main Limit", "Sub Limit"]
        selectedItems: [
          if (isMain) "Main Limit" else "Sub Limit",
        ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.setLimitTypeByLabel(selectedValue.first);
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
