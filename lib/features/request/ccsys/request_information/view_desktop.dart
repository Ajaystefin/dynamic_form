import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/fields/application_type.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/fields/business_segment.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/fields/ca_date.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/fields/main_branch.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/fields/region.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/state.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Desktop view for the CCSYS request information screen.
class ViewDesktop extends StatelessWidget {
  /// Creates a [ViewDesktop] widget.
  const ViewDesktop({super.key});

  /// Builds the desktop request information view.
  @override
  Widget build(BuildContext context) {
    final RequestInformationViewModel viewModel =
        context.read<RequestInformationViewModel>();
    return BlocBuilder<RequestInformationViewModel, RequestInformationState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    RequestInformationState state,
    RequestInformationViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.serverError".tr()),
        );
      default:
        return SingleChildScrollView(
          child: Focus(
            focusNode: viewModel.formFocusNode,
            child: Form(
              key: viewModel.formKey,
              child: BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSectionHeader(
                      title: "ccsys.requestInformation.requestInformation".tr(),
                    ),
                    const Gap(size: GapSize.large),
                    BoxLayout(
                      child: TopSectionDetails(
                        request: Globals.request ?? Request(),
                      ),
                    ),
                    BoxLayout(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormRow(
                            children: [
                              CaDate(viewModel: viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              BusinessSegmentField(viewModel: viewModel),
                              Region(viewModel: viewModel),
                              MainBranch(viewModel: viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              ApplicationTypeDropdown(
                                viewModel: viewModel,
                              ),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomButton(
                                isLoading: viewModel.state.isButtonLoading,
                                label: "ccsys.requestInformation.saveContinue"
                                    .tr(),
                                onPressed: () => !viewModel.canEdit
                                    ? viewModel.moveToNext()
                                    : viewModel.onSavePressed(context),
                              ),
                            ],
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
