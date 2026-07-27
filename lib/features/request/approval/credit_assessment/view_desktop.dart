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
import "package:wcas_frontend/features/request/approval/credit_assessment/model.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/state.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/widgets/rim_list_acordian.dart";

/// Displays the desktop view for the credit assessment approval screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop credit assessment approval view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final CreditAssessmentViewModel viewModel =
        context.read<CreditAssessmentViewModel>();
    return BlocBuilder<CreditAssessmentViewModel, CreditAssessmentState>(
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
    CreditAssessmentState state,
    CreditAssessmentViewModel viewModel,
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

  Widget _buildView(CreditAssessmentViewModel viewModel, BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          const Gap(size: GapSize.large),
          LabelWidget(
            label: "approval.creditAssessment.creditAppraisalRemarks".tr(),
            labelStyle: AppStyle.tableHeaderStyle,
            isRequired: true,
            child: UnifiedTextEditor(
              disable: viewModel.isReadOnly,
              semanticLabel:
                  "approval.creditAssessment.creditAppraisalRemarks".tr(),
              // characterLimit: 5000, // No character limit for Credit Appraisal Remarks
              controller: viewModel.appraisalController,
              scrollController: viewModel.scrollController,
              initialText: viewModel.creditAppraisal,
              editorId: "approval.creditAssessment.creditAppraisalRemarks",
            ),
          ),
          const Gap(size: GapSize.large),
          LabelWidget(
            label: "approval.creditAssessment.creditBrief".tr(),
            labelStyle: AppStyle.tableHeaderStyle,
            isRequired: true,
            child: UnifiedTextEditor(
              disable: viewModel.isReadOnly,
              semanticLabel: "approval.creditAssessment.creditBrief".tr(),
              characterLimit: 5000,
              controller: viewModel.briefController,
              scrollController: viewModel.scrollController,
              initialText: viewModel.creditBrief,
              editorId: "approval.creditAssessment.creditBrief",
            ),
          ),
          const Gap(),
          if (!viewModel.isReadOnly)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  semanticLabel: "approval.creditAssessment.save".tr(),
                  label: "approval.creditAssessment.save".tr(),
                  onPressed: () {
                    viewModel.onSavePress(context: context);
                  },
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  semanticLabel:
                      "approval.creditAssessment.saveAndContinue".tr(),
                  label: "approval.creditAssessment.saveAndContinue".tr(),
                  onPressed: () {
                    viewModel.onSavePress(context: context, isContinue: true);
                  },
                ),
              ],
            ),
          const Gap(),
        ],
      ),
    );
  }

  /// Builds the country RIM section for credit assessment.
  Widget countryRimSection(CreditAssessmentViewModel viewModel) {
    return LabelWidget(
      label: "approval.creditAssessment.creditAppraisalRemarks".tr(),
      labelStyle: AppStyle.tableHeaderStyle,
      isRequired: true,
      child: CustomAccordion(
        initiallyExpanded: true,
        title: "approval.creditAssessment.countryRim".tr(),
        children: [
          RimListAccordion(viewModel: viewModel),
        ],
      ),
    );
  }
}
