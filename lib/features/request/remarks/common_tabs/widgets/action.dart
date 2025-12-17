import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/remarks/common_tabs/model.dart';
import 'package:wcas_frontend/features/request/remarks/common_tabs/state.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({super.key, required this.viewModel, required this.state});
  final CommonTabsViewModel viewModel;
  final CommonTabsState state;
  @override
  Widget build(BuildContext context) {
    logger.i(state.buttonLoaderStatus);
    switch (state.buttonLoaderStatus) {
      case LoadingStatus.loading:
        return buttons(context, loading: true);

      default:
        return buttons(
          context,
        );
    }
  }

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
                    viewModel.onSavePress(
                        context: context, shouldNavigate: true);
                  },
          ),
        ],
      );
}
