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

/// Desktop view for the Relationship Profitability Summary screen.
class ViewDesktop extends StatelessWidget {
  /// Creates a desktop view for the Relationship Profitability Summary screen.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final RelationshipProfitabilitySummaryViewModel viewModel =
        context.read<RelationshipProfitabilitySummaryViewModel>();
    final bool canShowButton = viewModel.canEdit ||
        (viewModel.otherRolesCheck() && viewModel.canEditFinalRAROC);
    return BlocBuilder<RelationshipProfitabilitySummaryViewModel,
        RelationshipProfitabilitySummaryState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
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
                          disabled: !canShowButton,
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

  /// Builds the relationship profitability summary view content.
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
            const Gap(),
            relationshipProfitabilitySection(viewModel),
            const Gap(),
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
                maxLength: 2000,
                controller: viewModel.summaryCommentsController,
                onChanged: (value) {
                  viewModel.summaryComments = value;
                },
                onSaved: (String? value) {
                  viewModel.summaryComments = (value ?? "").trim();
                },
                readOnly: !viewModel.canEdit || viewModel.otherRolesCheck(),
                filled: !viewModel.canEdit || viewModel.otherRolesCheck(),
              ),
            ),
            const Gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  semanticLabel: "common.save".tr(),
                  label: "common.save".tr(),
                  onPressed: (viewModel.canEdit || viewModel.otherRolesCheck())
                      ? () async {
                          await viewModel.onSaveAndContinue(
                            isContinue: false,
                            context: context,
                          );
                        }
                      : null,
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  label: "common.saveAndContinue".tr(),
                  semanticLabel: "common.saveAndContinue".tr(),
                  onPressed: (viewModel.canEdit || viewModel.otherRolesCheck())
                      ? () async {
                          await viewModel.onSaveAndContinue(
                            isContinue: true,
                            context: context,
                          );
                        }
                      : null,
                ),
              ],
            ),
            const Gap(),
          ],
        ),
      ),
    );
  }

  /// Builds the RAROC information section.
  Widget rarocInfoSection(RelationshipProfitabilitySummaryViewModel viewModel) {
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

  /// Builds the relationship profitability section.
  Widget relationshipProfitabilitySection(
    RelationshipProfitabilitySummaryViewModel viewModel,
  ) {
    return CustomAccordion(
      title: "profitabilityAccountConduct."
              "relationshipProfitabilitySummary.relationshipProfitability"
          .tr(),
      children: [
        RimListAccordion(viewModel: viewModel),
      ],
    );
  }

  /// Builds the relationship profitability group section.
  Widget relationshipProfitabilityGroupSection(
    RelationshipProfitabilitySummaryViewModel viewModel,
  ) {
    final groupName = Globals.request?.groupName ?? "AGA (125)";
    // viewModel.currentGroupName() ?? Globals.request?.groupName;
    if (Utils.isGroupApplication()) {
      return CustomAccordion(
        title: "profitabilityAccountConduct.relationshipProfitabilitySummary."
                "relationshipProfitabilityGroup"
            .tr(namedArgs: {"groupName": groupName}),
        // "Relationship Profitability Group Name- $groupName".tr()
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
