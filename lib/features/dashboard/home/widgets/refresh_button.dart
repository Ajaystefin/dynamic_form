import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/state.dart";

class RefreshButton extends StatelessWidget {
  const RefreshButton({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final HomeViewModel viewModel;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return CustomTooltip(
      message: "dashboard.home.refresh".tr(),
      child: IconButton(
        color: AppColors.primary,
        onPressed: () async => viewModel.onClickRefresh(),
        icon: state.refreshLoader == true
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
