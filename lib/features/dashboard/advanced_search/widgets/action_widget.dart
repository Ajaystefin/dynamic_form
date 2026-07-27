import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";

/// Widget that displays submit and reset actions for advanced search.
class ActionWidget extends StatelessWidget {
  /// Creates an [ActionWidget].
  const ActionWidget({
    required this.viewModel,
    super.key,
  });

  /// View model that handles advanced search actions.
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
