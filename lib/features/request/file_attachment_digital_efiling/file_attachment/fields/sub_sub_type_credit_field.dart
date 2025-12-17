import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';

class SubSubTypeCreditField extends StatelessWidget {
  final FileAttachmentViewModel viewModel;
  const SubSubTypeCreditField({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "eDigitalFilingFileAttachments.fileAttachments.subSubType".tr(),
        showLabel: true,
        isRequired: false,
        child: CustomTextField(
          initialValue: viewModel.request.applicationType?.name ?? "",
          readOnly: true,
          maxLength: 50,
          counterText: "",
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "validation.subSubTypeRequired".tr();
            }
            return null;
          },
          filled: true,
          fillColor: AppColors.tableCellColorGroupedRow,
        ));
  }
}
