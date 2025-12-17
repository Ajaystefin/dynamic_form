import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/icon.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/widgets/add_sublimit_dialog_box.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

class AddSublimitButton extends StatelessWidget {
  final FacilitiesSummaryFiViewModel viewModel;
  final FacilityGroup? facilityGroup;
  final Facility? facility;
  const AddSublimitButton(
      {super.key, required this.viewModel, this.facilityGroup, this.facility});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomIcon(
        onTap: () {
          DialogHelper.showCustomDialog(
            barrierDismissible: false,
            title: "facilities.facilitySummary.addSublimit".tr(),
            content: BlocProvider.value(
              value: viewModel,
              child: const AddSubLimitDialogBoxFi(),
            ),
            context: context,
          );
        },
        icon: Icons.add_circle_outline_sharp,
        iconColor: AppColors.buttonBackground,
      ),
    );
  }
}
