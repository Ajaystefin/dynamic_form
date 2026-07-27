import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";

/// Widget for displaying the action button used to add a facility.
class AddFacilityButton extends StatelessWidget {
  /// Creates an add facility button widget.
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

  /// Selected limit group identifier.
  final int? limitGroup;

  /// Selected borrower RIM number.
  final int? selectedRim;

  /// Total proposed limit amount.
  final int? totalProposedLimit;

  /// Indicates whether the facility is a main limit.
  final bool? isMainLimit;

  /// Indicates whether standby sub-limit validation is enabled.
  final bool? isStanbySublimitValidation;

  /// Proposed facility limit amount.
  final int? proposedLimit;

  /// View model containing facility summary data and actions.
  final FacilitiesSummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: "facilities.facilitySummary.addFacility".tr(),
      onPressed: () {
        // project groups are 11315 (Project Specific) and 11317 (Project
        // Standby
        final bool isProjectGroup =
            limitGroup == ServerConstants.projectSpecificLimitsID ||
                limitGroup == ServerConstants.projectStandByLimitID;
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
