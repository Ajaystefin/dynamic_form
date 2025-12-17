import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/model.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/state.dart';

class SectionFive extends StatelessWidget {
  final EsgCertificationViewModel viewModel;
  final EsgCertificationState state;
  const SectionFive({super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomSectionHeader(
            title: "certification.esgCertification.additionalCheckList".tr()),
        const Gap(),
        CustomTextArea(
          readOnly: viewModel.isReadOnly,
          semanticLabel:
              "certification.esgCertification.additionalCheckList".tr(),
          key: ValueKey(viewModel.fieldVersion),
          width: MediaQuery.of(context).size.width * .8,
          autoFocus: false,
          maxLength: 2000,
          initialValue: state.additionalChecklist.capitalizeFirstLetter(),
          onChanged: viewModel.updateAdditionalChecklist,
        ),
        const Gap(size: GapSize.medium),
        viewModel.isReadOnly
            ? Container()
            : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                CustomButton(
                  label: "certification.esgCertification.saveAndContinue".tr(),
                  semanticLabel:
                      "certification.esgCertification.saveAndContinue".tr(),
                  onPressed: viewModel.isSubmitting
                      ? null
                      : () async => await viewModel.submitCertification(),
                ),
              ]),
        const Gap(size: GapSize.medium),
      ]),
    );
  }
}
