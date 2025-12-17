import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/information/termination/fields/reason_for_termination.dart';
import 'package:wcas_frontend/features/request/information/termination/fields/remarks.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    TerminationViewModel viewModel = context.read<TerminationViewModel>();
    return BlocBuilder<TerminationViewModel, TerminationState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, TerminationState state,
      TerminationViewModel viewModel) {
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
                        title:
                            "requestInformation.terminateWithdrawal.terminationWithdrawal"
                                .tr(),
                      ),
                      const Gap(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BoxLayout(
                            child: TopSectionDetails(
                                request: Globals.request ?? Request()),
                          ),
                          BoxLayout(
                            child:
                                // Type.
                                Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FormRow(
                                  children: [
                                    ReasonForTermination(viewModel: viewModel),
                                    const SizedBox(),
                                    const SizedBox(),
                                  ],
                                ),
                                const Gap(
                                  size: GapSize.medium,
                                ),
                                Remarks(viewModel: viewModel),
                                const Gap(
                                  size: GapSize.medium,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: CustomButton(
                                    label:
                                        "requestInformation.terminateWithdrawal.terminate"
                                            .tr(),
                                    onPressed: state.isButtonLoading
                                        ? null
                                        : () {
                                            viewModel.onTerminateButtonPressed(
                                                context);
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
            ),
          ),
        );
    }
  }
}
