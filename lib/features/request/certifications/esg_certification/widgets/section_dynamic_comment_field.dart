import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";

class SectionDynamicCommentField extends StatelessWidget {
  const SectionDynamicCommentField({
    required this.label,
    required this.initialValue,
    required this.headerTitle,
    required this.onChanged,
    super.key,
    this.readOnly = false,
  });
  final String label;
  final String initialValue;
  final String headerTitle;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(title: headerTitle),
              const Gap(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelWidget(
                    label: label,
                    isRequired: true,
                    labelStyle: AppStyle.boldLabel,
                  ),
                  CustomTextArea(
                    readOnly: readOnly,
                    validator: CustomValidator.requiredField,
                    semanticLabel:
                        "certification.esgCertification.additionalCheckList"
                            .tr(),
                    autoFocus: false,
                    maxLength: 2000,
                    initialValue: initialValue,
                    onChanged: onChanged,
                  ),
                  const Gap(size: GapSize.small),
                ],
              ),
            ],
          ),
        ),
        const Gap(),
      ],
    );
  }
}
