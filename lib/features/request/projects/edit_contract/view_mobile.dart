import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/borrower_role.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/comments_table.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/contract_code.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/contract_comments.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/contract_scope.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/contract_value.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/customer_name.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/expected_completion_date.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/expected_start_date.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/initial_contract_value.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/link_commitment_table.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/original_completion_date.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/paymaster_name.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/ppc_table.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/project_collection_acc.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/project_completion.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/project_name.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/project_tenor.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/rim_no.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/state.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/widgets/actions.dart";

/// Mobile view for editing contract details.
class ViewMobile extends StatelessWidget {
  /// Creates a mobile view for editing contract details.
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final EditContractViewModel viewModel =
        context.read<EditContractViewModel>();
    return BlocBuilder<EditContractViewModel, EditContractState>(
      builder: (context, state) {
        return Layout(
          hideSideMenu: true,
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    EditContractState state,
    EditContractViewModel viewModel,
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
        return BoxLayout(
          child: SingleChildScrollView(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "project.viewEditContractDetails.editContract".tr(),
                  ),
                  const Gap(),
                  CustomButton(
                    leadingIcon:
                        const Icon(Icons.arrow_back, color: AppColors.white),
                    label: "project.linkContract.backToRequestStatus".tr(),
                    semanticLabel:
                        "project.linkContract.backToRequestStatus".tr(),
                    onPressed: () {
                      viewModel.onBacktoRequestStatusPressed(context);
                    },
                  ),
                  const Gap(size: GapSize.large),
                  ContractCode(viewModel: viewModel),
                  const Gap(),
                  ProjectName(viewModel: viewModel),
                  const Gap(),
                  CustomerName(viewModel: viewModel),
                  const Gap(),
                  RimNo(viewModel: viewModel),
                  const Gap(),
                  BorrowerRole(
                    viewModel: viewModel,
                  ),
                  const Gap(),
                  PaymasterName(viewModel: viewModel),
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
                  ProjectCompletion(viewModel: viewModel),
                  const Gap(),
                  InitialContractValue(
                    viewModel: viewModel,
                  ),
                  const Gap(),
                  ContractScope(viewModel),
                  const Gap(),
                  OriginalCompletionDate(viewModel),

                  const Gap(),
                  CustomSectionHeader(
                    title:
                        "project.viewEditContractDetails.linkCommitmentNumber"
                            .tr(),
                  ),
                  const Gap(size: GapSize.large),
                  ProjectCollectionAcc(viewModel: viewModel),
                  const Gap(),
                  if (state.linkCommitmentStatus == LoadingStatus.loading)
                    Column(
                      children: [
                        ProjectCollectionAcc(
                          viewModel: viewModel,
                        ),
                        const Gap(),
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                        LinkCommitmentTable(viewModel),
                      ],
                    )
                  else
                    Column(
                      children: [
                        ProjectCollectionAcc(
                          viewModel: viewModel,
                        ),
                        const Gap(),
                        LinkCommitmentTable(viewModel),
                      ],
                    ),
                  const Gap(),
                  CustomSectionHeader(
                    title: "project.viewEditContractDetails.ppc".tr(),
                  ),
                  const Gap(),
                  if (state.ppcStatus == LoadingStatus.loading)
                    Column(
                      children: [
                        Container(),
                        PpcTable(
                          viewModel,
                          state,
                          editable: viewModel.isPpcEditable,
                        ),
                      ],
                    )
                  else
                    PpcTable(
                      viewModel,
                      state,
                      editable: viewModel.isPpcEditable,
                    ), // becomes true after Add),

                  const Gap(size: GapSize.large),
                  if (viewModel.isAddPPC)
                    AddItemButton(
                      onTap: () {
                        // 1) Add the row
                        viewModel.addPPCRow();
                      },
                      isLeftSided: true,
                      child: Text(
                        "project.viewEditContractDetails.addPpc".tr(),
                        style:
                            const TextStyle(fontSize: AppStyle.fontSizeSmall),
                      ),
                    ),
                  const Gap(),
                  ContractComments(viewModel: viewModel),
                  const Gap(),
                  CommentsTable(viewModel: viewModel),
                  const Gap(),
                  ActionsWidget(viewModel),
                ],
              ),
            ),
          ),
        );
    }
  }
}
