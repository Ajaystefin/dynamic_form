import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/state.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/widgets/body_widget.dart";

/// Desktop view for the Facilities with CBD feature.
class ViewDesktop extends StatelessWidget {
  /// Creates a [ViewDesktop] widget.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final FacilitiesWithCbdViewModel viewModel =
        context.read<FacilitiesWithCbdViewModel>();
    return BlocBuilder<FacilitiesWithCbdViewModel, FacilitiesWithCbdState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    FacilitiesWithCbdState state,
    FacilitiesWithCbdViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      // case LoadingStatus.error:
      //   return Center(
      //     child: Text('common.serverError'.tr()),
      //   );
      default:
        return BodyWidget(viewModel: viewModel);
    }
  }
}
