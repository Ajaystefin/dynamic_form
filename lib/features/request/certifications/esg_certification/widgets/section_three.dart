import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart";

/// Section three of the ESG Certification form.
class SectionThree extends StatelessWidget {
  /// Creates section three.
  const SectionThree({required this.viewModel, super.key});

  /// ESG certification view model.
  final EsgCertificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    const int sectionId = ServerConstants.esgSection3Id;
    final String headerTitle = viewModel.sectionTitleById(sectionId);

    final String sectionGuidelines =
        (sectionId != 0) ? viewModel.guidelinesForSectionId(sectionId) : "";

    return SizedBox(
      width: double.infinity,
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSectionHeader(
              title: headerTitle,
              enableEllipsis: true,
              maxLines: 1,
              ellipsisCharLimit: 110,
            ),
            GuidelinesSection(
              headerText:
                  "certification.esgCertification.additionalGuidnaceText".tr(),
              guidelines: sectionGuidelines,
            ),
            const Gap(),
          ],
        ),
      ),
    );
  }
}
