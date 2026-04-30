import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
// import 'package:wcas_frontend/core/utils/validators.dart';
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/state.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/widgets/raroc_information.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/widgets/relationship_profitability_group.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/widgets/rim_list_acordian.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final RelationshipProfitabilitySummaryViewModel viewModel =
        context.read<RelationshipProfitabilitySummaryViewModel>();
    return BlocBuilder<RelationshipProfitabilitySummaryViewModel,
        RelationshipProfitabilitySummaryState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "profitabilityAccountConduct."
                            "relationshipProfitabilitySummary.sectionTitle"
                        .tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TabMenu(
                          activeKey: RevenueCrossSellTabs
                              .relationshipProfitabilitySummary,
                          routes: TabConstants.revenueCrossSellRoutes,
                          labels: TabConstants.revenueCrossSellTitles,
                        ),
                        BoxLayout(
                          disabled: !viewModel.canEdit,
                          child: _body(
                            context,
                            state,
                            viewModel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    RelationshipProfitabilitySummaryState state,
    RelationshipProfitabilitySummaryViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("common.emptyState".tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.errorState".tr()),
        );
      default:
        return buildView(state, viewModel, context);
    }
  }

  Widget buildView(
    RelationshipProfitabilitySummaryState state,
    RelationshipProfitabilitySummaryViewModel viewModel,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rarocInfoSection(viewModel),
            const Gap(size: GapSize.medium),
            relationshipProfitabilitySection(viewModel),
            const Gap(size: GapSize.medium),
            relationshipProfitabilityGroupSection(viewModel),
            const Gap(size: GapSize.large),
            LabelWidget(
              label: "profitabilityAccountConduct."
                      "relationshipProfitabilitySummary.rmComments"
                  .tr(),
              labelStyle: AppStyle.tableHeaderStyle,
              child: CustomTextArea(
                semanticLabel: "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.rmComments"
                    .tr(),
                width: double.infinity,
                autoFocus: false,
                maxLength: 2000,
                // !viewModel.isFIApplication ? CustomValidator.requiredField :
                validator: null,
                initialValue: viewModel.summaryComments,
                onSaved: (String? value) {
                  viewModel.summaryComments = value;
                },
              ),
            ),
            const Gap(size: GapSize.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: "common.save".tr(),
                  semanticLabel: "common.save".tr(),
                  onPressed: (viewModel.canEdit)
                      ? () async {
                          await viewModel.onSaveAndContinue(
                            false,
                            context: context,
                          );
                        }
                      : null,
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  label: "common.saveAndContinue".tr(),
                  semanticLabel: "common.saveAndContinue".tr(),
                  onPressed: (viewModel.canEdit)
                      ? () async {
                          await viewModel.onSaveAndContinue(
                            true,
                            context: context,
                          );
                        }
                      : null,
                ),
              ],
            ),
            const Gap(size: GapSize.medium),
          ],
        ),
      ),
    );
  }

  Widget rarocInfoSection(viewModel) {
    return CustomAccordion(
      initiallyExpanded: true,
      title: "profitabilityAccountConduct."
              "relationshipProfitabilitySummary.rarocInformation"
          .tr(),
      children: [
        RoracInformation(
          viewModel: viewModel,
        ),
      ],
    );
  }

  Widget relationshipProfitabilitySection(viewModel) {
    return CustomAccordion(
      title: "profitabilityAccountConduct."
              "relationshipProfitabilitySummary.relationshipProfitability"
          .tr(),
      children: [
        RimListAccordion(viewModel: viewModel),
      ],
    );
  }

  Widget relationshipProfitabilityGroupSection(viewModel) {
    final groupName = Globals.request?.groupName ?? "AGA (125)";
    //viewModel.currentGroupName() ?? Globals.request?.groupName;
    if (Utils.isGroupApplication()) {
      return CustomAccordion(
        title: "profitabilityAccountConduct.relationshipProfitabilitySummary."
                "relationshipProfitabilityGroup"
            .tr(namedArgs: {"groupName": groupName}),
        //"Relationship Profitability Group Name- $groupName".tr(),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RelationshipProfitabilityGroup(viewModel: viewModel),
            ],
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
