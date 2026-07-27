import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/state.dart";

/// Refresh button used to reload dashboard home data.
class RefreshButton extends StatelessWidget {
  /// Creates a [RefreshButton].
  const RefreshButton({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Home dashboard view model used to handle refresh action.
  final HomeViewModel viewModel;

  /// Current dashboard home state.
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return CustomTooltip(
      message: "dashboard.home.refresh".tr(),
      child: IconButton(
        color: AppColors.primary,
        onPressed: () async => viewModel.onClickRefresh(),
        icon: state.refreshLoader ?? false
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}
