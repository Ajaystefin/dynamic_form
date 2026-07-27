import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/model.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/state.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Displays the desktop view for the FI credit assessment approval screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop FI credit assessment approval view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final CreditAssessmentFIViewModel viewModel =
        context.read<CreditAssessmentFIViewModel>();
    return BlocBuilder<CreditAssessmentFIViewModel, CreditAssessmentFIState>(
      builder: (context, state) {
        return Layout(
          child: BoxLayout(
            child: SingleChildScrollView(
              controller: viewModel.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "approval.creditAssessment.title".tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    child: _body(context, state, viewModel),
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
    CreditAssessmentFIState state,
    CreditAssessmentFIViewModel viewModel,
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
        return _buildView(viewModel, context);
    }
  }

  Widget _buildView(
    CreditAssessmentFIViewModel viewModel,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          if (viewModel.rims.isEmpty)
            Center(
              child: Text(
                "approval.requestForFOL.noBankRimsAvailable".tr(),
              ),
            ),
          for (final Customer rim in viewModel.rims)
            Column(
              children: [
                CustomAccordion(
                  title: "RIM No ${rim.customerRimNo}",
                  initiallyExpanded: true,
                  isEnabled: true,
                  children: [
                    LabelWidget(
                      label: "approval.comments.tabTitle".tr(),
                      labelStyle: AppStyle.tableHeaderStyle,
                      isRequired: true,
                      child: UnifiedTextEditor(
                        key: ValueKey("rim_${rim.customerRimNo}"),
                        disable: viewModel.isReadOnly,
                        semanticLabel: "approval.comments.tabTitle".tr(),
                        characterLimit: 5000,
                        controller: viewModel.rimController[rim.customerRimNo],
                        scrollController: viewModel.scrollController,
                        initialText:
                            viewModel.initialTextMap[rim.customerRimNo] ?? "",
                        editorId: "comments_${rim.customerRimNo}",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const Gap(),
          if (!viewModel.isReadOnly)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  semanticLabel: "approval.creditAssessment.save".tr(),
                  label: "approval.creditAssessment.save".tr(),
                  onPressed: (viewModel.rims.isEmpty)
                      ? null
                      : () => viewModel.onSavePress(context: context),
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  semanticLabel:
                      "approval.creditAssessment.saveAndContinue".tr(),
                  label: "approval.creditAssessment.saveAndContinue".tr(),
                  onPressed: (viewModel.rims.isEmpty)
                      ? null
                      : () {
                          viewModel.onSavePress(
                            context: context,
                            isContinue: true,
                          );
                        },
                ),
              ],
            ),
          const Gap(),
        ],
      ),
    );
  }
}
