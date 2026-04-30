import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class DeleteFeeButton extends StatelessWidget {
  const DeleteFeeButton({
    required this.viewModel,
    required this.feeID,
    super.key,
  });
  final CreateFacilityViewModel viewModel;
  final int? feeID;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: AppColors.buttonBackground),
      onPressed: () {
        DialogHelper.showCustomDialog(
          width: 400.w,
          barrierDismissible: false,
          title: "facilities.createFacility.feeDefualtRate".tr(),
          content: Column(
            spacing: 20,
            children: [
              Text(
                "facilities.createFacility.DeleteFee_Confirmation".tr(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 20,
                children: [
                  CustomButton(
                    label: "common.delete".tr(),
                    onPressed: () {
                      Navigator.of(context).pop();
                      viewModel.deleteFeeDetails(
                        feeID: feeID,
                      );
                    },
                  ),
                  CustomButton(
                    label: "common.cancel".tr(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
          context: context,
        );
      },
    );
  }
}
