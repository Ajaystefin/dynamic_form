import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/icon.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_facility_sublimit.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

class AddSublimitButton extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;
  final FacilityGroup? facilityGroup;
  final Facility? facility;
  final int? limitGroup;
  final int? selectedRim;
  final bool? isMainLimit;
  final String? limitNumber;
  final int? proposedLimit;
  const AddSublimitButton(
      {super.key,
      required this.viewModel,
      this.facilityGroup,
      this.facility,
      this.limitGroup,
      this.selectedRim,
      this.isMainLimit,
      this.limitNumber,
      this.proposedLimit});

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
                      limitNumber: limitNumber,
                      proposedLimit: proposedLimit,
                      selectedRim: selectedRim,
                      isMainLimit: isMainLimit),
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
