import "package:easy_localization/easy_localization.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
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
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_availability_date.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_description.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_group.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_number.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/limit_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/original_limit.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/past_dues.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/policy_deviations.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/present_limit.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/present_outstanding.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/fields/product_type.dart";
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
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/custom_accordion_title.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/limit_allocation.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/non_std_condition_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/widgets/std_conditions_table.dart";

/// Mobile view for the create facility screen.
class ViewMobile extends StatelessWidget {
  /// Creates a mobile view for the create facility screen.
  const ViewMobile({super.key});

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
        return _buildView(state, viewModel);
    }
  }

  Widget _buildView(
    CreateFacilityState state,
    CreateFacilityViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "facilities.createFacility.title".tr(),
              ),
              const Gap(),
              Column(
                children: [
                  BoxLayout(
                    child: TopSectionDetails(
                      request: Globals.request!,
                    ),
                  ),
                  BoxLayout(
                    extraPadding: true,
                    child: _buildFacilityDescriptionSection(state, viewModel),
                  ),
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
      return const SizedBox(
        width: double.infinity,
        height: 150,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: CupertinoActivityIndicator(radius: 20),
        ),
      );
    } else {
      if (!viewModel.showCreateFacilityForm) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 5,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: CustomAccordion(
                title: "Jhone Doe -"
                    " "
                    // UI purpose only; replace with proper API data
                    "23986",
                children: List.generate(
                  viewModel.facilityTypesUnderCustomerRim.length,
                  (index) => CustomAccordionTitleWidget(
                    title: viewModel.facilityTypesUnderCustomerRim[index],
                    children: [
                      ProductType(viewModel: viewModel),
                      const Gap(),
                      LimitGroup(viewModel: viewModel),
                      const Gap(),
                      LimitDescription(viewModel: viewModel),
                      const Gap(),
                      if (viewModel.getFacility.facilityTypeSelectedValue !=
                              null &&
                          viewModel.getFacility.facilityDescription != null)
                        CustomButton(
                          label: "common.continue".tr(),
                          onPressed: () async {
                            // await viewModel.navigateToCreateFacility();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        return SectionBackground(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LimitDescription(viewModel: viewModel),
              const Gap(),
              LimitType(viewModel: viewModel),
              const Gap(),
              FacilityTitle(viewModel: viewModel),
              const Gap(),
              AdvanceType(viewModel: viewModel),
              const Gap(),
              SustanabilityClassification(viewModel: viewModel),
              const Gap(),
              CommitmentAccountNumber(viewModel: viewModel),
              const Gap(),
              PresentOutstanding(viewModel: viewModel),
              const Gap(),
              FacilityPastDues(viewModel: viewModel),
              const Gap(),
              OriginalLimit(viewModel: viewModel),
              const Gap(),
              PresentLimit(viewModel: viewModel),
              const Gap(),
              ProposedLimit(viewModel: viewModel),
              const Gap(),
              FacilityProposedByCC(viewModel: viewModel),
              const Gap(),
              LimitNumber(viewModel: viewModel),
              const Gap(),
              ControllingLimitNumber(viewModel: viewModel),
              const Gap(),
              LimitAvailabilityDate(viewModel: viewModel),
              const Gap(),
              SharedLimit(viewModel: viewModel),
              const Gap(),
              BorrowerRim(viewModel: viewModel),
              const Gap(),
              LimitAllocationTable(viewModel: viewModel),
              const Gap(),
              ProjectFinanceRelatedActivity(viewModel: viewModel),
              const Gap(),
              FacilityProjectName(viewModel: viewModel),
              const Gap(),
              FacilityPurpose(viewModel: viewModel),
              const Gap(),
              FacilityPropertyType(viewModel: viewModel),
              const Gap(),
              FacilityPropertySubType(viewModel: viewModel),
              const Gap(),
              FacilityEmirates(viewModel: viewModel),
              const Gap(),
              RegulatorySpecialisedLanding(viewModel: viewModel),
              const Gap(),
              if (viewModel.getFacility
                      .selectedRegulatorySpecialisedLandingValue?.id ==
                  ServerConstants.optionYESid)
                RegulatoryLandingSpecification(viewModel: viewModel)
              else
                const SizedBox.shrink(),
              const Gap(),
              FacilityCountryOfRisk(viewModel: viewModel),
              const Gap(),
              CrossBoarderCorporateExposure(viewModel: viewModel),
              const Gap(),
              FacilityCommitted(viewModel: viewModel),
              const Gap(),
              FacilitySeniority(viewModel: viewModel),
              const Gap(),
              FacilityAccountType(viewModel: viewModel),
              const Gap(),
              FacilitySector(viewModel: viewModel),
              const Gap(),
              FacilitySicCode(viewModel: viewModel),
              const Gap(),
              PromissoryNote(viewModel: viewModel),
              const Gap(),
              CollateralDepandant(viewModel: viewModel),
              const Gap(),
              FeeDefaultRateTable(
                viewModel: viewModel,
              ),
              const Gap(),
              // DynamicForm(     //   sections: viewModel.sections,
              //   document: viewModel.dynamicFormDocument,
              //   formKey: viewModel.dynamicFormKey,
              // ),
              // const Gap(),

              PolicyDeviations(viewModel: viewModel),
              const Gap(),
              FacilityRemarks(viewModel: viewModel),
              const Gap(),
              const LabelWidget(label: "Conditions"),
              ConditionsTable(
                viewModel: viewModel,
              ),
              const Gap(),
              NonStdConditionTable(
                viewModel: viewModel,
              ),
              const Gap(),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  CustomButton(
                    label: "common.save".tr(),
                    onPressed: () async {
                      await viewModel.saveContinueOnPressed(
                        navigateToHomePage: false,
                      );
                    },
                  ),
                  CustomButton(
                    label: "common.saveAndContinue".tr(),
                    onPressed: () async {
                      await viewModel.saveContinueOnPressed(
                        navigateToHomePage: true,
                      );
                    },
                  ),
                  CustomButton(
                    label: "common.cancel".tr(),
                    onPressed: () async {
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
}
