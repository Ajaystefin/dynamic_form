import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/model.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart';

class SectionThree extends StatelessWidget {
  final EsgCertificationViewModel viewModel;
  const SectionThree({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final String headerTitle = viewModel.sectionTitles!.length > 2
        ? viewModel.sectionTitles![2].name!.tr()
        : '';
    // Only keep guidance items whose `reference1` matches this section’s title
    final String sectionGuidelines = viewModel.additionalGuidelines!.isNotEmpty
        ? viewModel.additionalGuidelines![2].name!
        : '';

    return BoxLayout(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomSectionHeader(title: headerTitle),
        GuidelinesSection(
          headerText:
              'certification.esgCertification.additionalGuidnaceText'.tr(),
          guidelines: sectionGuidelines,
        ),
        const Gap(),
      ]),
    );
  }
}
