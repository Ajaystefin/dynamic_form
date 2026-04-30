import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/flexbox.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/model.dart";

class BottomControls extends StatelessWidget {
  const BottomControls({
    required this.viewModel,
    required this.context,
    super.key,
    this.canSubmit = true,
  });
  final RequestForClosureViewModel viewModel;
  final BuildContext context;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();
    Future<void> submitApplication() async {
      final List<String> result = await viewModel.saveCommentAndClose();
      if (result.isNotEmpty) {
        if (context.mounted &&
            result.first == "layout.topmenu.comfirmation".tr()) {
          await layoutViewModel.showConfirmationDialog(context, result.last);
        } else if (context.mounted) {
          await layoutViewModel.showWarningDialog(context, result);
        }
      }
    }

    return FlexBox(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: CustomButton(
            semanticLabel: "approval.requestForClosure.closeApplication".tr(),
            label: "approval.requestForClosure.closeApplication".tr(),
            onPressed: viewModel.canSubmit ? submitApplication : null,
          ),
        ),
        const Gap(),
      ],
    );
  }
}
