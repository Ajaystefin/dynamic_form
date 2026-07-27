import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/features/request/information/security_perfection/state.dart";
import "package:wcas_frontend/features/request/information/security_perfection/widgets/condition_table.dart";
import "package:wcas_frontend/features/request/information/security_perfection/widgets/covenant_table.dart";
import "package:wcas_frontend/features/request/information/security_perfection/widgets/reason_for_deferral.dart";
import "package:wcas_frontend/features/request/information/security_perfection/widgets/security_perfection_table.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Mobile view for the Security Perfection feature.
class ViewMobile extends StatelessWidget {
  /// Creates a [ViewMobile] widget.
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final SecurityPerfectionViewModel viewModel =
        context.read<SecurityPerfectionViewModel>();
    return BlocBuilder<SecurityPerfectionViewModel, SecurityPerfectionState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    SecurityPerfectionState state,
    SecurityPerfectionViewModel viewModel,
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
    SecurityPerfectionViewModel viewModel,
    SecurityPerfectionState state,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "requestInformation.securityPerfection.title".tr(),
              ),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(
                  request: Globals.request ?? Request(),
                ),
              ),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppStyle.spacing,
                  children: [
                    SecurityPerfectionTable(
                      viewModel: viewModel,
                      state: state,
                    ),
                    const Gap(),
                    CovenantTable(
                      viewModel: viewModel,
                      state: state,
                    ),
                    const Gap(),
                    ConditionTable(
                      viewModel: viewModel,
                      state: state,
                    ),
                    const Gap(),
                    ReasonForDeferral(viewModel: viewModel),
                  ],
                ),
              ),
              const Gap(),
              Align(
                alignment: AlignmentDirectional.center,
                child: CustomButton(
                  label:
                      "requestInformation.securityPerfection.saveContinue".tr(),
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
