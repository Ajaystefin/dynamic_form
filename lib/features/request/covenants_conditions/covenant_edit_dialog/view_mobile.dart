import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/action_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_no_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/associated_table.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/audit_status_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/basis_of_seperation_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_sub_type_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_test_credit_entity.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_tobe_tested_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_type_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/credit_lens_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/customer_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/entity_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/finacial_year_end_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_inline_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_subtype.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_view.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_statement_view.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/frequency_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/general_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/internal_financial_covenant.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/next_monitory_date_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/period_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/rim_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/status_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/submission_time_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/threshold_type_field.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    CovenantEditDialogViewModel viewModel =
        context.read<CovenantEditDialogViewModel>();
    return BlocBuilder<CovenantEditDialogViewModel, CovenantEditDialogState>(
        builder: (context, state) {
      return _body(context, state, viewModel);
    });
  }

  Widget _body(BuildContext context, CovenantEditDialogState state,
      CovenantEditDialogViewModel viewModel) {
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
        return _buildView(viewModel, state, context);
    }
  }

  Widget _buildView(
    CovenantEditDialogViewModel viewModel,
    CovenantEditDialogState state,
    BuildContext context,
  ) {
    final state = context.watch<CovenantEditDialogViewModel>().state;
    return SingleChildScrollView(
      child: BoxLayout(
        extraPadding: true,
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormRow(children: [
                CustomerNameField(viewModel: viewModel),
                CovenantTypeField(viewModel: viewModel),
                const SizedBox()
              ]),

              // const Gap(),
              _covenantTypeField(viewModel, state),
              const Gap(),
              const Gap(size: GapSize.small),
              FormRow(children: [
                SubmissionTimeField(viewModel: viewModel),
                FrequencyField(viewModel: viewModel),
                NextMonitoryDateField(viewModel: viewModel),
              ]),

              const Gap(),
              const Gap(size: GapSize.small),
              FormRow(children: [
                FinancialYearEndField(viewModel: viewModel),
                GeneralField(
                  viewModel: viewModel,
                ),
                StatusField(viewModel: viewModel),
              ]),

              const Gap(),
              AssociatedTable(
                viewModel: viewModel,
              ),

              const Gap(),
              const Gap(size: GapSize.small),
              FormRow(children: [
                if (viewModel.selectedCovenantTypeEnum !=
                    CovenantType.financial) ...[
                  CovenanToBeTestedField(viewModel: viewModel),
                  viewModel.selectedTestType == CovenantTestType.rim
                      ? CustomerRimToBeTested(viewModel: viewModel)
                      : TestNameField(viewModel: viewModel),
                  LabelWidget(
                    label: "",
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: viewModel.onAddButtonPress,
                    ),
                  ),
                ],
                if (viewModel.selectedCovenantTypeEnum ==
                    CovenantType.financial)
                  TresholdTypeField(viewModel: viewModel),
              ]),

              const Gap(),
              FormRow(children: [
                ActionField(viewModel: viewModel),
                const SizedBox(),
                const SizedBox()
              ]),

              const Gap(),
              if (viewModel.showAddWidgets)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: AppStyle.linkContractScopeField),
                  child: Column(children: [
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 1,
                            child: AddCustomerRimField(viewModel: viewModel),
                          ),
                          const Gap(direction: Axis.horizontal),
                          if (state.searchLoaderStatus == LoadingStatus.loading)
                            const CircularProgressIndicator(),
                          Expanded(
                            flex: 1,
                            child: AddCustomerNameField(viewModel: viewModel),
                          ),
                        ]),
                    const Gap(),
                    Row(
                      children: [
                        CustomButton(
                          semanticLabel:
                              "covenantsConditions.covenantEditDialog.add".tr(),
                          label:
                              "covenantsConditions.covenantEditDialog.add".tr(),
                          onPressed: viewModel.onAddRim,
                        ),
                        const Gap(direction: Axis.horizontal),
                        CustomButton(
                          semanticLabel:
                              "covenantsConditions.covenantEditDialog.cancel"
                                  .tr(),
                          label: "covenantsConditions.covenantEditDialog.cancel"
                              .tr(),
                          onPressed: viewModel.onCancelPress,
                        ),
                      ],
                    ),
                  ]),
                ),

              const Gap(),
              if (viewModel.selectedCovenantTypeEnum ==
                      CovenantType.information &&
                  viewModel.selectedSubTypeValueEnum ==
                      CovenantSubType.financialStatements)
                CustomButton(
                  label:
                      "covenantsConditions.covenantEditDialog.linkFinancialCovenant"
                          .tr(),
                  semanticLabel:
                      "covenantsConditions.covenantEditDialog.linkFinancialCovenant"
                          .tr(),
                  leadingIcon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    viewModel.addLinkFinancialView();
                  },
                ),
              const Gap(),
              // add link financial
              ...viewModel.linkedFinancialCovenants.map((linkedCovenant) {
                return FinancialStatementView(
                  state: state,
                  viewModel: viewModel,
                  linkcovenant: linkedCovenant,
                  onDelete: () =>
                      viewModel.deleteLinkedCovenant(linkedCovenant),
                );
              }),
              const Gap(),
              if (viewModel.selectedCovenantTypeEnum == CovenantType.financial)
                CustomButton(
                  label:
                      "covenantsConditions.covenantEditDialog.addCovenatSubtype"
                          .tr(),
                  semanticLabel:
                      "covenantsConditions.covenantEditDialog.addCovenatSubtype"
                          .tr(),
                  leadingIcon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    viewModel.addFinancialCovenatSubtypeView();
                  },
                ),
              const Gap(),

              //add financial covenat subtpe
              if (state.addFinancialCovenat &&
                  viewModel.selectedCovenantTypeEnum == CovenantType.financial)
                ...viewModel.financialCovenantSubtypes
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final subtype = entry.value;

                  return FinancialCovenantView(
                    viewModel: viewModel,
                    state: state,
                    financialCovenant: subtype,
                    onDelete: () => viewModel.deleteFinancialCovenat(index),
                  );
                }),
              const Gap(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                      label: "covenantsConditions.covenantEditDialog.save".tr(),
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.save".tr(),
                      onPressed: () async {
                        viewModel.onSavePress().then((bool value) {
                          if (value && context.mounted) {
                            Navigator.pop(context);
                          }
                        });
                      }),
                  const Gap(direction: Axis.horizontal),
                  CustomButton(
                      label:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      onPressed: () async {
                        Navigator.pop(context);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _covenantTypeField(
      CovenantEditDialogViewModel viewModel, CovenantEditDialogState state) {
    switch (viewModel.selectedCovenantTypeEnum) {
      case CovenantType.information:
        return Column(
          children: [
            const Gap(),
            const Gap(size: GapSize.small),
            FormRow(children: [
              CovenantDescriptionField(viewModel: viewModel),
              CovenantSubTypeField(viewModel: viewModel),
              const SizedBox(),
            ]),
            _subtypeField(viewModel, state),
          ],
        );
      case CovenantType.financial:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
            FormRow(children: [
              CovenantTestCreditEntity(viewModel: viewModel),
              const SizedBox(),
              const SizedBox()
            ]),
            const Gap(),
            FormRow(children: [
              CreditLensField(
                  initialValue: '', viewModel: viewModel, isRequired: true,isEnabled: true),
              EntityNameField(
                  initialValue: '', viewModel: viewModel, isRequired: true),
              const SizedBox()
            ]),
            const Gap(),
            FormRow(children: [
              SeperationBasisField(viewModel: viewModel),
              AuditStatusField(viewModel: viewModel),
              const SizedBox()
            ]),
            const Gap(),
            // custom text area
            FinancialCovenantInlineField(
              viewModel: viewModel,
              hintText:
                  "covenantsConditions.covenantEditDialog.financialCovenantText"
                      .tr(),
              width: double.infinity,
            ),
            const Gap(),
            FormRow(children: [
              CovenantDescriptionField(
                viewModel: viewModel,
              ),
              FinancialCovenantSubtype(viewModel: viewModel),
              const SizedBox()
            ]),
            const Gap(),
            // custom text area
            FinancialCovenantInlineField(
              viewModel: viewModel,
              hintText: "",
              width: double.infinity,
            ),
            const Gap(),
            FormRow(children: [
              InternalFinancialCevenant(viewModel: viewModel),
              FrequencyField(viewModel: viewModel),
              NextMonitoryDateField(viewModel: viewModel),
            ]),
            const Gap(),
          ],
        );
      case CovenantType.nonFinancial:
        return Column(
          children: [
            const Gap(),
            FormRow(children: [
              CovenantDescriptionField(
                viewModel: viewModel,
              ),
              CovenantSubTypeField(viewModel: viewModel),
              const SizedBox()
            ]),
            const Gap(),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _subtypeField(
      CovenantEditDialogViewModel viewModel, CovenantEditDialogState state) {
    switch (viewModel.selectedSubTypeValueEnum) {
      case CovenantSubType.financialStatements:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
            const Gap(size: GapSize.small),
            FormRow(children: [
              PeriodField(viewModel: viewModel),
              CreditLensField(
                  initialValue: '', viewModel: viewModel, isRequired: false,isEnabled: true),
              EntityNameField(
                  initialValue: '', viewModel: viewModel, isRequired: false),
            ]),
            const Gap(),
            const Gap(size: GapSize.small),
            FormRow(children: [
              SeperationBasisField(viewModel: viewModel),
              AuditStatusField(viewModel: viewModel),
              const SizedBox()
            ]),
          ],
        );
      case CovenantSubType.projectProgressReport:
        return const SizedBox();
      case CovenantSubType.debtorsAndStockAgeing:
        return Column(
          children: [
            const Gap(),
            const Gap(size: GapSize.small),
            FormRow(children: [
              PeriodField(viewModel: viewModel),
              SeperationBasisField(viewModel: viewModel),
              const SizedBox()
            ]),
          ],
        );
      case CovenantSubType.personalNetWorthIncomeStatement:
        return const SizedBox();
      case CovenantSubType.operatingBudget:
        return Column(
          children: [
            const Gap(),
            const Gap(size: GapSize.small),
            FormRow(children: [
              PeriodField(viewModel: viewModel),
              SubmissionTimeField(viewModel: viewModel),
              const SizedBox()
            ]),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
