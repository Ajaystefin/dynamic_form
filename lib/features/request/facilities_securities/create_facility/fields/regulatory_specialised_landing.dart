import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing regulatory specialised lending details.
class RegulatorySpecialisedLanding extends StatelessWidget {
  /// Creates a regulatory specialised lending widget.
  const RegulatorySpecialisedLanding({
    required this.viewModel,
    super.key,
  });

  /// View model containing regulatory specialised lending data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final Reference yesRef =
        viewModel.regulatorySpecialisedLandingOptions.firstWhere(
      (e) => e.id == ServerConstants.optionYESid,
      orElse: () => viewModel.regulatorySpecialisedLandingOptions.isNotEmpty
          ? viewModel.regulatorySpecialisedLandingOptions.first
          : Reference(),
    );

    final Reference noRef =
        viewModel.regulatorySpecialisedLandingOptions.firstWhere(
      (e) => e.id == ServerConstants.optionNOid,
      orElse: () => yesRef,
    );

    final Reference selected = viewModel.facilityDetail.isNotEmpty
        ? ((viewModel.facilityDetail.first.isRegulatorySpecialisedLending?.id ==
                ServerConstants.optionYESid)
            ? yesRef
            : noRef)
        : (viewModel.getFacility.selectedRegulatorySpecialisedLandingValue ??
            noRef);

    return LabelWidget(
      label: "facilities.createFacility.regulatorySpecialisedLending".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomRadioButton<Reference>(
        itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
            Text(item.name ?? ""),
        options: viewModel.regulatorySpecialisedLandingOptions,
        selectedValue: selected,
        onChanged: (value) {
          viewModel.changeRegulatorySpecialisedLanding(value);
        },
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
