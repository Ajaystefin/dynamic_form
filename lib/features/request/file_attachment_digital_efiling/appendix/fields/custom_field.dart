import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_entry.dart";

/// CustomFieldWidget stateless widget

class CustomFieldWidget extends StatelessWidget {
  /// Creates [CustomFieldWidget] instance
  const CustomFieldWidget({required this.viewModel, super.key});

  /// AppendixViewModel view model to handle actions
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final entries = viewModel.appendix.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Gap(),
          itemBuilder: (context, index) {
            final AppendixEntry appendixEntry = entries[index];

            // Keep row identity stable with a single key on the row
            return KeyedSubtree(
              key: ValueKey(appendixEntry.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME
                  LabelWidget(
                    label: "eDigitalFilingFileAttachments.appendix.name".tr(),
                    isRequired: true,
                    isEnabled: !viewModel.isAppendixReadOnly,
                    child: CustomTextField(
                      initialValue: appendixEntry.label,
                      maxLength: 100,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "common.validation.emptyField".tr();
                        }
                        return null;
                      },
                      inputFormatters: [
                        // Allow ONLY letters, numbers, and spaces
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z0-9\s]"),
                        ),
                      ],
                      onChanged: (value) => viewModel
                          .onUpdateAppendix(appendixEntry.id, label: value),
                    ),
                  ),
                  const Gap(),

                  // NOTES
                  LabelWidget(
                    label: "eDigitalFilingFileAttachments.appendix.notes".tr(),
                    isRequired: true,
                    isEnabled: !viewModel.isAppendixReadOnly,
                    child: UnifiedTextEditor(
                      key: ValueKey("rich-text-editor-${appendixEntry.id}"),
                      editorId: "rich-text-editor-${appendixEntry.id}",
                      scrollController: viewModel.scrollController,
                      showVideoUpload: false,
                      // semanticLabel: TabConstants.remarksTitles[tab]!.tr(),
                      controller: viewModel.commentControllers[index],
                      initialText: appendixEntry.value,
                      characterLimit: 5000,
                      // disable: viewModel.isReadOnlyMode,
                    ),
                  ),
                  const Gap(),

                  if (!viewModel.isAppendixReadOnly)

                    // REMOVE BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          label: "eDigitalFilingFileAttachments.appendix.remove"
                              .tr(),
                          onPressed: () => viewModel
                              .onRemoveAppendixEntryById(appendixEntry.id),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
        const Gap(),
        if (!viewModel.isAppendixReadOnly)
          CustomButton(
            label: "eDigitalFilingFileAttachments.appendix.addAppendix".tr(),
            onPressed: viewModel.onAddAppendix,
          ),
      ],
    );
  }
}
