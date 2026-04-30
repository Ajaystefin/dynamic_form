import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
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
import "package:wcas_frontend/features/request/projects/edit_contract/fields/excepted_completion_date_varient.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/expected_completion_date.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/expected_start_date.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/fields/inital_contract_value_varient.dart";
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

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

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
                                  .tr(),
                        ),
                        CustomButton(
                          leadingIcon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                          ),
                          label:
                              "project.linkContract.backToRequestStatus".tr(),
                          semanticLabel:
                              "project.linkContract.backToRequestStatus".tr(),
                          onPressed: () {
                            viewModel.onBacktoRequestStatusPressed(context);
                          },
                        ),
                      ],
                    ),
                    const Gap(),
                    BoxLayout(
                      extraPadding: true,
                      child: Column(
                        children: [
                          FormRow(
                            children: [
                              ContractCode(viewModel: viewModel),
                              ProjectName(viewModel: viewModel),
                              CustomerName(viewModel: viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              RimNo(viewModel: viewModel),
                              BorrowerRole(viewModel: viewModel),
                              PaymasterName(viewModel: viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              ExpectedStartDate(viewModel),
                              ExpectedCompletionDate(viewModel),
                              ContractValue(viewModel),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              ProjectTenor(
                                viewModel: viewModel,
                              ),
                              ProjectCompletion(viewModel: viewModel),
                              Container(),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              InitialContractValue(viewModel: viewModel),
                              InitalContractValueVarient(viewModel: viewModel),
                              Container(),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              OriginalCompletionDate(viewModel),
                              ExceptedCompletionDateVarient(
                                viewModel: viewModel,
                              ),
                              Container(),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              ContractScope(viewModel),
                              Container(),
                              const Gap(),
                            ],
                          ),
                          const Gap(),
                        ],
                      ),
                    ),
                    BoxLayout(
                      extraPadding: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSectionHeader(
                            title: "project.viewEditContractDetails."
                                    "linkCommitmentNumber"
                                .tr(),
                          ),
                          const Gap(),
                          const Gap(),
                          state.linkCommitmentStatus == LoadingStatus.loading
                              ? Column(
                                  children: [
                                    FormRow(
                                      children: [
                                        ProjectCollectionAcc(
                                          viewModel: viewModel,
                                        ),
                                      ],
                                    ),
                                    const Gap(),
                                    Container(),
                                    // const Center(
                                    //   child: CircularProgressIndicator(),
                                    // ),
                                    LinkCommitmentTable(viewModel),
                                  ],
                                )
                              : Column(
                                  children: [
                                    FormRow(
                                      children: [
                                        ProjectCollectionAcc(
                                          viewModel: viewModel,
                                        ),
                                      ],
                                    ),
                                    const Gap(),
                                    LinkCommitmentTable(viewModel),
                                  ],
                                ),
                          const Gap(),
                        ],
                      ),
                    ),
                    BoxLayout(
                      extraPadding: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSectionHeader(
                            title: "project.viewEditContractDetails.ppc".tr(),
                          ),
                          const Gap(),
                          state.ppcStatus == LoadingStatus.loading
                              ? Column(
                                  children: [
                                    Container(),
                                    PpcTable(
                                      viewModel,
                                      editable: viewModel.isPpcEditable,
                                    ),
                                  ],
                                )
                              : PpcTable(
                                  viewModel,
                                  editable: viewModel.isPpcEditable,
                                ), // becomes true after Add),

                          const Gap(),
                          if (viewModel.canEdit) ...[
                            if (viewModel.isAddPPC)
                              AddItemButton(
                                onTap: () {
                                  // 1) Add the row
                                  viewModel.onAddRowPressed();
                                  // 2) Enable edit mode so new row shows as
                                  // editable with delete icon
                                  viewModel.enablePpcEditMode();
                                },
                                isLeftSided: true,
                                child: Text(
                                  "project.viewEditContractDetails.addPpc".tr(),
                                  style: const TextStyle(
                                    fontSize: AppStyle.fontSizeSmall,
                                  ),
                                ),
                              ),
                          ],

                          const Gap(),
                          FormRow(
                            children: [
                              ContractComments(viewModel: viewModel),
                              Container(),
                            ],
                          ),

                          const Gap(),
                          FormRow(
                            children: [
                              CommentsTable(viewModel: viewModel),
                              Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(),
                    ActionsWidget(viewModel),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
