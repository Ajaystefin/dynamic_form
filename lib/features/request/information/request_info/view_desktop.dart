import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/application_type.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/business_segment.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/ca_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/cancellation_reason.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/customer_request_received.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/date_all_document_received.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/deviation_breach_justification.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/erm_approval.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/esg.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/exposure_strategy.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/interim_review_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/interim_review_date_required.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/main_branch.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/main_sector_industry.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/mark_forward_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/next_review_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/other_co_borrowers.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/override_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/policy_deviations.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/present_review_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/pricing_committee.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/product_type.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/purpose_of_applicaion_detailed.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/purpose_of_applicaion_summary.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/reason_for_deferral.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/reconsideration.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/region.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/restructured_rescheduled.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/sharia_approval.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/tpan.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/tpan_received_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/tpan_request_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/ultimate_ownership.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";
import "package:wcas_frontend/models/request/request.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestInfoViewModel viewModel = context.read<RequestInfoViewModel>();

    return BlocBuilder<RequestInfoViewModel, RequestInfoState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    RequestInfoState state,
    RequestInfoViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("requestInformation.requestInformation.error".tr()),
        );
      default:
        return SingleChildScrollView(
          controller: viewModel.scrollController,
          child: _buildBodySection(
            context,
            state,
            viewModel,
          ),
        );
    }
  }

  Widget _buildBodySection(
    BuildContext context,
    RequestInfoState state,
    RequestInfoViewModel viewModel,
  ) {
    return Focus(
      focusNode: viewModel.formFocusNode,
      child: Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "requestInformation.requestInformation."
                        "requestInformationTitle"
                    .tr(),
              ),
              const Gap(),
              Column(
                children: [
                  // Top Customer Namw Request Type.
                  BoxLayout(
                    child: TopSectionDetails(
                      request: Globals.request ?? Request(),
                    ),
                  ),

                  // Type.
                  BoxLayout(
                    disabled: !viewModel.canEdit &&
                        !Utils.checkRoles([
                          UserRole.creditAnalyst, //"CA"
                        ]),
                    // disabled: !viewModel.canEdit,
                    extraPadding: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(),
                        // First Row: CA Date, Product Type, Empty Column

                        FormRow(
                          children: [
                            CaDate(viewModel: viewModel),
                            ProductType(viewModel: viewModel),
                            // Only displayed when product type = Islamic
                            state.isIslamic
                                ? ShariaApproval(viewModel: viewModel)
                                : Container(),
                          ],
                        ),
                        const Gap(),
                        // Second Row: Business Segment, Region, Branch (3
                        // Columns)
                        FormRow(
                          children: [
                            BusinessSegmentField(viewModel: viewModel),
                            Region(viewModel: viewModel),
                            MainBranch(viewModel: viewModel),
                          ],
                        ),
                        const Gap(),
                        // Third Row: Application Type (Single Widget, Empty
                        // Columns)
                        FormRow(
                          children: [
                            ApplicationTypeDropdown(
                              viewModel: viewModel,
                            ),
                            Utils.checkApplicationType(
                              ApplicationType.cancellation,
                            )
                                ? CancellationReason(viewModel: viewModel)
                                : Utils.checkApplicationType(
                                    ApplicationType.reconsideration,
                                  )
                                    ? ReconsiderationField(viewModel: viewModel)
                                    : const SizedBox(),
                            const SizedBox(),
                          ],
                        ),
                        const Gap(),

                        if (!Utils.checkApplicationType(
                          ApplicationType.cancellation,
                        )) ...[
                          // Widgets to show when 'Reconsideration' is selected
                          // These widgets will show ONLY when Reconsideration'
                          // is selected

                          //   // Fourth Row: Present Review Date, Next Review Date, Empty Column
                          FormRow(
                            children: [
                              PresentReviewDate(
                                viewModel: viewModel,
                                state: state,
                              ),
                              NextReviewDate(
                                viewModel: viewModel,
                                state: state,
                              ),
                              OverrideDate(
                                viewModel: viewModel,
                                state: state,
                              ),
                            ],
                          ),
                          const Gap(),
                          //   // Fifth Row: Customer Request Received, Date All Document Received, Empty Column
                          FormRow(
                            children: [
                              CustomerRequestReceived(viewModel: viewModel),
                              DateAllDocumentReceived(viewModel: viewModel),
                              (state.isApplicationTypeMarkForward)
                                  ? MarkForwardDate(
                                      viewModel: viewModel,
                                      state: state,
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          const Gap(),
                          //   // Sixth Row: TPAN, Empty Column, Empty Column
                          FormRow(
                            children: [
                              Tpan(viewModel: viewModel),
                              //TPAN is Yes show date

                              state.isTPAN
                                  ? TPANRequestDate(viewModel: viewModel)
                                  : const SizedBox(),

                              state.isTPAN
                                  ? TPANReceivedDate(viewModel: viewModel)
                                  : const SizedBox(),
                            ],
                          ),
                          const Gap(),
                          if (viewModel.selectedRequestType?.id ==
                              ServerConstants.requestTypeId[RequestType.fullCA])
                            Column(
                              children: [
                                FormRow(
                                  children: [
                                    ERMApproval(viewModel: viewModel),
                                    ESG(viewModel: viewModel),
                                    PricingCommittee(viewModel: viewModel),
                                  ],
                                ),
                                const Gap(),
                              ],
                            ),

                          FormRow(
                            children: [
                              if (viewModel.selectedRequestType?.id ==
                                  ServerConstants
                                      .requestTypeId[RequestType.fullCA])
                                RestructuredRescheduled(
                                  viewModel: viewModel,
                                ),

                              InterimReviewDateRequired(viewModel: viewModel),
                              //InterimReviewDateRequired is Yes show
                              //InterimReviewDate

                              state.isInterimReviewDateRequired
                                  ? InterimReviewDate(viewModel: viewModel)
                                  : const SizedBox(),

                              if (viewModel.selectedRequestType?.id !=
                                  ServerConstants
                                      .requestTypeId[RequestType.fullCA])
                                const SizedBox(),
                            ],
                          ),
                          const Gap(),
                          FormRow(
                            children: [
                              if (viewModel.selectedRequestType?.id ==
                                  ServerConstants
                                      .requestTypeId[RequestType.fullCA])
                                ExposureStrategy(viewModel: viewModel),
                              MainSectorIndustry(viewModel: viewModel),
                              (Utils.checkApplicationType(
                                ApplicationType.markForward,
                              )
                                  // viewModel.selectedApplicationType?.id ==
                                  //       ServerConstants.applicationTypeId[
                                  //         ApplicationType.markForward]
                                  )
                                  ? ReasonForDeferral(viewModel: viewModel)
                                  : const SizedBox(),
                              if (viewModel.selectedRequestType?.id !=
                                  ServerConstants
                                      .requestTypeId[RequestType.fullCA])
                                const SizedBox(),
                            ],
                          ),
                          const Gap(),
                          //   // Seventh Row: OtherCoBorrowers
                          OtherCoBorrowers(
                            viewModel: viewModel,
                            state: state,
                            width: 350.w,
                            row: viewModel.coBorrowerList ?? [],
                          ),

                          if (viewModel.canEdit && viewModel.otherRolesCheck())
                            AddItemButton(
                              onTap: () => viewModel.addCoBorrowerRow(),
                              isLeftSided: true,
                              child: Text(
                                "requestInformation.requestInformation."
                                        "addOtherCoBorrowers"
                                    .tr(),
                                style: const TextStyle(
                                  fontSize: AppStyle.fontSizeSmall,
                                ),
                              ),
                            ),
                          const Gap(),
                          UltimateOwnership(viewModel: viewModel),
                          const Gap(),
                          PurposeOfApplicaionSummary(
                            viewModel: viewModel,
                          ),
                          const Gap(),
                          // // Ninth Row: Purpose of Applicaion Detailed * info (for * isRequired: true)
                          PurposeOfApplicaionDetailed(viewModel: viewModel),
                          const Gap(),
                          (viewModel.isFI)
                              ? Container()
                              : FormRow(
                                  children: [
                                    PolicyDeviations(
                                      viewModel: viewModel,
                                    ),
                                    (state.isPolicyDeviation == true)
                                        ? DeviationBreachJustification(
                                            viewModel: viewModel,
                                          )
                                        : Container(),
                                  ],
                                ),
                        ],

                        const Gap(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (viewModel.isNewRequest)
                              CustomButton(
                                label: "requestInformation."
                                        "applicationBorrowers.back"
                                    .tr(),
                                onPressed: () {
                                  if (context.mounted) {
                                    router.go(Routes.applicationBorrowers);
                                  }
                                },
                              ),
                            if (viewModel.isNewRequest)
                              const Gap(
                                size: GapSize.medium,
                                direction: Axis.horizontal,
                              ),
                            if (viewModel.canEdit
                                ? viewModel.otherRolesCheck()
                                //continue action button  :
                                : Utils.checkRoles([
                                    UserRole.creditAnalyst, //"CA"
                                  ]))
                              CustomButton(
                                label: "requestInformation."
                                        "requestInformation.saveContinue"
                                    .tr(),
                                isLoading: viewModel.state.isButtonLoading,
                                onPressed: viewModel.isApiError
                                    ? null
                                    : () {
                                        viewModel
                                            .saveContinueButtonPress(context);
                                      },
                              ),
                          ],
                        ),

                        // const Gap(),
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
