import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/borrower_role.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/completion.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/contract_code.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/contract_comments.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/contract_scope.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/contract_value.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/customer_name.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/expected_completion_date.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/expected_start_date.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/initial_contract_value.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/link_commitment_table.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/original_completion_date.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/paymaster_name.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/ppc_table.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/project_collection_acc.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/project_name.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/project_tenor.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/fields/rim_no.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/widgets/actions.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    EditContractViewModel viewModel = context.read<EditContractViewModel>();
    return BlocBuilder<EditContractViewModel, EditContractState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, EditContractState state,
      EditContractViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.serverError'.tr()),
        );
      default:
        return SingleChildScrollView(
            child: BoxLayout(
                child: Focus(
          child: Form(
            key: viewModel.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomSectionHeader(
                          title:
                              "project.viewEditContractDetails.editViewContract"
                                  .tr()),
                      CustomButton(
                        leadingIcon: const Icon(Icons.arrow_back,
                            color: AppColors.white),
                        label: "project.linkContract.backToRequestStatus".tr(),
                        semanticLabel:
                            "project.linkContract.backToRequestStatus".tr(),
                        onPressed: () {
                          if (context.mounted) {
                            context.go(Routes.searchProject);
                          }
                        },
                      ),
                    ]),
                const Gap(),
                BoxLayout(
                  extraPadding: true,
                  child: Column(
                    children: [
                      FormRow(
                        children: [
                          ContractCode(
                              contractCode: viewModel.contract.contractCode),
                          ProjectName(
                              prjectName: viewModel.contract.projectName),
                          CustomerName(
                              customerName: viewModel.contract.customerName),
                        ],
                      ),
                      const Gap(),
                      FormRow(
                        children: [
                          RimNo(rimNO: viewModel.contract.rimNo),
                          BorrowerRole(viewModel: viewModel),
                          PaymasterName(
                              paymasterName: viewModel.contract.paymasterName),
                        ],
                      ),
                      const Gap(),
                      FormRow(children: [
                        ExpectedStartDate(viewModel),
                        ExpectedCompletionDate(viewModel),
                        ContractValue(viewModel),
                      ]),
                      const Gap(),
                      FormRow(children: [
                        ProjectTenor(
                          viewModel: viewModel,
                        ),
                        ProjectCompletion(
                            projectCompletion: viewModel.contract.completion),
                        InitialContractValue(viewModel: viewModel),
                      ]),
                      const Gap(),
                      FormRow(
                        children: [
                          ContractScope(viewModel),
                          OriginalCompletionDate(viewModel),
                          const Gap(),
                        ],
                      ),
                      const Gap(),
                      FormRow(
                        children: [
                          ContractComments(viewModel: viewModel),
                          const Gap(),
                          const Gap(),
                        ],
                      ),
                      const Gap(),
                    ],
                  ),
                ),
                state.linkCommitmentStatus == LoadingStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : BoxLayout(
                        extraPadding: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSectionHeader(
                                title:
                                    'project.viewEditContractDetails.linkCommitmentNumber'
                                        .tr()),
                            const Gap(),
                            FormRow(
                              children: const [ProjectCollectionAcc()],
                            ),
                            const Gap(),
                            LinkCommitmentTable(viewModel),
                            const Gap(),
                          ],
                        ),
                      ),
                state.ppcStatus == LoadingStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : BoxLayout(
                        extraPadding: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSectionHeader(
                                title: 'project.viewEditContractDetails.addPpc'
                                    .tr()),
                            const Gap(),
                            PpcTable(viewModel),
                            const Gap(),
                          ],
                        ),
                      ),
                const Gap(),
                ActionsWidget(viewModel),
              ],
            ),
          ),
        )));
    }
  }
}
