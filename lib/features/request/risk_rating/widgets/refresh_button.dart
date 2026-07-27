import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";

/// Refresh Button
///
/// Displays a button that refreshes risk rating data.
class RefreshButton extends StatelessWidget {
  /// Creates a refresh button.
  const RefreshButton({
    required this.viewModel,
    super.key,
  });

  /// Risk rating view model.
  final RiskRatingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        viewModel.state.refreshLoader == LoadingStatus.loading;
    return CustomTooltip(
      message: "dashboard.home.refresh".tr(),
      child: IconButton(
        color: AppColors.primary,
        onPressed: isLoading
            ? null
            : () async {
                await viewModel.onRefreshPressed();
              },
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(
                Icons.refresh,
                semanticLabel: "dashboard.home.refresh".tr(),
              ),
      ),
    );
  }
}
