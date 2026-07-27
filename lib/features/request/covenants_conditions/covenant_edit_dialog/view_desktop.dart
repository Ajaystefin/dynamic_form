import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/action_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_button.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_value_dropdown.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/associated_table.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/audit_status_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/basis_of_seperation_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_link_financial.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_sub_type_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_sub_type_financial_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_test_credit_entity.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_tobe_tested_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_type_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/credit_lens_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/customer_name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/entity_name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/finacial_year_end_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_description_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_inline_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_desktop_dropdown.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_statement_view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/frequency_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/general_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/internal_financial_covenant.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/label_covenant_tested.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/next_monitory_date_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/period_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/rim_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/status_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/submission_time_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/threshold_type_field.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Desktop view for the covenant edit dialog.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final CovenantEditDialogViewModel viewModel =
        context.read<CovenantEditDialogViewModel>();
    return BlocBuilder<CovenantEditDialogViewModel, CovenantEditDialogState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    CovenantEditDialogState state,
    CovenantEditDialogViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("common.emptyState".tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.errorState".tr()),
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
    final CovenantEditDialogState state =
        context.watch<CovenantEditDialogViewModel>().state;

    viewModel.showOnlyNonFinancialSubtypeItems =
        viewModel.selectedCovenantTypeEnum == CovenantType.nonFinancial;

    final bool isNonFinancial =
        viewModel.selectedCovenantTypeEnum == CovenantType.nonFinancial;

    final bool showOperatingBudgetPeriod =
        viewModel.selectedCovenantTypeEnum == CovenantType.information &&
            viewModel.selectedSubGeneralTypeValueEnum ==
                CovenantSubType.operatingBudget;

    return SingleChildScrollView(
      child: BoxLayout(
        disabled: !viewModel.canEdit,
        extraPadding: true,
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormRow(
                children: [
                  CustomerNameField(
                    viewModel: viewModel,
                    isEnabled: viewModel.isNewCovenant,
                  ),
                  CovenantTypeField(viewModel: viewModel, isEnabled: true),
                  const SizedBox(),
                ],
              ),
              if (viewModel.selectedCovenantTypeEnum !=
                  CovenantType.financial) ...[
                const Gap(),
                const Gap(size: GapSize.small),
                FormRow(
                  children: [
                    // Description radio button selection
                    CovenantDescriptionField(
                      key: ValueKey(
                        "nf-desc-radio-"
                        "${viewModel.isFinancialStandard ?? false}",
                      ),
                      viewModel: viewModel,
                    ),

                    // Subtype: Financial-subtype widget for Non-Financial,
                    //else the generic subtype widget
                    if (isNonFinancial)
                      CovenantSubTypeFinancialField(
                        key: ValueKey(
                          "nf-subtype-"
                          "${viewModel.isLinkFinancialSubtypeEnabled}",
                        ),
                        viewModel: viewModel,
                        selectedItem:
                            viewModel.selectedFinancialCovenantSubType,
                        forceEmptySelection: viewModel.isNewCovenant ||
                            !viewModel.isLinkFinancialSubtypeEnabled,
                        overrideEnablement:
                            viewModel.isLinkFinancialSubtypeEnabled,
                      )
                    else
                      CovenantSubTypeField(viewModel: viewModel),

                    // Third column:
                    //    - Non-Financial: show AuditStatusField here
                    //    - Information + Operating Budget: show PeriodField
                    // (your current behavior)
                    //    - Otherwise: keep empty slot to preserve 3-column
                    // alignment

                    if (isNonFinancial)
                      AuditStatusField(viewModel: viewModel)
                    else
                      showOperatingBudgetPeriod
                          ? PeriodField(viewModel: viewModel)
                          : const SizedBox(),
                  ],
                ),
                const Gap(),
                const Gap(size: GapSize.small),
                if (viewModel.shouldShowDescriptionTextArea)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...[
                        if (viewModel.selectedSubGeneralTypeValueEnum ==
                            CovenantSubType.other)
                          LabelWidget(
                            label: "covenantsConditions."
                                    "covenantEditDialog"
                                    ".otherDescription"
                                .tr(),
                            child: CustomTextArea(
                              readOnly: !viewModel.canEdit,
                              maxLines: 4,
                              minLines: 3,
                              validator: CustomValidator.requiredField,
                              initialValue: viewModel.isNewCovenant
                                  ? ""
                                  : ((viewModel.covenant?.description ?? "")
                                      .trim()),
                              maxLength: 2000,
                              onChanged: (value) {
                                viewModel.covenant?.description = value;
                              },
                            ),
                          )
                        else
                          CustomTextArea(
                            readOnly: !viewModel.canEdit,
                            maxLines: 4,
                            minLines: 3,
                            initialValue: viewModel.isNewCovenant
                                ? ""
                                : ((viewModel.covenant?.description ?? "")
                                    .trim()),
                            maxLength: 2000,
                            validator: CustomValidator.requiredField,
                            onChanged: (value) {
                              viewModel.covenant?.description = value;
                            },
                          ),
                      ],
                    ],
                  )
                else
                  const SizedBox(),
              ],

              //show for non - financials only
              if (isNonFinancial &&
                  (viewModel.isFinancialStandard ?? false)) ...[
                FinancialCovenantDescriptionField(
                  key: ValueKey(
                    "nf-std-desc-${viewModel.isFinancialStandard ?? false}",
                  ),
                  viewModel: viewModel,
                  width: double.infinity,
                ),
                const Gap(),
              ],
              _covenantTypeField(viewModel, state, context),
              FormRow(
                children: [
                  SubmissionTimeField(viewModel: viewModel),
                  FrequencyField(
                    key: ValueKey(
                      "freq-"
                      "${viewModel.selectedCovenantTypeEnum}-"
                      "${viewModel.selectedGeneralCovenantSubType?.id ?? 0}",
                    ),
                    viewModel: viewModel,
                  ),
                  NextMonitoryDateField(viewModel: viewModel),
                ],
              ),
              const Gap(),
              const Gap(size: GapSize.small),
              FormRow(
                children: [
                  FinancialYearEndField(
                    key: ValueKey(
                      "fs-fye-"
                      '${viewModel.covenant?.financialYearEndDate ?? ""}',
                    ),
                    viewModel: viewModel,
                  ),
                  GeneralField(viewModel: viewModel),
                  StatusField(viewModel: viewModel),
                ],
              ),

              if (viewModel.isSpecificSelected())
                AssociatedTable(
                  viewModel: viewModel,
                ),
              // Covenants to be tested: add name and customer rim field
              const Gap(),
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
                FormRow(
                  children: [
                    if (viewModel.selectedCovenantTypeEnum !=
                        CovenantType.financial) ...[
                      CovenanToBeTestedField(viewModel: viewModel),
                      if (viewModel.selectedTestType == CovenantTestType.rim)
                        CustomerRimToBeTested(viewModel: viewModel)
                      else
                        NameField(viewModel: viewModel),
                      if (viewModel.selectedTestType == CovenantTestType.rim)
                        AddRimButton(viewModel: viewModel)
                      else
                        const SizedBox(height: 0),
                    ],
                    if (viewModel.selectedCovenantTypeEnum ==
                        CovenantType.financial)
                      TresholdTypeField(
                        isEnabled: viewModel.shouldEnableMainThresholdType,
                        viewModel: viewModel,
                      ),
                  ],
                ),
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
                FormRow(
                  children: [
                    CustomerRimToBeTested(viewModel: viewModel),
                    AddRimButton(viewModel: viewModel),
                    const SizedBox(),
                  ],
                ),
              ],
              if (viewModel.showAddWidgets)
                AddRimValueDropdown(viewModel: viewModel, state: state),
              const Gap(),
              FormRow(
                children: [
                  ActionField(viewModel: viewModel),
                  const SizedBox(),
                  const SizedBox(),
                ],
              ),
              const Gap(),
              const Gap(),
              //add link financial covenat subtype button
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
                  semanticLabel: "covenantsConditions.covenantEditDialog."
                          "linkFinancialCovenant"
                      .tr(),
                  label: "covenantsConditions.covenantEditDialog."
                          "linkFinancialCovenant"
                      .tr(),
                  leadingIcon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    viewModel.addLinkFinancialView();
                  },
                ),
              const Gap(),
              const Gap(),
              //add financial covenat subtype button
              if (state.addFinancialCovenat &&
                  viewModel.selectedCovenantTypeEnum == CovenantType.financial)
                ...viewModel.financialCovenantSubtypes
                    .asMap()
                    .entries
                    .map((entry) {
                  final int index = entry.key;
                  final Covenant subtype = entry.value;

                  return FinancialCovenantView(
                    key: ValueKey("fin-subtype-$index"), // NEW: stable key
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
              if (viewModel.canEdit || viewModel.canEditComments)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      ignoreProvider: viewModel.canEditComments,
                      label: "covenantsConditions.covenantEditDialog.save".tr(),
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.save".tr(),
                      onPressed: () async {
                        final bool result = await viewModel.onSavePress();
                        if (result && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Gap(direction: Axis.horizontal),
                    CustomButton(
                      ignoreProvider: viewModel.canEditComments,
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      label:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
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
    final String descriptionHintText = viewModel.getDescriptionCovenantHint();
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
            FormRow(
              children: [
                CovenantTestCreditEntity(viewModel: viewModel),
                const SizedBox(),
                const SizedBox(),
              ],
            ),
            FormRow(
              children: [
                CreditLensField(
                  initialValue: "",
                  viewModel: viewModel,
                  isRequired: true,
                  isEnabled: true,
                ),
                EntityNameField(
                  initialValue: "",
                  viewModel: viewModel,
                  isRequired: true,
                ),
                const SizedBox(),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                SeperationBasisField(viewModel: viewModel),
                AuditStatusField(viewModel: viewModel),
                const SizedBox(),
              ],
            ),
            const Gap(),
            FinancialCovenantInlineField(
              viewModel: viewModel,
              hintText: descriptionHintText,
              width: double.infinity,
            ),
            const Gap(),
            FormRow(
              children: [
                CovenantDescriptionLinkFinancial(
                  key: ValueKey(
                    "desc-radio-${viewModel.isFinancialStandard ?? false}",
                  ), // NEW
                  viewModel: viewModel,
                ),
                FinancialSubtypeDropdownDesktop(
                  key: ValueKey(
                    "desktop-subtype-${viewModel.isFinancialStandard ?? false}",
                  ),
                  viewModel: viewModel,
                  forceEmptySelection: viewModel.isNewCovenant ||
                      !(viewModel.isFinancialStandard ?? true),
                ),
                InternalFinancialCevenant(viewModel: viewModel),
              ],
            ),
            const Gap(size: GapSize.large),
            if (viewModel.isFinancialStandard ?? true)
              FinancialCovenantDescriptionField(
                key: ValueKey(
                  "desktop-std-desc-"
                  "${viewModel.isFinancialStandard ?? false}",
                ),
                viewModel: viewModel,
                width: double.infinity,
              )
            else
              CustomTextArea(
                readOnly: !viewModel.canEdit,
                key: ValueKey(
                  "desktop-custom-desc-"
                  "${viewModel.isFinancialStandard ?? false}",
                ),
                maxLines: 4,
                minLines: 3,
                maxLength: 2000,
                hintText:
                    "covenantsConditions.covenantEditDialog.customFinancialCovenantHintText"
                        .tr(),
                hintStyle:
                    const TextStyle(color: AppColors.tableCellColorGroupedRow),
                initialValue: viewModel.isNewCovenant &&
                        !(viewModel.isFinancialStandard ?? true)
                    ? ""
                    : ((viewModel.covenant?.description ?? "").trim()),
                validator: CustomValidator.requiredField,
                onChanged: (value) {
                  viewModel.covenant
                    ?..description = value
                    ..threshold = null;
                },
              ),
            const Gap(),
          ],
        );
      case CovenantType.nonFinancial:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _subtypeField(
    CovenantEditDialogViewModel viewModel,
    CovenantEditDialogState state,
  ) {
    switch (viewModel.selectedSubGeneralTypeValueEnum) {
      case CovenantSubType.financialStatements:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormRow(
              children: [
                PeriodField(viewModel: viewModel),
                CreditLensField(
                  initialValue: "",
                  viewModel: viewModel,
                  isRequired: false,
                  isEnabled: true,
                ),
                EntityNameField(
                  initialValue: "",
                  viewModel: viewModel,
                  isRequired: false,
                ),
              ],
            ),
            const Gap(),
            const Gap(size: GapSize.small),
            FormRow(
              children: [
                SeperationBasisField(viewModel: viewModel),
                AuditStatusField(viewModel: viewModel),
                const SizedBox.shrink(),
              ],
            ),
            const Gap(),
          ],
        );
      case CovenantSubType.projectProgressReport:
        return const SizedBox.shrink();
      case CovenantSubType.debtorsAndStockAgeing:
        return Column(
          children: [
            FormRow(
              children: [
                PeriodField(viewModel: viewModel),
                SeperationBasisField(viewModel: viewModel),
                const SizedBox(),
              ],
            ),
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
