import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/features/request/ccsys/approval/model.dart';

class SaveButton extends StatelessWidget {
  final CcsysApprovalViewModel viewModel;
  const SaveButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "remarks.financialRatiosAnalysis.saveAndContinue".tr(),
          onPressed: () {
            viewModel.onSavePress();
          },
        ),
      ],
    );
  }
}
