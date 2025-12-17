import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class RegulatoryLandingSpecification extends StatelessWidget {
  final CreateFacilityViewModel viewModel;

  const RegulatoryLandingSpecification({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.regulatorySpecification'.tr(),
      child: CustomDropdown<Reference>(
        isEnabled:
            viewModel.facility.selectedRegulatorySpecialisedLandingValue?.id ==
                ServerConstants.optionYESid,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.regulatorySpecifications,
        selectedItems: [viewModel.facility.regulatorySpecification],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facility.regulatorySpecification = (selectedValue.first);
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
