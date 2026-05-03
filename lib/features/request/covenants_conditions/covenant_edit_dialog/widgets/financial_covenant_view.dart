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

class FinancialCovenantView extends StatelessWidget {
  const FinancialCovenantView({
    required this.viewModel,
    required this.state,
    required this.financialCovenant,
    required this.onDelete,
    super.key,
  });
  final CovenantEditDialogViewModel viewModel;
  final CovenantEditDialogState state;
  final Covenant financialCovenant;
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
          const Gap(size: GapSize.medium),
          // custom text area
          (financialCovenant.isStandard ?? true)
              ? AddFinancialDescriptionView(
                  viewModel: viewModel,
                  width: double.infinity,
                  row: financialCovenant,
                )
              : CustomTextArea(
                  maxLines: 4,
                  minLines: 3,
                  // initialValue: viewModel.isNewCovenant == true
                  //     ? ''
                  //     : ((viewModel.customAddCSFinancialDescription ?? '')
                  //         .trim()),

                  initialValue: (financialCovenant.description ?? "").trim(),
                  maxLength: 2000,
                  validator: CustomValidator.requiredField,
                  onChanged: (value) {
                    // viewModel.customAddCSFinancialDescription = value;
                    financialCovenant.description = value; // per-row
                  },
                ),
          const Gap(size: GapSize.medium),
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
          const Gap(size: GapSize.medium),
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
          const Gap(size: GapSize.medium),
          FormRow(
            children: [
              if (viewModel.selectedCovenantTypeEnum !=
                  CovenantType.financial) ...[
                CovenanToBeTestedField(viewModel: viewModel),
                viewModel.selectedTestType == CovenantTestType.rim
                    ? CustomerRimToBeTested(viewModel: viewModel)
                    : NameField(viewModel: viewModel),
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
                  isEnabled: (financialCovenant.isStandard ?? true) &&
                      viewModel.isRowThresholdEditable(financialCovenant),
                  selectedItem: viewModel
                      .findThresholdById(financialCovenant.thresholdType),
                  forceEmptySelection: financialCovenant.thresholdType == null,
                ),
            ],
          ),
          const Gap(size: GapSize.medium),
          FormRow(
            children: [
              ActionField(viewModel: viewModel),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          const Gap(size: GapSize.medium),
          if (viewModel.showAddWidgets)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppStyle.linkContractScopeField,
              ),
              child: BoxLayout(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: AddCustomerRimField(viewModel: viewModel),
                    ),
                    const Gap(size: GapSize.medium),
                    if (state.searchLoaderStatus == LoadingStatus.loading)
                      const CircularProgressIndicator(),
                    Expanded(
                      flex: 1,
                      child: AddCustomerNameField(viewModel: viewModel),
                    ),
                    const Gap(size: GapSize.medium),
                    CustomButton(
                      semanticLabel:
                          "covenantsConditions.covenantEditDialog.add".tr(),
                      label: "covenantsConditions.covenantEditDialog.add".tr(),
                      onPressed: viewModel.addSearchedRimToList,
                    ),
                    const Gap(size: GapSize.medium),
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
          const Gap(size: GapSize.medium),
        ],
      ),
    );
  }
}
