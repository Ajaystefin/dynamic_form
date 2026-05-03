import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class SustanabilityClassification extends StatelessWidget {
  const SustanabilityClassification({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final Set<String> selectedIds = (viewModel.facilityDetail.isNotEmpty
            ? viewModel.facilityDetail.first.sustainabilityClassification
            : "")
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    final List<Reference> selectedRefs = viewModel.sustanabilityClassifications
        .where((ref) => selectedIds.contains(ref.id?.toString()))
        .toList();

    return LabelWidget(
      isEnabled: (!viewModel.isCmoUpdate() ||
              !viewModel.isEditableForProposedByCC()) &&
          viewModel.canEdit,
      isRequired: !viewModel.isFIFlow,
      label: "facilities.createFacility.sustanabilityClassification".tr(),
      child: CustomMultiSelectDropdown(
        validationMessage:
            viewModel.isFIFlow ? null : "common.validation.emptyField".tr(),
        selectedItems: selectedRefs,
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
            title: Text(
              item.name ?? "",
            ),
          );
        },
        items: viewModel.sustanabilityClassifications,
        onSelected: (value) {
          viewModel.getFacility.sustainabilityClassification = value;
        },
      ),
    );
  }
}
