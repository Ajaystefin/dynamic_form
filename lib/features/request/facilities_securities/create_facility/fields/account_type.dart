import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FacilityAccountType extends StatelessWidget {
  const FacilityAccountType({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.accountType".tr(),
      isEnabled: (!viewModel.isCmoUpdate() ||
              !viewModel.isEditableForProposedByCC()) &&
          viewModel.canEdit,
      isRequired: !viewModel.isFIFlow,
      child: CustomMultiSelectDropdown<Reference>(
        validationMessage:
            viewModel.isFIFlow ? null : "common.validation.emptyField".tr(),
        items: viewModel.accountTypesForUi,
        selectedItems: viewModel.selectedAccountTypes.isEmpty
            ? null
            : viewModel.selectedAccountTypes,
        onSelected: (value) {
          viewModel.selectedAccountTypes = value;
          if (value.isNotEmpty) {
            viewModel.getFacility.accountTypeValue = value.first;
          } else {
            viewModel.getFacility.accountTypeValue = null;
          }
        },
        dropdownBuilder: (context, data) {
          return dropdownMultiItemBuildScrollWidget(
            data,
            (index) => Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelStyle: const TextStyle(fontSize: AppStyle.columnName),
              label: Text("${data?[index].name}"),
            ),
          );
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            minVerticalPadding: 0,
            minTileHeight: 34,
            title: Text(item.name ?? ""),
          );
        },
      ),
    );
  }
}
