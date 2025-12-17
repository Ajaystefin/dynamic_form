import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/action_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_button.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_value_dropdown.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/associated_table.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/audit_status_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/basis_of_seperation_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_link_financial.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_sub_type_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_sub_type_financial_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_test_credit_entity.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_tobe_tested_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_type_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/credit_lens_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/customer_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/entity_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/finacial_year_end_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_description_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_inline_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_view.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_statement_view.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/frequency_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/general_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/internal_financial_covenant.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/label_covenant_tested.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/next_monitory_date_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/period_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/rim_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/status_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/submission_time_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/threshold_type_field.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

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

    viewModel.showOnlyNonFinancialSubtypeItems =
        viewModel.selectedCovenantTypeEnum == CovenantType.nonFinancial;

    return SingleChildScrollView(
      child: BoxLayout(
        extraPadding: true,
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormRow(children: [
                CustomerNameField(
                    viewModel: viewModel, isEnabled: viewModel.isNewCovenant),
                CovenantTypeField(viewModel: viewModel, isEnabled: true),
                const SizedBox()
              ]),
              if (viewModel.selectedCovenantTypeEnum !=
                  CovenantType.financial) ...[
                const Gap(),
                const Gap(size: GapSize.small),
                FormRow(children: [
                  CovenantDescriptionField(viewModel: viewModel),
                  (viewModel.selectedCovenantTypeEnum ==
                          CovenantType.nonFinancial)
                      ? CovenantSubTypeFinancialField(
                          viewModel: viewModel,
                          selectedItem:
                              viewModel.selectedFinancialCovenantSubType,
                          forceEmptySelection:
                              viewModel.isNewCovenant ? true : false,
                          overrideEnablement:
                              viewModel.isLinkFinancialSubtypeEnabled,
                        )
                      : CovenantSubTypeField(viewModel: viewModel),
                  (viewModel.selectedCovenantTypeEnum ==
                              CovenantType.information &&
                          viewModel.selectedSubGeneralTypeValueEnum ==
                              CovenantSubType.operatingBudget)
                      ? PeriodField(viewModel: viewModel)
                      : const SizedBox(),
                ]),
                const Gap(),
                const Gap(size: GapSize.small),
                viewModel.shouldShowDescriptionTextArea
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...[
                            (viewModel.selectedSubGeneralTypeValueEnum ==
                                    CovenantSubType.other)
                                ? LabelWidget(
                                    label:
                                        "covenantsConditions.covenantEditDialog.otherDescription"
                                            .tr(),
                                    child: CustomTextArea(
                                      maxLines: 4,
                                      minLines: 3,
                                      validator: CustomValidator.requiredField,
                                      initialValue: viewModel.isNewCovenant ==
                                              true
                                          ? ''
                                          : ((viewModel.covenant?.description ??
                                                  '')
                                              .trim()),
                                      maxLength: 2000,
                                      onChanged: (value) {
                                        viewModel.covenant?.description = value;
                                      },
                                    ),
                                  )
                                : CustomTextArea(
                                    maxLines: 4,
                                    minLines: 3,
                                    initialValue: viewModel.isNewCovenant ==
                                                true ||
                                            !(viewModel.isFinancialStandard ??
                                                false)
                                        ? ''
                                        : ((viewModel.covenant?.description ??
                                                '')
                                            .trim()),
                                    maxLength: 2000,
                                    validator: CustomValidator.requiredField,
                                    onChanged: (value) {
                                      viewModel.covenant?.description = value;
                                    },
                                  ),
                          ]
                        ],
                      )
                    : const SizedBox(),
              ],

              //show for non - financials only
              if (viewModel.selectedCovenantTypeEnum ==
                      CovenantType.nonFinancial &&
                  (viewModel.isFinancialStandard ?? false)) ...[
                FinancialCovenantDescriptionField(
                  viewModel: viewModel,
                  width: double.infinity,
                ),
                const Gap(),
              ],
              _covenantTypeField(viewModel, state, context),
              FormRow(children: [
                SubmissionTimeField(viewModel: viewModel),
                FrequencyField(viewModel: viewModel),
                NextMonitoryDateField(viewModel: viewModel),
              ]),
              const Gap(),
              const Gap(size: GapSize.small),
              FormRow(children: [
                FinancialYearEndField(viewModel: viewModel),
                GeneralField(viewModel: viewModel),
                StatusField(viewModel: viewModel),
              ]),
              if (viewModel.isSpecificSelected())
                AssociatedTable(
                  viewModel: viewModel,
                ),
              const Gap(), //covenants to be tested ( //add name and customer rim field)
              if (!(viewModel.selectedCovenantTypeEnum ==
                      CovenantType.nonFinancial ||
                  viewModel.selectedCovenantTypeEnum ==
                          CovenantType.information &&
                      (viewModel.selectedSubGeneralTypeValueEnum ==
                              CovenantSubType.projectProgressReport ||
                          viewModel.selectedSubGeneralTypeValueEnum ==
                              CovenantSubType.operatingBudget ||
                          viewModel.selectedSubGeneralTypeValueEnum ==
                              CovenantSubType.other)))
                FormRow(children: [
                  if (viewModel.selectedCovenantTypeEnum !=
                      CovenantType.financial) ...[
                    CovenanToBeTestedField(viewModel: viewModel),
                    viewModel.selectedTestType == CovenantTestType.rim
                        ? CustomerRimToBeTested(viewModel: viewModel)
                        : TestNameField(viewModel: viewModel),
                    viewModel.selectedTestType == CovenantTestType.rim
                        ? AddRimButton(viewModel: viewModel)
                        : const SizedBox(height: 0)
                  ],
                  if (viewModel.selectedCovenantTypeEnum ==
                      CovenantType.financial)
                    TresholdTypeField(
                      viewModel: viewModel,
                    ),
                ]),
              //add customer rim field
              if (viewModel.selectedCovenantTypeEnum ==
                      CovenantType.nonFinancial ||
                  viewModel.selectedCovenantTypeEnum ==
                          CovenantType.information &&
                      (viewModel.selectedSubGeneralTypeValueEnum ==
                              CovenantSubType.projectProgressReport ||
                          viewModel.selectedSubGeneralTypeValueEnum ==
                              CovenantSubType.operatingBudget ||
                          viewModel.selectedSubGeneralTypeValueEnum ==
                              CovenantSubType.other)) ...[
                CovenantTestLabelField(viewModel: viewModel),
                FormRow(children: [
                  CustomerRimToBeTested(viewModel: viewModel),
                  AddRimButton(viewModel: viewModel),
                  const SizedBox(),
                ]),
              ],
              if (viewModel.showAddWidgets)
                AddRimValueDropdown(viewModel: viewModel, state: state),
              const Gap(),
              FormRow(children: [
                ActionField(viewModel: viewModel),
                const SizedBox(),
                const SizedBox(),
              ]),
              const Gap(),
              const Gap(),
              if (viewModel.selectedCovenantTypeEnum ==
                      CovenantType.information &&
                  viewModel.selectedSubGeneralTypeValueEnum ==
                      CovenantSubType.financialStatements)
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
              if (viewModel.selectedCovenantTypeEnum ==
                      CovenantType.information &&
                  viewModel.selectedSubGeneralTypeValueEnum ==
                      CovenantSubType.financialStatements)
                CustomButton(
                  semanticLabel:
                      "covenantsConditions.covenantEditDialog.linkFinancialCovenant"
                          .tr(),
                  label:
                      "covenantsConditions.covenantEditDialog.linkFinancialCovenant"
                          .tr(),
                  leadingIcon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    viewModel.addLinkFinancialView();
                  },
                ),
              const Gap(),
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
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      label:
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
    CovenantEditDialogViewModel viewModel,
    CovenantEditDialogState state,
    BuildContext context,
  ) {
    String descriptionHintText = viewModel.getDescriptionCovenantHint();
    switch (viewModel.selectedCovenantTypeEnum) {
      case CovenantType.information:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            FormRow(children: [
              CreditLensField(
                initialValue: '',
                viewModel: viewModel,
                isRequired: true,
                isEnabled: true,
              ),
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
            FinancialCovenantInlineField(
              viewModel: viewModel,
              hintText: descriptionHintText,
              width: double.infinity,
            ),
            const Gap(),
            FormRow(children: [
              CovenantDescriptionLinkFinancial(
                viewModel: viewModel,
              ),
              CovenantSubTypeFinancialField(
                viewModel: viewModel,
                selectedItem: viewModel.selectedFinancialCovenantSubType,
                forceEmptySelection: viewModel.isNewCovenant ? true : false,
              ),
              InternalFinancialCevenant(viewModel: viewModel),
            ]),
            const Gap(size: GapSize.large),
            (viewModel.isFinancialStandard ?? true)
                ? FinancialCovenantDescriptionField(
                    viewModel: viewModel,
                    width: double.infinity,
                  )
                : CustomTextArea(
                    maxLines: 4,
                    minLines: 3,
                    maxLength: 2000,
                    initialValue: viewModel.isNewCovenant == true ||
                            !(viewModel.isFinancialStandard ?? false)
                        ? ''
                        : ((viewModel.covenant?.description ?? '').trim()),
                    validator: CustomValidator.requiredField,
                    onChanged: (value) {
                      viewModel.covenant?.description = value;
                    },
                  ),
            const Gap(size: GapSize.medium),
          ],
        );
      case CovenantType.nonFinancial:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _subtypeField(
      CovenantEditDialogViewModel viewModel, CovenantEditDialogState state) {
    switch (viewModel.selectedSubGeneralTypeValueEnum) {
      case CovenantSubType.financialStatements:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormRow(children: [
              PeriodField(viewModel: viewModel),
              CreditLensField(
                  initialValue: '',
                  viewModel: viewModel,
                  isRequired: false,
                  isEnabled: true),
              EntityNameField(
                  initialValue: '', viewModel: viewModel, isRequired: false),
            ]),
            const Gap(),
            const Gap(size: GapSize.small),
            FormRow(children: [
              SeperationBasisField(viewModel: viewModel),
              AuditStatusField(viewModel: viewModel),
              const SizedBox.shrink()
            ]),
            const Gap(),
          ],
        );
      case CovenantSubType.projectProgressReport:
        return const SizedBox.shrink();
      case CovenantSubType.debtorsAndStockAgeing:
        return Column(
          children: [
            FormRow(children: [
              PeriodField(viewModel: viewModel),
              SeperationBasisField(viewModel: viewModel),
              const SizedBox()
            ]),
            const Gap(),
            const Gap(size: GapSize.small),
          ],
        );
      case CovenantSubType.personalNetWorthIncomeStatement:
        return const SizedBox.shrink();
      case CovenantSubType.operatingBudget:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
