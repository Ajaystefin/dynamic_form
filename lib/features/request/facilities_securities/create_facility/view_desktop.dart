import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/account_type.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/advance_type.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/borrower_rim.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/collatarel_dependant.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/commitment_account_number.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/committed.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/controlling_limit_number.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/country_risk.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/cross_boarder_exposure.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/emirates.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/facility_title.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_cbd_equity.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_counter_party.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_counterparty_assets.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_max_limit.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_revised_bank.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/fi_tenor.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/project_name.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/proposed_facility_amount_new.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sustanability_classification.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/add_fee_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/create_project_field.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/non_std_condition_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/std_conditions_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/limit_allocation.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_availability_date.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_description.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_number.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_type.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/original_limit.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/past_dues.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/policy_deviations.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/present_limit.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/present_outstanding.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/project_finance_related_activity.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/promissory_note.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/property_subtype.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/property_type.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/proposed_by_cc.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/proposed_limit.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/purpose.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/regulatory_landing_specify.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/regulatory_specialised_landing.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/remarks.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sector.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/seniority.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/shared_limit.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/fields/sic_code.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/sub_types_table.dart';
import 'model.dart';
import 'state.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    CreateFacilityViewModel viewModel = context.read<CreateFacilityViewModel>();
    return BlocBuilder<CreateFacilityViewModel, CreateFacilityState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, CreateFacilityState state,
      CreateFacilityViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('Empty State'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('Error State'.tr()),
        );
      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(BuildContext context, CreateFacilityState state,
      CreateFacilityViewModel viewModel) {
    return SingleChildScrollView(
      child: Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              CustomSectionHeader(
                  title: "facilities.createFacility.title".tr()),
              Column(children: [
                BoxLayout(
                  child: TopSectionDetails(
                    request: viewModel.request,
                  ),
                ),
                _buildFacilityDescriptionSection(state, viewModel),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityDescriptionSection(
      CreateFacilityState state, CreateFacilityViewModel viewModel) {
    if (state.navigateToCreateFacility == LoadingStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppStyle.spacingLarge,
          horizontal: AppStyle.spacingLarge,
        ),
        child: CircularProgressIndicator(),
      );
    } else {
      // if (viewModel.showCreateFacilityForm) {

      return BoxLayout(
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
                                viewModel: viewModel), //main limit sub limit
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
            FormRow(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AdvanceType(viewModel: viewModel),
              CommitmentAccountNumber(viewModel: viewModel),
              SustanabilityClassification(viewModel: viewModel),
            ]),
            const Gap(),
            FormRow(children: [
              PresentOutstanding(viewModel: viewModel),
              FacilityPastDues(viewModel: viewModel),
              OriginalLimit(viewModel: viewModel),
            ]),
            const Gap(),
            FormRow(children: [
              PresentLimit(viewModel: viewModel),
              ProposedLimit(viewModel: viewModel),
              FacilityProposedByCC(viewModel: viewModel),
            ]),
            FormRow(
              children: [
                const SizedBox(),
                if (viewModel.showProposedSecurityAmount)
                  ProposedFacilityAmountNew(viewModel: viewModel),
                const SizedBox(),
              ],
            ),
            showFiGap(viewModel.showFacilityFi),
            if (viewModel.showFacilityFi)
              LabelWidget(label: "facilities.createFacility.proposedByFI".tr()),
            showFiGap(viewModel.showFacilityFi),
            if (viewModel.showFacilityFi)
              FormRow(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FiRevisedBank(viewModel: viewModel),
                FiExcessMaxLimit(viewModel: viewModel),
                const SizedBox.shrink()
              ]),
            showFiGap(viewModel.showFacilityFi),
            if (viewModel.showFacilityFi)
              LabelWidget(
                  label: "facilities.createFacility.maxLimitLowest".tr()),
            showFiGap(viewModel.showFacilityFi),
            if (viewModel.showFacilityFi)
              FormRow(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FiCbdEquity(viewModel: viewModel),
                FiCounterParty(viewModel: viewModel),
                FiCounterPartyAssets(viewModel: viewModel),
              ]),
            showFiGap(viewModel.showFacilityFi),
            if (viewModel.showFacilityFi)
              LabelWidget(
                  label: "facilities.createFacility.recommendedByCredit".tr()),
            showFiGap(viewModel.showFacilityFi),
            if (viewModel.showFacilityFi)
              FormRow(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FiRevisedBank(viewModel: viewModel),
                FiExcessMaxLimit(viewModel: viewModel),
                const SizedBox.shrink()
              ]),
            const Gap(),
            FormRow(children: [
              LimitNumber(viewModel: viewModel),
              ControllingLimitNumber(viewModel: viewModel),
              LimitAvailabilityDate(viewModel: viewModel),
            ]),
            const Gap(),
            FormRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SharedLimit(viewModel: viewModel),
                BorrowerRim(viewModel: viewModel),
                Visibility(
                    visible: (viewModel.facility.sharedLimit?.id ==
                            ServerConstants.optionYESid &&
                        Utils.isGroupApplication() &&
                        viewModel.borrowersByRimInTable.isNotEmpty),
                    child: LimitAllocationTable(viewModel: viewModel)),
              ],
            ),
            const Gap(),
            FormRow(children: [
              ProjectFinanceRelatedActivity(viewModel: viewModel),
              (viewModel.limitGroup == 11317)
                  ? FacilityProjectNameWithAction(viewModel: viewModel)
                  : FacilityProjectName(viewModel: viewModel),
              FacilityPurpose(viewModel: viewModel),
            ]),
            const Gap(),
            FormRow(children: [
              FacilityPropertyType(viewModel: viewModel),
              FacilityPropertySubType(viewModel: viewModel),
              FacilityEmirates(viewModel: viewModel),
            ]),
            const Gap(),
            FormRow(children: [
              RegulatorySpecialisedLanding(viewModel: viewModel),
              RegulatoryLandingSpecification(viewModel: viewModel),
              FacilityCountryOfRisk(viewModel: viewModel),
            ]),
            const Gap(),
            FormRow(children: [
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              CrossBoarderCorporateExposure(viewModel: viewModel)
            ]),
            const Gap(),
            FormRow(
              children: [
                FacilityCommitted(viewModel: viewModel),
                FacilitySeniority(viewModel: viewModel),
                FacilityAccountType(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(children: [
              FacilitySector(viewModel: viewModel),
              FacilitySicCode(viewModel: viewModel),
              const SizedBox.shrink(),
            ]),
            const Gap(),
            FormRow(children: [
              PromissoryNote(viewModel: viewModel),
              CollateralDepandant(viewModel: viewModel),
              const SizedBox.shrink(),
            ]),
            const Gap(),
            LabelWidget(
              label: 'Fees and Default Rate',
              isRequired: viewModel.isFeeRowMandatory ? true : false,
            ),
            FeeDefaultRateTable(
              viewModel: viewModel,
              feeDefualtRateTableRows: viewModel.feeDefualtRate,
            ),
            const Gap(),
            //if reference 5 is not null for (Facility_type)  and limit description mathces refernce 5 show
            //in suubtype inside table find all the refernce5 value whicha are having "LCD" value only value
            //heading =--sub-limit
            const LabelWidget(
              label: 'Sub Limit',
            ),
            FacilitySubTypeTable(
              viewModel: viewModel,
              facilitySubtypes: viewModel.facilitySubTypes,
            ),
            const Gap(),
            DynamicForm(
              sections: viewModel.sections,
              document: viewModel.dynamicFormDocument,
              key: viewModel.dynamicFormKey,
            ),
            const Gap(),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  flex: 1,
                  child: viewModel.showFacilityFi
                      ? FiTenor(viewModel: viewModel)
                      : PolicyDeviations(viewModel: viewModel)),
              const Gap(
                size: GapSize.large,
                direction: Axis.horizontal,
              ),
              Expanded(
                flex: 2,
                child: FacilityRemarks(viewModel: viewModel),
              ),
            ]),
            const Gap(),
            const LabelWidget(
              label: 'Conditions',
            ),
            const Gap(),
            ConditionsTable(
              viewModel: viewModel,
              conditions: viewModel.conditions,
            ),
            const Gap(),
            NonStdConditionTable(
              viewModel: viewModel,
              conditions: viewModel.nonStandardCondition,
            ),
            const Gap(),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              // CustomButton(
              //   label: 'common.save'.tr(),
              //   onPressed: () async {
              //     viewModel.saveContinueOnPressed(false);
              //   },
              // ),
              const Gap(
                direction: Axis.horizontal,
              ),
              CustomButton(
                  label: 'common.save'.tr(),
                  isLoading: viewModel.state.isButtonLoading,
                  onPressed: viewModel.isApiError
                      ? null
                      : () {
                          viewModel.saveContinueOnPressed(true);
                        }),
              const Gap(
                direction: Axis.horizontal,
              ),
              // CustomButton(
              //   label: 'common.cancel'.tr(),
              //   onPressed: () {
              //     viewModel.cancelOnPressed();
              //   },
              // ),
            ]),
          ],
        ),
      );
    }
  }

  Widget showFiGap(bool showFiGap) {
    return showFiGap ? const Gap() : const SizedBox.shrink();
  }
}
