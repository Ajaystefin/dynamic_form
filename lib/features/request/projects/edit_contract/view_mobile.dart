import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
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

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

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
        return BoxLayout(
            child: SingleChildScrollView(
          child: Form(
            key: viewModel.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title: "project.viewEditContractDetails.editContract".tr()),
                const Gap(size: GapSize.large),
                ContractCode(
                  contractCode: viewModel.contract.contractCode,
                ),
                const Gap(),
                ProjectName(
                  prjectName: viewModel.contract.projectName,
                ),
                const Gap(),
                CustomerName(
                  customerName: viewModel.contract.customerName,
                ),
                const Gap(),
                RimNo(
                  rimNO: viewModel.contract.rimNo,
                ),
                const Gap(),
                BorrowerRole(
                  viewModel: viewModel,
                ),
                const Gap(),
                PaymasterName(
                  paymasterName: viewModel.contract.paymasterName,
                ),
                const Gap(),
                ExpectedStartDate(viewModel),
                const Gap(),
                ExpectedCompletionDate(viewModel),
                const Gap(),
                ContractValue(viewModel),
                const Gap(),
                ProjectTenor(
                  viewModel: viewModel,
                ),
                const Gap(),
                ProjectCompletion(
                    projectCompletion: viewModel.contract.completion),
                const Gap(),
                InitialContractValue(
                  viewModel: viewModel,
                ),
                const Gap(),
                ContractScope(viewModel),
                const Gap(),
                OriginalCompletionDate(viewModel),
                const Gap(),
                ContractComments(viewModel: viewModel),
                const Gap(),
                CustomSectionHeader(
                    title:
                        'project.viewEditContractDetails.linkCommitmentNumber'
                            .tr()),
                const Gap(size: GapSize.large),
                const ProjectCollectionAcc(),
                const Gap(),
                LinkCommitmentTable(viewModel),
                const Gap(),
                CustomSectionHeader(
                    title: 'project.viewEditContractDetails.ppc'.tr()),
                const Gap(),
                PpcTable(viewModel),
                const Gap(size: GapSize.large),
                ActionsWidget(viewModel),
              ],
            ),
          ),
        ));
    }
  }
}
