import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/information/present_request/fields/present_comments.dart";
import "package:wcas_frontend/features/request/information/present_request/model.dart";
import "package:wcas_frontend/features/request/information/present_request/state.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Mobile view for the Present Request screen.
///
/// Provides a mobile-optimized layout for displaying request
/// details, comments, and related actions on smaller devices.
class ViewMobile extends StatelessWidget {
  /// Creates a [ViewMobile].
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final PresentRequestViewModel viewModel =
        context.read<PresentRequestViewModel>();
    return BlocBuilder<PresentRequestViewModel, PresentRequestState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    PresentRequestState state,
    PresentRequestViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: _buildWidgets(viewModel, state),
        );
    }
  }

  Widget _buildWidgets(
    PresentRequestViewModel viewModel,
    PresentRequestState state,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "requestInformation.presentRequest.title".tr(),
              ),
              const Gap(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxLayout(
                    child: TopSectionDetails(
                      request: Globals.request ?? Request(),
                    ),
                  ),
                  BoxLayout(
                    disabled: !viewModel.canEdit,
                    child: PresentComments(
                      viewModel: viewModel,
                    ),
                  ),
                ],
              ),
              const Gap(),
              if (!viewModel.canEdit)
                Container()
              else
                Align(
                  alignment: AlignmentDirectional.center,
                  child: CustomButton(
                    label:
                        "requestInformation.presentRequest.saveContinue".tr(),
                    isLoading: state.isButtonLoading,
                    onPressed: state.isButtonLoading
                        ? null
                        : () {
                            viewModel.onSaveButtonPressed();
                          },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
