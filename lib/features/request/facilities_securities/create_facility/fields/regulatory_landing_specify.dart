import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class RegulatoryLandingSpecification extends StatelessWidget {
  const RegulatoryLandingSpecification({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Safe check for facilityDetail existence
    final bool hasFacilityDetail = viewModel.facilityDetail.isNotEmpty;

    // From facilityDetail: isRegulatorySpecialisedLending == YES ?
    final bool isRegSpecLendingYesFromFacilityDetail = hasFacilityDetail
        ? (viewModel.facilityDetail.first.isRegulatorySpecialisedLending?.id ==
            ServerConstants.optionYESid)
        : false;

    // From selected value: isRegulatorySpecialisedLending == YES / NO ?
    final int? selectedLandingId =
        viewModel.getFacility.selectedRegulatorySpecialisedLandingValue?.id;

    final bool isRegSpecLendingYesFromSelection =
        selectedLandingId == ServerConstants.optionYESid;

    final bool isRegSpecLendingNoFromSelection =
        selectedLandingId == ServerConstants.optionNOid;

    // isEnabled logic: prefer facilityDetail value when present, else fallback
    // to selection
    final bool isEnabled = hasFacilityDetail
        ? isRegSpecLendingYesFromFacilityDetail
        : isRegSpecLendingYesFromSelection;

    // Target regulatory spec id from the first facility detail (safe)
    final int? targetRegulatorySpecId = hasFacilityDetail
        ? viewModel.facilityDetail.first.regulatorySpecification?.id
        : null;

    // Resolve the selected Reference for the dropdown
    Reference resolveSelectedItem() {
      if (isRegSpecLendingNoFromSelection) {
        return Reference();
      }
      if (targetRegulatorySpecId == null) {
        return Reference();
      }
      // Find match; fallback to Reference() if none
      for (final Reference spec in viewModel.regulatorySpecifications) {
        if (spec.id == targetRegulatorySpecId) {
          return spec;
        }
      }
      return Reference();
    }

    return LabelWidget(
      label: "facilities.createFacility.regulatorySpecification".tr(),
      child: CustomDropdown<Reference>(
        isEnabled: isEnabled,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.regulatorySpecifications,
        selectedItems: <Reference>[resolveSelectedItem()],
        onSelected: (List<Reference> selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.getFacility.regulatorySpecification = selectedValue.first;
          }
        },
        itemBuilder: (
          BuildContext context,
          Reference item,
          bool isDisabled,
          bool isSelected,
        ) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (BuildContext context, Reference? data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
