import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/icon.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

class AddSublimitButton extends StatelessWidget {
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
  final FacilitiesSummaryViewModel viewModel;
  final Facility? facility;
  final int? limitGroup;
  final int? selectedRim;
  final bool? isMainLimit;
  final String? limitNumber;
  final String? projectName;
  final int? totalProposedLimit;
  final int? proposedLimit;
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
                barrierDismissible: true,
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
