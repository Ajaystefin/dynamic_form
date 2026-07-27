import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/currency/converted_amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/borrower_role.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/cash_collateral.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/cmo_remarks.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/country_of_security.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/current_time_deposit_account_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/deferred_till.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/deferred_waived.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/emirates.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/is_security_expiry_open_ended.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/is_security_provider_cbd_customer.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/limit_controlling_security.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/present_security_amount.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/proposed_security_amount.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/remarks.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_code.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_desc.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_expire_date.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_group.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_held_by.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_address.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_category.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_country_incorporation.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_emirates_id.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_legal_status.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_name.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_nationality.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_rim_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_tl_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_status.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/fields/tangible_security.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/widgets/action_widgets.dart";

/// Desktop view for displaying the security creation and maintenance screen.
class ViewDesktop extends StatelessWidget {
  /// Creates a desktop view instance.
  const ViewDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CreateSecurityViewModel viewModel =
        context.read<CreateSecurityViewModel>();
    return BlocBuilder<CreateSecurityViewModel, CreateSecurityState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    CreateSecurityState state,
    CreateSecurityViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    CreateSecurityState state,
    CreateSecurityViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        disabled: !viewModel.canEdit,
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(),
              CustomSectionHeader(title: "security.createSecurity.title".tr()),
              const Gap(),
              Column(
                children: [
                  BoxLayout(
                    child: TopSectionDetails(
                      request: viewModel.request,
                    ),
                  ),
                  if (state.securityTypeStatus != LoadingStatus.loaded &&
                      !viewModel.isUpdateFlow)
                    BoxLayout(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FormRow(
                            children: [
                              SecurityGroup(viewModel: viewModel),
                              TypeOfSecurity(viewModel: viewModel),
                              const SizedBox(),
                            ],
                          ),
                          const Gap(),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppStyle.spacingLarge,
                            ),
                            child: CustomButton(
                              label: "common.continue".tr(),
                              onPressed: viewModel.security.securityType != null
                                  ? () {
                                      viewModel.loadDynamicForm();
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (state.securityTypeStatus == LoadingStatus.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppStyle.spacingLarge,
                        vertical: AppStyle.spacingLarge,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  if (state.securityTypeStatus == LoadingStatus.loaded)
                    BoxLayout(
                      extraPadding: true,
                      disabled: !viewModel.canEdit,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(),
                          FormRow(
                            children: [
                              SecurityDescription(viewModel: viewModel),
                              SecurityCode(viewModel: viewModel),
                              SecurityNumber(viewModel: viewModel),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          FormRow(
                            children: [
                              TangibleSecurity(viewModel: viewModel),
                              LimitControllingSecurity(viewModel: viewModel),
                              CashCollateral(viewModel: viewModel),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          FormRow(
                            children: [
                              PresentSecurityAmount(viewModel: viewModel),
                              ProposedSecurityAmount(viewModel: viewModel),
                              BorrowerRole(viewModel: viewModel),
                            ],
                          ),
                          FormRow(
                            children: [
                              if (viewModel.showPresentSecurityAmount)
                                ConvertedAmountField(
                                  currencies: viewModel.currencyCodes,
                                  controller: viewModel
                                      .newPresentSecurityAmountController,
                                  isDropdownEnabled:
                                      Globals.request?.applicationSubType ==
                                          ServerConstants.manualEntry,
                                  dropdownItemBuilder:
                                      currencyListTileItemBuilder,
                                  inputFormatters: securityAmountFormatters(),
                                  // Long-standing behaviour: unlike the
                                  // proposed side, this AED field is editable
                                  // and unfilled, and PresentSecurityAmount
                                  // .onSaved reads it back into
                                  // security.aedPresentSecurity.
                                  readOnly: false,
                                  filled: false,
                                )
                              else
                                const SizedBox(),
                              if (viewModel.showProposedSecurityAmount)
                                ConvertedAmountField(
                                  currencies: viewModel.currencyCodes,
                                  controller: viewModel
                                      .newProposedSecurityAmountController,
                                  isDropdownEnabled:
                                      Globals.request?.applicationSubType ==
                                          ServerConstants.manualEntry,
                                  dropdownItemBuilder:
                                      currencyListTileItemBuilder,
                                  inputFormatters:
                                      securityAmountFormatters(maxLength: 12),
                                )
                              else
                                const SizedBox(),
                              const SizedBox(),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          FormRow(
                            children: [
                              IsSecurityProviderCbdCustomer(
                                viewModel: viewModel,
                              ),
                              IsSecurityExpiryOpenEnded(viewModel: viewModel),
                              SecurityExpireDate(viewModel: viewModel),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          FormRow(
                            children: [
                              SecurityProviderRimNumber(viewModel: viewModel),
                              SecurityProviderName(viewModel: viewModel),
                              Visibility(
                                visible:
                                    !(viewModel.security.securityType?.id ==
                                        ServerConstants.personalGuaranteeId),
                                child: SecurityProviderCountryIncorporation(
                                  viewModel: viewModel,
                                ),
                              ),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          if (!viewModel.isGuaranteeType) ...[
                            FormRow(
                              children: [
                                SecurityProviderCategory(viewModel: viewModel),
                                SecurityProviderLegalStatus(
                                  viewModel: viewModel,
                                ),
                                SecurityProviderTlNumber(viewModel: viewModel),
                              ],
                            ),
                            const Gap(size: GapSize.large),
                            FormRow(
                              children: [
                                SecurityProviderAddress(viewModel: viewModel),
                                SecurityProviderEmiratesId(
                                  viewModel: viewModel,
                                ),
                                SecurityProviderNationality(
                                  viewModel: viewModel,
                                ),
                              ],
                            ),
                            const Gap(size: GapSize.large),
                            FormRow(
                              children: [
                                CountryOfSecurity(viewModel: viewModel),
                                Emirates(viewModel: viewModel),
                                Visibility(
                                  visible:
                                      viewModel.security.securityType?.id == 78,
                                  child: CurrentTimeDepositAccountNumber(
                                    viewModel: viewModel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Gap(size: GapSize.large),
                          if (viewModel.sections.isNotEmpty)
                            DynamicForm(
                              sections: viewModel.sections,
                              document: viewModel.dynamicFormDocument,
                              key: viewModel.dynamicFormKey,
                              onFieldChange: viewModel.onDynamicFormFieldChange,
                              // Lock entire form when canEdit is false
                              readOnly: !viewModel.canEdit,
                              // allow editing ONLY CMO-flagged fields when in edit mode
                              disableAllExceptCMOUpdate:
                                  viewModel.canEdit && viewModel.isCmoUpdate(),
                            ),
                          const Gap(size: GapSize.large),
                          FormRow(
                            children: [
                              DeferredWaivedBy(viewModel: viewModel),
                              DeferredTill(viewModel: viewModel),
                              const SizedBox(),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          FormRow(
                            children: [
                              SecurityHeldBy(viewModel: viewModel),
                              SecurityStatus(viewModel: viewModel),
                              const SizedBox(),
                            ],
                          ),
                          const Gap(size: GapSize.large),
                          if (viewModel.isFIFlow) ...[
                            Row(
                              children: [
                                Expanded(child: Remarks(viewModel: viewModel)),
                              ],
                            ),
                            const Gap(size: GapSize.large),
                            Row(
                              children: [
                                Expanded(
                                  child: CmoRemarks(viewModel: viewModel),
                                ),
                              ],
                            ),
                          ] else
                            FormRow(
                              children: [
                                Remarks(viewModel: viewModel),
                                CmoRemarks(viewModel: viewModel),
                              ],
                            ),
                          const Gap(size: GapSize.large),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "security.createSecurity.cmoUpdatableFields"
                                    .tr(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (viewModel.canEdit ||
                                  viewModel.isCmoUpdate() ||
                                  Utils.checkApplicationType(
                                    ApplicationType.cancellation,
                                  ))
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: ActionWidgets(
                                    viewModel: viewModel,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
