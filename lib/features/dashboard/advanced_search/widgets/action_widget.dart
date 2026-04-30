import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    required this.viewModel,
    super.key,
  });

  final AdvancedSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "dashboard.advancedSearch.submit".tr(),
          onPressed: viewModel.onSubmitButtonPress,
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "dashboard.advancedSearch.reset".tr(),
          onPressed: viewModel.onResetButtonPress,
        ),
        const Gap(direction: Axis.horizontal),
      ],
    );
  }
}
