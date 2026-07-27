import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";

/// A reusable section containing a header and a comment text area.
class SectionDynamicCommentField extends StatelessWidget {
  /// Creates a section dynamic comment field.
  const SectionDynamicCommentField({
    required this.fieldLabel,
    required this.initialCommentText,
    required this.sectionTitle,
    required this.onChanged,
    super.key,
    this.readOnly = false,
  });

  /// Label shown above the text area.
  final String fieldLabel;

  /// Initial comment text displayed in the text area.
  final String initialCommentText;

  /// Title displayed for the section header.
  final String sectionTitle;

  /// Called whenever the comment text changes.
  final ValueChanged<String> onChanged;

  /// Whether the text area is editable.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: sectionTitle,
                enableEllipsis: true,
                maxLines: 1,
                ellipsisCharLimit: 110,
              ),
              const Gap(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelWidget(
                    label: fieldLabel,
                    isRequired: true,
                    labelStyle: AppStyle.boldLabel,
                    labelMaxLines: 5,
                    showOverflowTooltip: false,
                  ),
                  CustomTextArea(
                    readOnly: readOnly,
                    validator: CustomValidator.requiredField,
                    semanticLabel:
                        "certification.esgCertification.additionalCheckList"
                            .tr(),
                    maxLength: 2000,
                    initialValue: initialCommentText,
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
