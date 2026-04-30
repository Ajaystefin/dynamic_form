import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

class SelectionActionWidgets extends StatelessWidget {
  const SelectionActionWidgets({required this.viewModel, super.key});
  final CreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Customer?>(
      valueListenable: viewModel.selectedCustomer,
      builder: (context, customer, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              backgroundColor: AppColors.darkGreen,
              onPressed: customer == null
                  ? null
                  : () {
                      viewModel.onSelectionPressed(
                        context,
                        closeDialog: true,
                      );
                    },
              label: "requestInformation.createRequest.select".tr(),
            ),
            const Gap(
              direction: Axis.horizontal,
            ),
            CustomButton(
              backgroundColor: AppColors.darkGreen,
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
                viewModel.onSelectionCancelButtonPress();
              },
              label: "requestInformation.createRequest.cancel".tr(),
            ),
          ],
        );
      },
    );
  }
}
