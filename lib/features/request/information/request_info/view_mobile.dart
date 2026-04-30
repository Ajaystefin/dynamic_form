import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
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
import "package:wcas_frontend/features/request/information/request_info/fields/reconsideration.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/region.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/restructured_rescheduled.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/tpan.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/tpan_received_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/tpan_request_date.dart";
import "package:wcas_frontend/features/request/information/request_info/fields/ultimate_ownership.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";
import "package:wcas_frontend/models/request/request.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

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

                  BoxLayout(
                    extraPadding: true,
                    disabled: !viewModel.canEdit &&
                        !Utils.checkRoles([
                          UserRole.creditAnalyst, //"CA"
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CaDate(viewModel: viewModel),
                        const Gap(),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ProductType(viewModel: viewModel),
                        ),
                        const Gap(),
                        BusinessSegmentField(viewModel: viewModel),
                        const Gap(),
                        Region(viewModel: viewModel),
                        const Gap(),
                        MainBranch(viewModel: viewModel),
                        const Gap(),
                        Column(
                          children: [
                            ApplicationTypeDropdown(viewModel: viewModel),
                            const Gap(),
                            Utils.checkApplicationType(
                              ApplicationType.cancellation,
                            )
                                ? CancellationReason(viewModel: viewModel)
                                : Utils.checkApplicationType(
                                    ApplicationType.reconsideration,
                                  )
                                    ? ReconsiderationField(viewModel: viewModel)
                                    : const SizedBox(height: 2),
                          ],
                        ),
                        const Gap(),
                        // if (viewModel.selectedApplicationType?.id ==
                        //     ServerConstants.applicationTypeCancelId) ...[
                        //   const Gap(),
                        // ] else
                        if (!Utils.checkApplicationType(
                          ApplicationType.cancellation,
                        )
                            //viewModel.selectedApplicationType == null
                            //||viewModel.selectedApplicationType?.id !=
                            //ServerConstants.applicationTypeCancelId
                            ) ...[
                          (state.isApplicationTypeMarkForward)
                              ? MarkForwardDate(
                                  viewModel: viewModel,
                                  state: state,
                                )
                              : Container(),
                          const Gap(),
                          PresentReviewDate(
                            viewModel: viewModel,
                            state: state,
                          ),
                          const Gap(),
                          NextReviewDate(viewModel: viewModel, state: state),
                          const Gap(),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: OverrideDate(
                              viewModel: viewModel,
                              state: state,
                            ),
                          ),
                          const Gap(),
                          CustomerRequestReceived(viewModel: viewModel),
                          const Gap(),
                          DateAllDocumentReceived(viewModel: viewModel),
                          const Gap(),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Tpan(viewModel: viewModel),
                          ),
                          const Gap(),
                          state.isTPAN
                              ? TPANRequestDate(viewModel: viewModel)
                              : Container(),
                          const Gap(),
                          state.isTPAN
                              ? TPANReceivedDate(viewModel: viewModel)
                              : Container(),
                          const Gap(),
                          if (viewModel.selectedRequestType?.id ==
                                  ServerConstants
                                      .requestTypeId[RequestType.fullCA]
                              //viewModel.selectedRequestType?.name =="Full CA"
                              ) ...[
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ERMApproval(viewModel: viewModel),
                            ),
                            const Gap(),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ESG(viewModel: viewModel),
                            ),
                            const Gap(),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: PricingCommittee(viewModel: viewModel),
                            ),
                            const Gap(),
                            RestructuredRescheduled(
                              viewModel: viewModel,
                            ),
                            const Gap(),
                          ],
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child:
                                InterimReviewDateRequired(viewModel: viewModel),
                          ),
                          const Gap(),
                          state.isInterimReviewDateRequired
                              ? InterimReviewDate(viewModel: viewModel)
                              : Container(),
                          const Gap(),
                          if (viewModel.selectedRequestType?.id ==
                                  ServerConstants
                                      .requestTypeId[RequestType.fullCA]
                              //viewModel.selectedRequestType?.name =="Full CA"
                              )
                            ExposureStrategy(viewModel: viewModel),
                          const Gap(),
                          MainSectorIndustry(viewModel: viewModel),
                          const Gap(),
                          if (viewModel.canEdit && viewModel.otherRolesCheck())
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: OtherCoBorrowers(
                                viewModel: viewModel,
                                state: state,
                                row: viewModel.coBorrowerList ?? [],
                              ),
                            ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: AddItemButton(
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
                          ),
                          const Gap(),
                          UltimateOwnership(viewModel: viewModel),
                          const Gap(),
                          PurposeOfApplicaionSummary(viewModel: viewModel),
                          const Gap(),
                          PurposeOfApplicaionDetailed(viewModel: viewModel),
                          const Gap(),
                          (viewModel.isFI)
                              ? Container()
                              : PolicyDeviations(
                                  viewModel: viewModel,
                                ),
                          const Gap(),
                          (viewModel.isFI)
                              ? Container()
                              : (state.isPolicyDeviation == true)
                                  ? DeviationBreachJustification(
                                      viewModel: viewModel,
                                    )
                                  : Container(),
                        ],
                        const Gap(
                          direction: Axis.horizontal,
                        ),

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
                                    context.push(Routes.applicationBorrowers);
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
