import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FacilityCommitted extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityCommitted({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.committed'.tr(),
      isRequired: (!viewModel.showFacilityFi),
      child: CustomDropdown<Reference>(
        validationMessage:
            (!viewModel.showFacilityFi) ? "common.validation.emptyField".tr() : null,
        semanticLabel: 'facilities.createFacility.committed'.tr(),
        items: viewModel.committedValues,
        selectedItems: !viewModel.showCreateFacilityForm &&
                viewModel.facility.committedValues != null
            ? [viewModel.facility.committedValues!]
            : null,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facility.committedValues = (selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected,
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
