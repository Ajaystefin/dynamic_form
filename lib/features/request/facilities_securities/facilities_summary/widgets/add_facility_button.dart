import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";

class AddFacilityButton extends StatelessWidget {
  const AddFacilityButton({
    required this.viewModel,
    required this.isMainLimit,
    super.key,
    this.limitGroup,
    this.selectedRim,
    this.totalProposedLimit,
    this.proposedLimit,
    this.isStanbySublimitValidation,
  });
  final int? limitGroup;
  final int? selectedRim;
  final int? totalProposedLimit;
  final bool? isMainLimit;
  final bool? isStanbySublimitValidation;
  final int? proposedLimit;
  final FacilitiesSummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: "facilities.facilitySummary.addFacility".tr(),
      onPressed: () {
        // project groups are 11315 (Project Specific) and 11317 (Project
        // Standby
        final bool isProjectGroup =
            (limitGroup == ServerConstants.projectSpecificLimitsID ||
                limitGroup == ServerConstants.projectStandByLimitID);
        final int? rimNo = selectedRim;

        // Always resolve header limitNo per rim (order "0" row)
        final String? headerLimitNo = (isProjectGroup && rimNo != null)
            ? viewModel.headerLimitNumberForGroupAtRim(limitGroup, rimNo)
            : null;

        // Always resolve proposed limit per rim at click-time (avoids stale
        // values)
        final int? headerProposed =
            (isProjectGroup && rimNo != null && limitGroup != null)
                ? viewModel.proposedLimitForGroup(limitGroup!, rimNo: rimNo)
                : proposedLimit;

        DialogHelper.showCustomDialog(
          barrierDismissible: true,
          title: "facilities.facilitySummary.addFacility".tr(),
          content: BlocProvider.value(
            value: viewModel,
            child: AddFacilitySubLimitBox(
              limitGroup: limitGroup,
              selectedRim: selectedRim,
              isMainLimit: isProjectGroup ? false : isMainLimit,
              limitNumber: isProjectGroup ? headerLimitNo : null,
              totalProposedLimit:
                  isProjectGroup ? headerProposed : totalProposedLimit,
              isStanbySublimitValidation: isStanbySublimitValidation,
              proposedLimit: headerProposed,
            ),
          ),
          context: context,
        );
      },
    );
  }
}
