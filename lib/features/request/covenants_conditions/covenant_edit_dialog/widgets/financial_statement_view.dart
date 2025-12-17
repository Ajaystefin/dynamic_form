import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/state.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/action_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/associated_table.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/audit_status_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/basis_of_seperation_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_description_link_financial.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_sub_type_financial_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_test_credit_entity.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/covenant_type_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/credit_lens_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/customer_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/entity_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/finacial_year_end_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_description_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/financial_covenant_inline_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/frequency_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/general_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/internal_financial_covenant.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/next_monitory_date_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/status_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/submission_time_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/widgets/threshold_type_field.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';

class FinancialStatementView extends StatelessWidget {
  final CovenantEditDialogViewModel viewModel;
  final CovenantEditDialogState state;
  final Covenant linkcovenant;
  final VoidCallback onDelete;

  const FinancialStatementView({
    super.key,
    required this.viewModel,
    required this.state,
    required this.linkcovenant,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    String descriptionHintText = viewModel.getDescriptionCovenantHint();
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(size: GapSize.large),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CustomSectionHeader(
              title: 'covenantsConditions.covenantEditDialog.financialCovenant'
                  .tr(),
            ),
            CustomButton(
              semanticLabel:
                  'covenantsConditions.covenantEditDialog.deleteCovenant'.tr(),
              label:
                  'covenantsConditions.covenantEditDialog.deleteCovenant'.tr(),
              backgroundColor: Colors.red,
              onPressed: onDelete,
            ),
          ]),
          const Gap(size: GapSize.large),
          FormRow(children: [
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
            const SizedBox()
          ]),
          const Gap(size: GapSize.medium),
          const Gap(size: GapSize.medium),
          FormRow(children: [
            CovenantTestCreditEntity(viewModel: viewModel),
            const SizedBox(),
            const SizedBox()
          ]),
          FormRow(children: [
            CreditLensField(
              initialValue: '',
              viewModel: viewModel,
              isRequired: false,
              // isEnabled: viewModel.isLinkFinancialView
              isEnabled: false,
            ),
            EntityNameField(
                initialValue: '',
                viewModel: viewModel,
                isRequired: false,
                isEnabled: !viewModel.isLinkFinancialView),
            const SizedBox()
          ]),
          const Gap(size: GapSize.medium),
          FormRow(children: [
            SeperationBasisField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView),
            AuditStatusField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView),
            const SizedBox()
          ]),
          const Gap(size: GapSize.large),
          FinancialCovenantInlineField(
            viewModel: viewModel,
            hintText: descriptionHintText,
            width: double.infinity,
          ),
          const Gap(size: GapSize.medium),
          FormRow(children: [
            CovenantDescriptionLinkFinancial(
              viewModel: viewModel,
            ),
            CovenantSubTypeFinancialField(
              viewModel: viewModel,
              selectedItem: viewModel.selectedFinancialCovenantSubType,
              forceEmptySelection: true,
              overrideEnablement: viewModel.isLinkFinancialSubtypeEnabled,
            ),
            InternalFinancialCevenant(viewModel: viewModel),
          ]),
          const Gap(size: GapSize.large),
          (viewModel.isLinkFinancialSubtypeEnabled)
              ? Column(
                  children: [
                    ...[
                      FinancialCovenantDescriptionField(
                          viewModel: viewModel, width: double.infinity),
                      const Gap(),
                    ]
                  ],
                )
              : CustomTextArea(
                  maxLines: 4,
                  minLines: 3,
                  initialValue: viewModel.isNewCovenant == true
                      ? ''
                      : ((viewModel.customLinkFinancialDescription ?? '')
                          .trim()),
                  validator: CustomValidator.requiredField,
                  maxLength: 2000,
                  onChanged: (value) {
                    viewModel.customLinkFinancialDescription = value;
                  },
                ),
          FormRow(children: [
            TresholdTypeField(
              viewModel: viewModel,
              // isEnabled: !viewModel.isLinkFinancialView
            ),
            SubmissionTimeField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView),
            FinancialYearEndField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView),
          ]),
          const Gap(size: GapSize.medium),
          FormRow(children: [
            FrequencyField(
                viewModel: viewModel,
                isEnabled: !viewModel.isLinkFinancialView),
            NextMonitoryDateField(viewModel: viewModel),
            GeneralField(
              viewModel: viewModel,
            ),
          ]),
          const Gap(size: GapSize.medium),
          if (viewModel.isSpecificSelected())
            AssociatedTable(
              viewModel: viewModel,
            ),
          const Gap(size: GapSize.medium),
          FormRow(children: [
            StatusField(viewModel: viewModel),
            ActionField(viewModel: viewModel),
            const SizedBox()
          ]),
          const Gap(size: GapSize.medium),
        ],
      ),
    );
  }
}
