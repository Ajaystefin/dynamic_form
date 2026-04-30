import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/assign_request_dialog/model.dart";
import "package:wcas_frontend/features/dashboard/assign_request_dialog/state.dart";
import "package:wcas_frontend/features/layout/view.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final AssignRequestDialogViewModel viewModel =
        context.read<AssignRequestDialogViewModel>();
    return BlocBuilder<AssignRequestDialogViewModel, AssignRequestDialogState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    AssignRequestDialogState state,
    AssignRequestDialogViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("Empty State".tr()),
        );
      default:
        return const Center(child: Text("AssignRequestDialog View"));
    }
  }
}
