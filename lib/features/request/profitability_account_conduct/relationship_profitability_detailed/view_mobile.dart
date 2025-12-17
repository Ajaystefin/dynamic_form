import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/tab_menu.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/widgets/account_conduct_accordian.dart';
import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    RelationshipProfitabilityDetailedViewModel viewModel =
        context.read<RelationshipProfitabilityDetailedViewModel>();
    return BlocBuilder<RelationshipProfitabilityDetailedViewModel,
        RelationshipProfitabilityDetailedState>(builder: (context, state) {
      return Layout(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title:
                        "profitabilityAccountConduct.relationshipProfitabilitySummary.sectionTitle"
                            .tr()),
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
                          labels: TabConstants.revenueCrossSellTitles),
                      BoxLayout(child: _body(context, state, viewModel)),
                    ],
                  ),
                )
              ],
            ))),
      );
    });
  }

  Widget _body(
      BuildContext context,
      RelationshipProfitabilityDetailedState state,
      RelationshipProfitabilityDetailedViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return _buildView(state, viewModel, context);
    }
  }

  Widget _buildView(
      RelationshipProfitabilityDetailedState state,
      RelationshipProfitabilityDetailedViewModel viewModel,
      BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          AccountConductAccordion(viewModel: viewModel),
          const Gap(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CustomSelectableText(
              text:
                  'profitabilityAccountConduct.relationshipProfitabilitySummary.rmComments'
                      .tr(),
              semanticsLabel:
                  'profitabilityAccountConduct.relationshipProfitabilitySummary.rmComments'
                      .tr(),
              textAlign: TextAlign.right,
              style: AppStyle.tableSuffixHeaderStyle,
            )
          ]),
          CustomTextArea(
            // maxLines: 10,
            // minLines: 4,
            initialValue: viewModel.strategyComment,
            // validator: CustomValidator.requiredField,
            onSaved: (String? value) {
              viewModel.strategyComment = value;
            },
          ),
          const Gap(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                  semanticLabel: "common.save".tr(),
                  label: "common.save".tr(),
                  onPressed: () async {
                     await viewModel.saveComment();
                  }),
              const Gap(direction: Axis.horizontal),
              CustomButton(
                  semanticLabel:
                      "common.saveAndContinue".tr(), 
                  label: "common.saveAndContinue".tr(), // "Save & Continue",
                  onPressed: () async {
                    await viewModel.saveComment(ifNavigate: true);
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
