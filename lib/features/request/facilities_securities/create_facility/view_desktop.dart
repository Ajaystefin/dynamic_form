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
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/account_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/advance_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/borrower_rim.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/collatarel_dependant.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/commitment_account_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/committed.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/controlling_limit_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/country_risk.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/cross_boarder_exposure.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/emirates.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/facility_title.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_cbd_equity.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_counter_party.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_counterparty_assets.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_max_limit.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_max_limit_cc.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_revised_bank.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_revised_bank_cc.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_tenor.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_availability_date.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_description.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/original_limit.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/past_dues.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/policy_deviations.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/present_limit.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/present_outstanding.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/project_finance_related_activity.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/project_name.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/promissory_note.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/property_subtype.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/property_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/proposed_by_cc.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/proposed_limit.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/purpose.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/regulatory_landing_specify.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/regulatory_specialised_landing.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/remarks.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sector.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/seniority.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/shared_limit.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sic_code.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sustanability_classification.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/add_fee_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/contracting_condition_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/create_project_field.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/limit_allocation.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/limit_caps.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/non_std_condition_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/std_conditions_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/sub_limit_table.dart";

/// Desktop view for the create facility screen.
class ViewDesktop extends StatelessWidget {
  /// Creates a desktop view for the create facility screen.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateFacilityViewModel viewModel =
        context.read<CreateFacilityViewModel>();
    return BlocBuilder<CreateFacilityViewModel, CreateFacilityState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    CreateFacilityState state,
    CreateFacilityViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("Empty State".tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("Error State".tr()),
        );
      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    CreateFacilityState state,
    CreateFacilityViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: viewModel.formKey,
        child: BoxLayout(
          disabled: !viewModel.canEdit,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              CustomSectionHeader(
                title: "facilities.createFacility.title".tr(),
              ),
              Column(
                children: [
                  BoxLayout(
                    child: TopSectionDetails(
                      request: Globals.request!,
                    ),
                  ),
                  _buildFacilityDescriptionSection(state, viewModel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityDescriptionSection(
    CreateFacilityState state,
    CreateFacilityViewModel viewModel,
  ) {
    if (state.navigateToCreateFacility == LoadingStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppStyle.spacingLarge,
          horizontal: AppStyle.spacingLarge,
        ),
        child: CircularProgressIndicator(),
      );
    } else {
      // wait for facility details in the existing-facility flow ---
      final bool waitingExisting =
          !viewModel.showCreateFacilityForm && viewModel.facilityDetail.isEmpty;

      if (waitingExisting) {
        // Still waiting for getFacilityDetails/getProjectList → keep spinner
        return const Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppStyle.spacingLarge,
            horizontal: AppStyle.spacingLarge,
          ),
          child: CircularProgressIndicator(),
        );
      }

      if (viewModel.isLimitCaps) {
        return BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [LimitCaps(viewModel: viewModel)],
          ),
        );
      } else {
        return BoxLayout(
          disabled: !viewModel.canEdit,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LimitDescription(viewModel: viewModel),
                              const Gap(),
                              LimitType(
                                viewModel: viewModel,
                              ), //main limit sub limit
                            ],
                          ),
                        ),
                        const Gap(
                          size: GapSize.large,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                  ),
                  const Gap(
                    size: GapSize.large,
                    direction: Axis.horizontal,
                  ),
                  Expanded(flex: 2, child: FacilityTitle(viewModel: viewModel)),
                ],
              ),
              const Gap(),
              FormRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdvanceType(viewModel: viewModel),
                  CommitmentAccountNumber(viewModel: viewModel),
                  SustanabilityClassification(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  PresentOutstanding(viewModel: viewModel),
                  FacilityPastDues(viewModel: viewModel),
                  OriginalLimit(viewModel: viewModel),
                ],
              ),
              // if (viewModel.showNewPresentOutStandingLimit)
              //   FormRow(  /// check why this triggering after select currency in proposed limit
              //     children: [
              //       ConvertedAmountField(
              //         currencies: viewModel.currencyCodes,
              //         controller: viewModel.newPresentOutStandingController,
              //         inputFormatters: currencyAmountFormatters(),
              //       ),
              //       const SizedBox(),
              //       const SizedBox(),
              //     ],
              //   ),
              const Gap(),
              FormRow(
                children: [
                  PresentLimit(
                    viewModel: viewModel,
                  ),
                  ProposedLimit(viewModel: viewModel),
                  FacilityProposedByCC(viewModel: viewModel),
                ],
              ),
              FormRow(
                children: [
                  if (viewModel.showNewPresentLimitAmount)
                    ConvertedAmountField(
                      currencies: viewModel.currencyCodes,
                      controller: viewModel.newPresentLimitController,
                      inputFormatters: currencyAmountFormatters(),
                      isLoadingListenable:
                          viewModel.rateLoadingFor(CurrencyField.presentLimit),
                    )
                  else
                    const SizedBox(),
                  if (viewModel.showNewProposedLimitAmount &&
                      !viewModel.isFIFlow)
                    ConvertedAmountField(
                      currencies: viewModel.currencyCodes,
                      controller: viewModel.newProposedLimitController,
                      inputFormatters: currencyAmountFormatters(),
                      isLoadingListenable:
                          viewModel.rateLoadingFor(CurrencyField.proposedLimit),
                    )
                  else
                    const SizedBox(),
                  if (viewModel.showNewProposedByCCAmount)
                    ConvertedAmountField(
                      currencies: viewModel.currencyCodes,
                      controller: viewModel.newProposedByccController,
                      inputFormatters: currencyAmountFormatters(),
                      isLoadingListenable:
                          viewModel.rateLoadingFor(CurrencyField.proposedBycc),
                    )
                  else
                    const SizedBox(),
                ],
              ),
              showFiGap(showFiGap: viewModel.isFIFlow),
              if (viewModel.isFIFlow)
                LabelWidget(
                  label: "facilities.createFacility.proposedByFI".tr(),
                  labelStyle: customLableStyle(),
                ),
              showFiGap(showFiGap: viewModel.isFIFlow),
              if (viewModel.isFIFlow)
                FormRow(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FiRevisedBank(viewModel: viewModel),
                    FiExcessMaxLimit(viewModel: viewModel),
                    const SizedBox.shrink(),
                  ],
                ),

              if (viewModel.isFIFlow)
                Builder(
                  builder: (context) {
                    // Aliases for line-length compliance
                    final bool showFiProp = viewModel
                        .showNewExcessOverMaxLimitAllowanceProposedByFiAmount;
                    final ctrl = viewModel
                        .newExcessOverMaxLimitAllowanceProposedByFiController;
                    return FormRow(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (viewModel.showNewRevisedBankLimitProposedByFiAmount)
                          ConvertedAmountField(
                            currencies: viewModel.currencyCodes,
                            controller: viewModel.newProposedLimitController,
                            inputFormatters: currencyAmountFormatters(),
                            isLoadingListenable: viewModel.rateLoadingFor(
                              CurrencyField.revisedBankLimitProposedByFi,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (showFiProp)
                          ConvertedAmountField(
                            currencies: viewModel.currencyCodes,
                            controller: ctrl,
                            inputFormatters: currencyAmountFormatters(),
                            isLoadingListenable: viewModel.rateLoadingFor(
                              CurrencyField
                                  .excessOverMaxLimitAllowanceProposedByFi,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        const SizedBox.shrink(),
                      ],
                    );
                  },
                ),
              showFiGap(showFiGap: viewModel.isFIFlow),
              if (viewModel.isFIFlow)
                LabelWidget(
                  labelStyle: customLableStyle(),
                  label: "Maximum Limit allowance Lowest",
                ),
              showFiGap(showFiGap: viewModel.isFIFlow),
              if (viewModel.isFIFlow)
                FormRow(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FiCbdEquity(viewModel: viewModel),
                    FiCounterParty(viewModel: viewModel),
                    FiCounterPartyAssets(viewModel: viewModel),
                  ],
                ),
              if (viewModel.isFIFlow)
                FormRow(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewModel.showNewCbdEquityTier325PercentAmount)
                      ConvertedAmountField(
                        currencies: viewModel.currencyCodes,
                        controller: viewModel.newCbdEquityTier325PercentController,
                        inputFormatters: currencyAmountFormatters(),
                        isLoadingListenable: viewModel.rateLoadingFor(
                          CurrencyField.cbdEquityTier325Percent,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (viewModel.showNewCounterpartyEquity5PercentAmount)
                      ConvertedAmountField(
                        currencies: viewModel.currencyCodes,
                        controller: viewModel.newCounterpartyEquity5PercentController,
                        inputFormatters: currencyAmountFormatters(),
                        isLoadingListenable: viewModel.rateLoadingFor(
                          CurrencyField.counterpartyEquity5Percent,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (viewModel.showNewCounterpartyTotalAssets2PercentAmount)
                      ConvertedAmountField(
                        currencies: viewModel.currencyCodes,
                        controller: viewModel.newCounterpartyTotalAssets2PercentController,
                        inputFormatters: currencyAmountFormatters(),
                        isLoadingListenable: viewModel.rateLoadingFor(
                          CurrencyField.counterpartyTotalAssets2Percent,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),

              showFiGap(showFiGap: viewModel.isFIFlow),
              if (viewModel.isFIFlow)
                LabelWidget(
                  labelStyle: customLableStyle(),
                  label: "facilities.createFacility.recommendedByCredit".tr(),
                ),
              showFiGap(showFiGap: viewModel.isFIFlow),
              if (viewModel.isFIFlow)
                FormRow(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FiRevisedBankByCC(viewModel: viewModel),
                    FiExcessMaxLimitCC(viewModel: viewModel),
                    FiTenor(viewModel: viewModel),
                  ],
                ),
              if (viewModel.isFIFlow) _buildCcRecommendedRow(viewModel),
              const Gap(),
              FormRow(
                children: [
                  LimitNumber(viewModel: viewModel),
                  ControllingLimitNumber(viewModel: viewModel),
                  LimitAvailabilityDate(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SharedLimit(viewModel: viewModel),
                  BorrowerRim(viewModel: viewModel),
                  Visibility(
                    visible: viewModel.getFacility.sharedLimit?.id ==
                            ServerConstants.optionYESid &&
                        Utils.isGroupApplication() &&
                        viewModel.borrowersByRimInTable.isNotEmpty,
                    child: LimitAllocationTable(viewModel: viewModel),
                  ),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  ProjectFinanceRelatedActivity(viewModel: viewModel),
                  if (viewModel.limitGroup == 11317 ||
                      viewModel.limitGroup == 11315)
                    FacilityProjectNameWithAction(viewModel: viewModel)
                  else
                    FacilityProjectName(viewModel: viewModel),
                  FacilityPurpose(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  FacilityPropertyType(viewModel: viewModel),
                  FacilityPropertySubType(viewModel: viewModel),
                  FacilityEmirates(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  RegulatorySpecialisedLanding(viewModel: viewModel),
                  RegulatoryLandingSpecification(viewModel: viewModel),
                  FacilityCountryOfRisk(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  CrossBoarderCorporateExposure(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  FacilityCommitted(viewModel: viewModel),
                  FacilitySeniority(viewModel: viewModel),
                  FacilityAccountType(viewModel: viewModel),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  FacilitySector(viewModel: viewModel),
                  FacilitySicCode(viewModel: viewModel),
                  const SizedBox.shrink(),
                ],
              ),
              const Gap(),
              FormRow(
                children: [
                  PromissoryNote(viewModel: viewModel),
                  CollateralDepandant(viewModel: viewModel),
                  const SizedBox.shrink(),
                ],
              ),
              const Gap(),
              LabelWidget(
                label: "Fees and Default Rate",
                labelStyle: customLableStyle(),
                isRequired: viewModel.isFeeRowMandatory,
              ),
              FeeDefaultRateTable(
                viewModel: viewModel,
              ),
              if (viewModel.facilitySubTypes.isNotEmpty) const Gap(),
              //if reference 5 is not null for (Facility_type)  and limit
              //description mathces refernce 5 show
              //in subtype inside table find all the refernce5 value whicha are
              //having "LCD" value only value
              //heading =--sub-limit
              if (viewModel.facilitySubTypes.isNotEmpty)
                LabelWidget(
                  label: "Sub Limit",
                  labelStyle: customLableStyle(),
                ),
              if (viewModel.facilitySubTypes.isNotEmpty)
                FacilitySubTypeTable(
                  viewModel: viewModel,
                ),
              const Gap(),

              if (!viewModel.isFIFlow && viewModel.sections.isNotEmpty)
                DynamicForm(
                  sections: viewModel.sections,
                  document: viewModel.dynamicFormDocument,
                  key: viewModel.dynamicFormKey,
                  onFieldChange: viewModel.onDynamicFormFieldChange,
                  // When canEdit is false and the user is NOT a CMO role,
                  // lock the entire dynamic form as read-only.
                  readOnly: !viewModel.canEdit && !viewModel.isCmoUpdate(),
                  // When canEdit is false but the user IS a CMO role,
                  // only CMO-flagged fields (isCMOUpdate) remain editable.
                  disableAllExceptCMOUpdate:
                      !viewModel.canEdit && viewModel.isCmoUpdate(),
                ),
              const Gap(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: FacilityRemarks(viewModel: viewModel),
                  ),
                  const Gap(
                    size: GapSize.large,
                    direction: Axis.horizontal,
                  ),
                  Expanded(
                    child: viewModel.isFIFlow
                        ? const SizedBox()
                        : PolicyDeviations(viewModel: viewModel),
                  ),
                ],
              ),
              const Gap(),
              LabelWidget(
                label: "Conditions",
                labelStyle: customLableStyle(),
              ),
              const Gap(),

              if (viewModel.getFacility.limitGroup ==
                      ServerConstants.projectSpecificLimitsID ||
                  viewModel.getFacility.limitGroup ==
                      ServerConstants.projectStandByLimitID)
                ContractingStandardConditionsTable(
                  viewModel: viewModel,
                )
              else
                ConditionsTable(
                  viewModel: viewModel,
                ),
              const Gap(),
              NonStdConditionTable(
                viewModel: viewModel,
              ),
              const Gap(),

              if (viewModel.canEdit ||
                  viewModel.isCmoUpdate() ||
                  viewModel.isEditableForProposedByCC())
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Gap(direction: Axis.horizontal),
                    CustomButton(
                      ignoreProvider: true,
                      label: "common.save".tr(),
                      isLoading: viewModel.state.isSaveLoading,
                      onPressed: viewModel.isApiError
                          ? null
                          : () {
                              viewModel.saveContinueOnPressed(
                                navigateToHomePage: false,
                              );
                            },
                    ),
                    const Gap(
                      direction: Axis.horizontal,
                    ),
                    CustomButton(
                      ignoreProvider: true,
                      label: "common.saveAndContinue".tr(),
                      isLoading: viewModel.state.isSaveAndContinueLoading,
                      onPressed: viewModel.isApiError
                          ? null
                          : () {
                              viewModel.saveContinueOnPressed(
                                navigateToHomePage: true,
                              );
                            },
                    ),
                    const Gap(
                      direction: Axis.horizontal,
                    ),
                    CustomButton(
                      ignoreProvider: true,
                      label: "common.cancel".tr(),
                      onPressed: () {
                        viewModel.cancelOnPressed();
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      }
    }
  }

  /// Builds the CC-recommended FormRow with long property names.
  /// Extracted to avoid exceeding the 80-char line limit inside the
  /// builder callback, since property names are inherently long.
  Widget _buildCcRecommendedRow(
    CreateFacilityViewModel viewModel,
  ) {
    // Aliases: avoids repeating the 60-char property names inline
    final bool showRbCredit =
        viewModel.showNewRevisedBankLimitRecommendedByCreditAmount;
    final bool showExcessCc =
        viewModel.showNewExcessOverMaxLimitAllowanceRecommendedByCreditAmount;
    final ccController =
        viewModel.newExcessOverMaxLimitAllowanceRecommendedByCreditController;
    return FormRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRbCredit)
          ConvertedAmountField(
            currencies: viewModel.currencyCodes,
            controller: viewModel.newProposedByccController,
            inputFormatters: currencyAmountFormatters(),
            isLoadingListenable: viewModel.rateLoadingFor(
              CurrencyField.revisedBankLimitRecommendedByCredit,
            ),
          )
        else
          const SizedBox.shrink(),
        if (showExcessCc)
          ConvertedAmountField(
            currencies: viewModel.currencyCodes,
            controller: ccController,
            inputFormatters: currencyAmountFormatters(),
            isLoadingListenable: viewModel.rateLoadingFor(
              CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit,
            ),
          )
        else
          const SizedBox.shrink(),
        const SizedBox.shrink(),
      ],
    );
  }

  /// Returns a gap widget when [showFiGap] is true.
  ///
  /// Otherwise, returns an empty widget.
  Widget showFiGap({required bool showFiGap}) {
    return showFiGap ? const Gap(size: GapSize.large) : const SizedBox.shrink();
  }

  /// Returns the default label text style used by the view.
  TextStyle customLableStyle() => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      );
}
