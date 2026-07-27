import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
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
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/associated_table.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/audit_status_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/basis_of_seperation_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_link_financial.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_test_credit_entity.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_type_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/credit_lens_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/customer_name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/entity_name_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/finacial_year_end_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_inline_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_treshold_type.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/frequency_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/general_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/internal_financial_covenant.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/next_monitory_date_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/status_field.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/submission_time_field.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Financial statement view for the covenant edit dialog.
class FinancialStatementView extends StatelessWidget {
  /// Creates a financial statement view.
  const FinancialStatementView({
    required this.viewModel,
    required this.state,
    required this.linkcovenant,
    required this.onDelete,
    super.key,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Covenant edit dialog state.
  final CovenantEditDialogState state;

  /// Linked covenant data.
  final Covenant linkcovenant;

  /// Callback invoked when deleting the covenant.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String descriptionHintText = viewModel.getDescriptionCovenantHint();
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(size: GapSize.large),
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
              CustomerNameField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView,
                forceShowSelectedCustomer: true,
              ),
              CovenantTypeField(
                viewModel: viewModel,
                isEnabled: false,
                selectedItem: viewModel.selectedLinkFinancialCovenantType,
              ),
              const SizedBox(),
            ],
          ),
          const Gap(),
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
                isRequired: false,
                isEnabled: false,
              ),
              EntityNameField(
                initialValue: "",
                viewModel: viewModel,
                isRequired: false,
                isEnabled: !viewModel.isLinkFinancialView,
              ),
              const SizedBox(),
            ],
          ),
          const Gap(),
          FormRow(
            children: [
              SeperationBasisField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView,
              ),
              AuditStatusField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView,
              ),
              const SizedBox(),
            ],
          ),
          const Gap(size: GapSize.large),
          FinancialCovenantInlineField(
            viewModel: viewModel,
            hintText: descriptionHintText,
            width: double.infinity,
          ),
          const Gap(),
          FormRow(
            children: [
              CovenantDescriptionLinkFinancial(
                viewModel: viewModel,
                selectedValueOverride: (linkcovenant.isStandard ?? true)
                    ? viewModel.descriptionTypes
                        .firstWhere(
                          (r) => r.id == ServerConstants.standardDescriptionId,
                          orElse: () => viewModel.descriptionTypes.first,
                        )
                        .name
                    : viewModel.descriptionTypes
                        .firstWhere(
                          (r) => r.id == ServerConstants.customDescriptionId,
                          orElse: () => viewModel.descriptionTypes[
                              viewModel.descriptionTypes.length - 1],
                        )
                        .name,
                onChangedOverride: (value) {
                  final String? standardName = viewModel.descriptionTypes
                      .firstWhere(
                        (r) => r.id == ServerConstants.standardDescriptionId,
                        orElse: () => viewModel.descriptionTypes.first,
                      )
                      .name;

                  final bool isStdDescription = (value == standardName);

                  linkcovenant.isStandard = isStdDescription;

                  if (!isStdDescription) {
                    // Clear mapped fields & text
                    linkcovenant.covenantSubType = null;
                    linkcovenant.thresholdType = null;
                    linkcovenant.threshold = null; // numeric threshold
                    linkcovenant.description = ""; // show empty textarea
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
                row: linkcovenant,
                isEnabled:
                    (linkcovenant.isStandard ?? true) && !viewModel.isReadOnly,
              ),
              InternalFinancialCevenant(
                viewModel: viewModel,
                selectedValueOverride:
                    (linkcovenant.isInternalFinancial ?? true)
                        ? InternalFinancialCovenantType.yes
                        : InternalFinancialCovenantType.no,
                onChangedOverride: (value) {
                  linkcovenant.isInternalFinancial =
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
          const Gap(size: GapSize.large),
          if (linkcovenant.isStandard ?? true)
            Column(
              children: [
                ...[
                  AddFinancialDescriptionView(
                    viewModel: viewModel,
                    width: double.infinity,
                    row: linkcovenant,
                  ),
                  const Gap(),
                ],
              ],
            )
          else
            CustomTextArea(
              maxLines: 4,
              minLines: 3,
              // initialValue: viewModel.isNewCovenant
              //     ? ""
              //     : ((viewModel.customLinkFinancialDescription ?? "").trim()),
              hintText:
                  "covenantsConditions.covenantEditDialog.customFinancialCovenantHintText"
                      .tr(),
              hintStyle:
                  const TextStyle(color: AppColors.tableCellColorGroupedRow),
              validator: CustomValidator.requiredField,
              maxLength: 2000,
              initialValue: (linkcovenant.description ?? "").trim(),

              onChanged: (value) {
                linkcovenant
                  ..description = value
                  ..threshold = null;
                viewModel.emit(
                  viewModel.state.copyWith(loaderStatus: LoadingStatus.loaded),
                );
              },
            ),
          FormRow(
            children: [
              FinancialCovenantTresholdType(
                viewModel: viewModel,
                row: linkcovenant,
                isEnabled: viewModel.shouldEnableRowThresholdType(linkcovenant),
                selectedItem:
                    viewModel.findThresholdById(linkcovenant.thresholdType),
                forceEmptySelection: linkcovenant.thresholdType == null,
              ),
              SubmissionTimeField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView,
              ),
              FinancialYearEndField(
                key: ValueKey(
                  'fs-fye-${viewModel.covenant?.financialYearEndDate ?? ''}',
                ),
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView,
              ),
            ],
          ),
          const Gap(),
          FormRow(
            children: [
              FrequencyField(
                key:
                    ValueKey("fs-freq-${viewModel.selectedFrequency?.id ?? 0}"),
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView,
              ),
              NextMonitoryDateField(viewModel: viewModel),
              GeneralField(viewModel: viewModel, row: linkcovenant),
            ],
          ),
          const Gap(),
          if (linkcovenant.isGeneric == false)
            AssociatedTable(viewModel: viewModel, row: linkcovenant),
          const Gap(),
          FormRow(
            children: [
              StatusField(viewModel: viewModel),
              ActionField(viewModel: viewModel),
              const SizedBox(),
            ],
          ),
          const Gap(),
        ],
      ),
    );
  }
}
