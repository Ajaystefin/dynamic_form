import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/state.dart";

/// Section five of the ESG Certification form.
class SectionFive extends StatelessWidget {
  /// Creates section five.
  const SectionFive({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// ESG certification view model.
  final EsgCertificationViewModel viewModel;

  /// ESG certification state.
  final EsgCertificationState state;

  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(
            title: "certification.esgCertification.additionalCheckList".tr(),
          ),
          const Gap(),
          CustomTextArea(
            readOnly: viewModel.isReadOnly,
            semanticLabel:
                "certification.esgCertification.additionalCheckList".tr(),
            key: ValueKey(viewModel.fieldVersion),
            width: MediaQuery.of(context).size.width * .8,
            maxLength: 2000,
            initialValue: state.additionalChecklist.capitalizeFirstLetter(),
            onChanged: viewModel.updateAdditionalChecklist,
          ),
          const Gap(),
          // Show 'Continue' (navigate only) in read-only mode,
          // or 'Save & Continue' (save + navigate) in edit mode.
          if (viewModel.isReadOnly)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: "certification.esgCertification.continue".tr(),
                  semanticLabel:
                      "certification.esgCertification.continue".tr(),
                  onPressed: () => LayoutViewModel().goToNextRoute(),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label:
                      "certification.esgCertification.saveAndContinue".tr(),
                  semanticLabel:
                      "certification.esgCertification.saveAndContinue".tr(),
                  onPressed: viewModel.isSubmitting
                      ? null
                      : () async => viewModel.submitCertification(),
                ),
              ],
            ),
          const Gap(),
        ],
      ),
    );
  }
}
