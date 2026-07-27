import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/action_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_financial_covenant_view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_financial_description_view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/add_rim_no_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/associated_table.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_link_financial.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_tobe_tested_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/finacial_year_end_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_treshold_type.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/frequency_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/general_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/internal_financial_covenant.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/next_monitory_date_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/rim_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/status_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/submission_time_field.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Financial covenant view for the covenant edit dialog.
class FinancialCovenantView extends StatelessWidget {
  /// Creates a financial covenant view.
  const FinancialCovenantView({
    required this.viewModel,
    required this.state,
    required this.financialCovenant,
    required this.onDelete,
    super.key,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Covenant edit dialog state.
  final CovenantEditDialogState state;

  /// Financial covenant data.
  final Covenant financialCovenant;

  /// Callback invoked when deleting the financial covenant.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String? standardName = viewModel.descriptionTypes
        .firstWhere(
          (r) => r.id == ServerConstants.standardDescriptionId,
          orElse: () => viewModel.descriptionTypes.first,
        )
        .name;

    final String? customName = viewModel.descriptionTypes
        .firstWhere(
          (r) => r.id == ServerConstants.customDescriptionId,
          orElse: () =>
              viewModel.descriptionTypes[viewModel.descriptionTypes.length - 1],
        )
        .name;

    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSectionHeader(
                title:
                    "covenantsConditions.covenantEditDialog.financialCovenant"
                        .tr(),
              ),
              CustomButton(
                semanticLabel:
                    "covenantsConditions.covenantEditDialog.deleteCovenant"
                        .tr(),
                label: "covenantsConditions.covenantEditDialog.deleteCovenant"
                    .tr(),
                backgroundColor: Colors.red,
                onPressed: onDelete,
              ),
            ],
          ),
          const Gap(size: GapSize.large),
          FormRow(
            children: [
              CovenantDescriptionLinkFinancial(
                viewModel: viewModel,
                selectedValueOverride: (financialCovenant.isStandard ?? true)
                    ? standardName
                    : customName,
                onChangedOverride: (value) {
                  final bool isStdDescription = (value == standardName);
                  financialCovenant.isStandard = isStdDescription;

                  if (!isStdDescription) {
                    financialCovenant.covenantSubType = null;
                    financialCovenant.thresholdType = null;
                    financialCovenant.threshold = null;
                    financialCovenant.description = "";
                  }

                  viewModel.emit(
                    viewModel.state.copyWith(
                      loaderStatus: LoadingStatus.loaded,
                    ),
                  );
                },
              ),
              FinancialSubtypeDropdownRow(
                viewModel: viewModel,
                row: financialCovenant,
                isEnabled: financialCovenant.isStandard ?? true,
              ),
              InternalFinancialCevenant(
                viewModel: viewModel,
                selectedValueOverride:
                    (financialCovenant.isInternalFinancial ?? true)
                        ? InternalFinancialCovenantType.yes
                        : InternalFinancialCovenantType.no,
                onChangedOverride: (value) {
                  financialCovenant.isInternalFinancial =
                      (value == InternalFinancialCovenantType.yes);
                  viewModel.emit(
                    viewModel.state.copyWith(
                      loaderStatus: LoadingStatus.loaded,
                    ),
                  );
                },
              ),
            ],
          ),
          const Gap(),
          // custom text area
          if (financialCovenant.isStandard ?? true)
            AddFinancialDescriptionView(
              viewModel: viewModel,
              width: double.infinity,
              row: financialCovenant,
            )
          else
            CustomTextArea(
              maxLines: 4,
              minLines: 3,
              hintText:
                  "covenantsConditions.covenantEditDialog.customFinancialCovenantHintText"
                      .tr(),
              hintStyle:
                  const TextStyle(color: AppColors.tableCellColorGroupedRow),
              initialValue: (financialCovenant.description ?? "").trim(),
              maxLength: 2000,
              validator: CustomValidator.requiredField,
              onChanged: (value) {
                financialCovenant
                  ..description = value
                  ..threshold = null;
              },
            ),
          const Gap(),
          FormRow(
            children: [
              SubmissionTimeField(viewModel: viewModel, row: financialCovenant),
              FrequencyField(viewModel: viewModel, row: financialCovenant),
              NextMonitoryDateField(
                key: ValueKey(
                  'row-nmd-${financialCovenant.nextMonitorDate ?? ''}',
                ),
                viewModel: viewModel,
                row: financialCovenant,
              ),
            ],
          ),
          const Gap(),
          FormRow(
            children: [
              FinancialYearEndField(
                key: ValueKey(
                  'row-fye-${financialCovenant.financialYearEndDate ?? ''}',
                ),
                viewModel: viewModel,
                row: financialCovenant,
              ),
              GeneralField(viewModel: viewModel, row: financialCovenant),
              StatusField(viewModel: viewModel),
            ],
          ),
          if (financialCovenant.isGeneric == false)
            AssociatedTable(viewModel: viewModel, row: financialCovenant),
          const Gap(),
          FormRow(
            children: [
              if (viewModel.selectedCovenantTypeEnum !=
                  CovenantType.financial) ...[
                CovenanToBeTestedField(viewModel: viewModel),
                if (viewModel.selectedTestType == CovenantTestType.rim)
                  CustomerRimToBeTested(viewModel: viewModel)
                else
                  NameField(viewModel: viewModel),
                LabelWidget(
                  label: "",
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: viewModel.onAddButtonPress,
                  ),
                ),
              ],
              if (viewModel.selectedCovenantTypeEnum == CovenantType.financial)
                FinancialCovenantTresholdType(
                  viewModel: viewModel,
                  row: financialCovenant,
                  isEnabled:
                      viewModel.shouldEnableRowThresholdType(financialCovenant),
                  selectedItem: viewModel
                      .findThresholdById(financialCovenant.thresholdType),
                  forceEmptySelection: financialCovenant.thresholdType == null,
                ),
            ],
          ),
          const Gap(),
          FormRow(
            children: [
              ActionField(viewModel: viewModel),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          const Gap(),
          if (viewModel.showAddWidgets)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppStyle.linkContractScopeField,
              ),
              child: BoxLayout(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AddCustomerRimField(viewModel: viewModel),
                    ),
                    const Gap(),
                    if (state.searchLoaderStatus == LoadingStatus.loading)
                      const CircularProgressIndicator(),
                    Expanded(
                      child: AddCustomerNameField(viewModel: viewModel),
                    ),
                    const Gap(),
                    CustomButton(
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.add".tr(),
                      label: "covenantsConditions.covenantEditDialog.add".tr(),
                      onPressed: viewModel.addSearchedRimToList,
                    ),
                    const Gap(),
                    CustomButton(
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      label:
                          "covenantsConditions.covenantEditDialog.cancel".tr(),
                      onPressed: viewModel.onCancelPress,
                    ),
                  ],
                ),
              ),
            ),
          const Gap(),
        ],
      ),
    );
  }
}
