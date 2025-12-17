import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/actions.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/borrower_role.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/completion_percent.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/contract_amount.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/contract_scope.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/expected_end_date.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/expected_start_date.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/link_customer_name.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/link_customer_rim.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/paymaster_name.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/project_tenor.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/search_borrower.dart';

import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    LinkContractViewModel viewModel = context.read<LinkContractViewModel>();
    return BlocBuilder<LinkContractViewModel, LinkContractState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, LinkContractState state,
      LinkContractViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return SingleChildScrollView(
            child: BoxLayout(
          child: Focus(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(size: GapSize.medium),
                    SearchBorrower(viewModel: viewModel),
                    const Gap(size: GapSize.large),
                    CustomSectionHeader(
                        title: "project.linkContract.title".tr()),
                    const Gap(size: GapSize.medium),
                    BoxLayout(
                      extraPadding: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //rim + name + role
                          FormRow(children: [
                            LinkCustomerName(viewModel: viewModel),
                            LinkCustomerRim(viewModel: viewModel),
                            BorrowerRole(viewModel: viewModel),
                          ]),
                          const Gap(),

                          //contract value + amount + converted amount
                          FormRow(children: [
                            ContractAmount(viewModel: viewModel),
                            PaymasterName(viewModel: viewModel),
                              const SizedBox()
                          ]),
                          const Gap(),

                          //contract scope
                          FormRow(children: [
                            ContractScope(viewModel: viewModel),
                            const SizedBox(),
                            const SizedBox()
                          ]),
                          const Gap(),

                          // Dates + Tenor
                          FormRow(children: [
                            ExpectedStartDate(viewModel: viewModel),
                            ExpectedEndDate(viewModel: viewModel),
                            ProjectTenor(viewModel: viewModel),
                          ]),
                          const Gap(),

                          //completion%
                          FormRow(children: [
                            CompletionPercent(viewModel: viewModel),
                            const Gap(),
                            const Gap()
                          ]),
                        ],
                      ),
                    ),
                    const Gap(size: GapSize.medium),
                    ActionsSection(viewModel: viewModel),
                    const Gap(size: GapSize.medium),
                  ]),
            ),
          ),
        ));
    }
  }
}
