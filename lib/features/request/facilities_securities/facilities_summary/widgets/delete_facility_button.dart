import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';

class DeleteFacilityButton extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;
  final int? serialNumber;
  // final int? typeID;
  const DeleteFacilityButton(
      {super.key,
      required this.viewModel,
      required this.serialNumber,
      // required this.typeID
      });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: AppColors.buttonBackground),
      onPressed: () {
        DialogHelper.showCustomDialog(
          width: 400.w,
          barrierDismissible: false,
          title: "facilities.facilitySummary.title".tr(),
          content: Column(
            spacing: 20,
            children: [
              Text(
                "facilities.facilitySummary.delete_confirmation".tr(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 20,
                children: [
                  CustomButton(
                      label: "common.delete".tr(),
                      onPressed: () {
                        Navigator.of(context).pop();
                        viewModel.deleteFacilityDetails(
                          serialNumber: serialNumber,
                          // typeID: typeID,
                        );
                      }),
                  CustomButton(
                      label: "common.cancel".tr(),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              )
            ],
          ),
          context: context,
        );
      },
    );
  }
}
