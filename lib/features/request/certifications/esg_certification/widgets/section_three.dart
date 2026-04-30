import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart";

class SectionThree extends StatelessWidget {
  const SectionThree({required this.viewModel, super.key});
  final EsgCertificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int secId = viewModel.sectionIdAt(2);
    final String headerTitle =
        secId != 0 ? (viewModel.sectionTitles![2].name ?? "").tr() : "";

    final String sectionGuidelines =
        (secId != 0) ? viewModel.guidelinesForSectionId(secId) : "";
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(title: headerTitle),
          GuidelinesSection(
            headerText:
                "certification.esgCertification.additionalGuidnaceText".tr(),
            guidelines: sectionGuidelines,
          ),
          const Gap(),
        ],
      ),
    );
  }
}
