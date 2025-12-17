import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/widgets/condition_table.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/widgets/covenant_table.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/widgets/reason_for_deferral.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/widgets/security_perfection_table.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    SecurityPerfectionViewModel viewModel =
        context.read<SecurityPerfectionViewModel>();
    return BlocBuilder<SecurityPerfectionViewModel, SecurityPerfectionState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, SecurityPerfectionState state,
      SecurityPerfectionViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(BuildContext context, SecurityPerfectionState state,
      SecurityPerfectionViewModel viewModel) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppStyle.spacing,
            children: [
              CustomSectionHeader(
                  title: "requestInformation.securityPerfection.title".tr()),
              const Gap(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxLayout(
                    child: TopSectionDetails(
                      request: Globals.request ?? Request(),
                    ),
                  ),
                  BoxLayout(
                    child: Column(
                      spacing: AppStyle.spacing,
                      children: [
                        SecurityPerfectionTable(viewModel: viewModel),
                        const Gap(
                          size: GapSize.medium,
                        ),
                        CovenantTable(viewModel: viewModel),
                        const Gap(
                          size: GapSize.medium,
                        ),
                        ConditionTable(viewModel: viewModel),
                        const Gap(
                          size: GapSize.medium,
                        ),
                        ReasonForDeferral(viewModel: viewModel),
                        const Gap(
                          size: GapSize.medium,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CustomButton(
                            isLoading: state.isButtonLoading,
                            onPressed: state.isButtonLoading
                                ? null
                                : () {
                                    viewModel.onSaveButtonPressed();
                                  },
                            label:
                                'requestInformation.securityPerfection.saveContinue'
                                    .tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
