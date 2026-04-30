import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/model.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/state.dart";

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    required this.viewModel,
    required this.state,
    super.key,
  });

  final CommonTabsViewModel viewModel;
  final CommonTabsState state;

  @override
  Widget build(BuildContext context) {
    // In read-only mode show only the Continue navigation button
    if (viewModel.isReadOnlyMode) {
      return _continueButton(context);
    }

    logger.i(state.buttonLoaderStatus);
    switch (state.buttonLoaderStatus) {
      case LoadingStatus.loading:
        return buttons(context, loading: true);

      default:
        return buttons(context);
    }
  }

  /// Read-only mode: a single Continue button that advances the route
  Widget _continueButton(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            label: "common.continue".tr(),
            semanticLabel: "common.continue".tr(),
            onPressed: viewModel.navigate,
          ),
        ],
      );

  Widget buttons(BuildContext context, {bool loading = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            isLoading: !state.shouldNavigate && loading,
            label: "common.save".tr(),
            semanticLabel: "common.save".tr(),
            onPressed: (state.shouldNavigate && loading)
                ? null
                : () {
                    viewModel.onSavePress(context: context);
                  },
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            isLoading: state.shouldNavigate && loading,
            label: "common.saveAndContinue".tr(),
            semanticLabel: "common.saveAndContinue".tr(),
            onPressed: (!state.shouldNavigate && loading)
                ? null
                : () async {
                    await viewModel.onSavePress(
                      context: context,
                      shouldNavigate: true,
                    );
                  },
          ),
        ],
      );
}
