import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CollateralDepandant extends StatelessWidget {
  const CollateralDepandant({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Resolve YES/NO refs once from options
    final Reference yesRef = viewModel.collateralDepantantoptions.firstWhere(
      (e) => e.id == ServerConstants.optionYESid,
      orElse: () => viewModel.collateralDepantantoptions.isNotEmpty
          ? viewModel.collateralDepantantoptions.first
          : Reference(),
    );
    final Reference noRef = viewModel.collateralDepantantoptions.firstWhere(
      (e) => e.id == ServerConstants.optionNOid,
      orElse: () => yesRef,
    );

    // Existing: derive from API;  default to NO (unless VM already set)
    final Reference selected = viewModel.facilityDetail.isNotEmpty
        ? ((viewModel.facilityDetail.first.isCollateralDependent?.id ==
                ServerConstants.optionYESid)
            ? yesRef
            : noRef)
        : (viewModel.getFacility.selectedCollateralDepantantValue ?? noRef);

    return LabelWidget(
      label: "facilities.createFacility.collateralDependant".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomRadioButton<Reference>(
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ""),
        options: viewModel.collateralDepantantoptions,
        selectedValue: selected,
        onChanged: (value) {
          viewModel.changeCollateralDependant(value);
        },
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
