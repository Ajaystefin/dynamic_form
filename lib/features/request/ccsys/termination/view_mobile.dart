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
import "package:wcas_frontend/features/request/ccsys/termination/fields/reason_for_termination.dart";
import "package:wcas_frontend/features/request/ccsys/termination/fields/remarks.dart";
import "package:wcas_frontend/features/request/ccsys/termination/model.dart";
import "package:wcas_frontend/features/request/ccsys/termination/state.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Mobile view for the CCsys Termination / Withdrawal screen.
class ViewMobile extends StatelessWidget {
  /// Creates a mobile view.
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final CcsysTerminationViewModel viewModel =
        context.read<CcsysTerminationViewModel>();
    return BlocBuilder<CcsysTerminationViewModel, TerminationState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    TerminationState state,
    CcsysTerminationViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return Focus(
          focusNode: viewModel.formFocusNode,
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              child: BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSectionHeader(
                      title: "requestInformation.terminateWithdrawal."
                              "terminationWithdrawal"
                          .tr(),
                    ),
                    const Gap(),
                    BoxLayout(
                      child: TopSectionDetails(
                        request: Globals.request ?? Request(),
                      ),
                    ),
                    BoxLayout(
                      child: Column(
                        children: [
                          ReasonForTermination(viewModel: viewModel),
                          const Gap(),
                          Remarks(viewModel: viewModel),
                          const Gap(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CustomButton(
                              label: "requestInformation."
                                      "terminateWithdrawal.terminate"
                                  .tr(),
                              isLoading: state.isButtonLoading,
                              onPressed: state.isButtonLoading
                                  ? null
                                  : () {
                                      viewModel
                                          .onTerminateButtonPressed(context);
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
