import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/state.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/widgets/account_conduct_accordian.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel =
        context.read<RelationshipProfitabilityDetailedViewModel>();

    return BlocBuilder<RelationshipProfitabilityDetailedViewModel,
        RelationshipProfitabilityDetailedState>(
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
                              .relationshipProfitabilityDetailed,
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
    RelationshipProfitabilityDetailedState state,
    RelationshipProfitabilityDetailedViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
        return Center(child: Text("common.emptyState".tr()));
      case LoadingStatus.error:
        return Center(child: Text("common.errorState".tr()));
      default:
        return _buildView(state, viewModel, context);
    }
  }

  Widget _buildView(
    RelationshipProfitabilityDetailedState state,
    RelationshipProfitabilityDetailedViewModel viewModel,
    BuildContext context,
  ) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          AccountConductAccordion(viewModel: viewModel),
          const Gap(),

          // Label above textarea
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSelectableText(
                text: "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.rmComments"
                    .tr(),
                semanticsLabel: "profitabilityAccountConduct."
                        "relationshipProfitabilitySummary.rmComments"
                    .tr(),
                textAlign: TextAlign.right,
                style: AppStyle.tableSuffixHeaderStyle,
              ),
            ],
          ),

          // Strategy comments textarea
          CustomTextArea(
            maxLength: 5000,
            // If your CustomTextArea exposes these, uncomment to hard-enforce:
            // maxLengthEnforcement: MaxLengthEnforcement.enforced,
            // inputFormatters: const [LengthLimitingTextInputFormatter(5000)],
            initialValue: viewModel.strategyComment,
            // Keep VM updated as user types (nice UX and avoids relying only on
            // onSaved)
            onChanged: (String value) {
              viewModel.strategyComment = value;
            },
            // Ensure the latest value is captured on form.save()
            onSaved: (String? value) {
              viewModel.strategyComment = (value ?? "").trim();
            },
          ),

          const Gap(),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                semanticLabel: "common.save".tr(),
                label: "common.save".tr(),
                onPressed: (viewModel.canEdit)
                    ? () async {
                        // Trigger onSaved for all fields in this form
                        viewModel.formKey.currentState?.save();
                        await viewModel.saveComments();
                      }
                    : null,
              ),
              const Gap(direction: Axis.horizontal),
              CustomButton(
                semanticLabel: "common.saveAndContinue".tr(),
                label: "common.saveAndContinue".tr(),
                onPressed: (viewModel.canEdit)
                    ? () async {
                        // Trigger onSaved for all fields in this form
                        viewModel.formKey.currentState?.save();
                        await viewModel.saveComments(isContinue: true);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
