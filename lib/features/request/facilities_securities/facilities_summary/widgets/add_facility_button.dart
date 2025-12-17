import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/add_facility_sublimit.dart';

class AddFacilityButton extends StatelessWidget {
  final int? limitGroup;
  final int? selectedRim;
  final bool? isMainLimit;
  const AddFacilityButton(
      {super.key, required this.viewModel, this.limitGroup, this.selectedRim, required this.isMainLimit});
  final FacilitiesSummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: "facilities.facilitySummary.addFacility".tr(),
      onPressed: () {
        DialogHelper.showCustomDialog(
          barrierDismissible: true,
          title: "facilities.facilitySummary.addFacility".tr(),
          content: BlocProvider.value(
            value: viewModel,
            child: AddFacilitySubLimitBox(
              limitGroup: limitGroup,
              selectedRim: selectedRim,
              isMainLimit: isMainLimit,
            ),
          ),
          context: context,
        );
      },
    );
  }
}
