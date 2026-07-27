import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/icon.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

/// Widget for displaying the action button used to add a sub-limit.
class AddSublimitButton extends StatelessWidget {
  /// Creates an add sub-limit button widget.
  const AddSublimitButton({
    required this.viewModel,
    super.key,
    this.facility,
    this.limitGroup,
    this.totalProposedLimit,
    this.selectedRim,
    this.isMainLimit,
    this.limitNumber,
    this.projectName,
    this.proposedLimit,
    this.isStanbySublimitValidation,
  });

  /// View model containing facility summary data and actions.
  final FacilitiesSummaryViewModel viewModel;

  /// Facility associated with the sub-limit.
  final Facility? facility;

  /// Selected limit group identifier.
  final int? limitGroup;

  /// Selected borrower RIM number.
  final int? selectedRim;

  /// Indicates whether the facility is a main limit.
  final bool? isMainLimit;

  /// Limit number associated with the facility.
  final String? limitNumber;

  /// Project name associated with the facility.
  final String? projectName;

  /// Total proposed limit amount.
  final int? totalProposedLimit;

  /// Proposed sub-limit amount.
  final int? proposedLimit;

  /// Indicates whether standby sub-limit validation is enabled.
  final bool? isStanbySublimitValidation;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Handle tap
        },
        child: Center(
          child: CustomIcon(
            onTap: () {
              DialogHelper.showCustomDialog(
                title: "facilities.facilitySummary.addSublimit".tr(),
                content: BlocProvider.value(
                  value: viewModel,
                  child: AddFacilitySubLimitBox(
                    label: "facilities.facilitySummary.addSublimit".tr(),
                    limitGroup: limitGroup,
                    limitType: false,
                    totalProposedLimit: totalProposedLimit,
                    limitNumber: limitNumber,
                    isStanbySublimitValidation: isStanbySublimitValidation,
                    proposedLimit: proposedLimit,
                    selectedRim: selectedRim,
                    projectName: projectName,
                    isMainLimit: isMainLimit,
                    isSubLimit: true,
                  ),
                ),
                context: context,
              );
            },
            icon: Icons.add_circle_outline_sharp,
            iconColor: AppColors.buttonBackground,
          ),
        ),
      ),
    );
  }
}
