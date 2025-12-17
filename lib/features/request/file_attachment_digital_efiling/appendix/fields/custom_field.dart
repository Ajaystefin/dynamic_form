import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';
import 'package:wcas_frontend/models/request/file_attachment/appendix_entry.dart';

class CustomFieldWidget extends StatelessWidget {
  const CustomFieldWidget({super.key, required this.viewModel});
  final AppendixViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final entries = viewModel.entries;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListView.separated(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Gap(),
          itemBuilder: (context, index) {
            final AppendixEntry appendixEntry = entries[index];

            return KeyedSubtree(
                key: ValueKey(appendixEntry.id),
                child: ListView(shrinkWrap: true, children: [
                  LabelWidget(
                    label: 'eDigitalFilingFileAttachments.appendix.name'.tr(),
                    showLabel: true,
                    isRequired: true,
                    child: CustomTextField(
                      counterText: '',
                      key: ValueKey(
                          'label_${appendixEntry.id}'), // keeps cursor stable for this input
                      initialValue: appendixEntry.label,
                      // labelText: 'eDigitalFilingFileAttachments.appendix.name'.tr(),
                      maxLength: 100,
                      validator: CustomValidator.requiredField,
                      
                      inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.,\-]')),
],

                      onChanged: (v) => viewModel
                          .onUpdateAppendix(appendixEntry.id, label: v),
                    ),
                  ),
                  const Gap(),
                  LabelWidget(
                    label: 'eDigitalFilingFileAttachments.appendix.notes'.tr(),
                    showLabel: true,
                    isRequired: true,
                    child: CustomTextArea(
                      counterText: '',
                      key: ValueKey('value_${appendixEntry.id}'),
                      initialValue: appendixEntry.value,
                      validator: CustomValidator.requiredField,
                      //labelText:'eDigitalFilingFileAttachments.appendix.notes'.tr(),
                      maxLength: 5000,
                      onChanged: (v) => viewModel
                          .onUpdateAppendix(appendixEntry.id, value: v),
                    ),
                  ),
                  const Gap(),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomButton(
                            label:
                                'eDigitalFilingFileAttachments.appendix.remove'
                                    .tr(),
                            onPressed: () =>
                                viewModel.onRemoveAppendix(appendixEntry.id))
                      ])
                ]));
          }),
      const Gap(),
      CustomButton(
          label: 'eDigitalFilingFileAttachments.appendix.addAppendix'.tr(),
          onPressed: viewModel.onAddAppendix)
    ]);
  }
}
