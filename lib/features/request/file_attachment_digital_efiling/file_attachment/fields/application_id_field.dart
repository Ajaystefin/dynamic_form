import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';

class ApplicationIdField extends StatelessWidget {
  final FileAttachmentViewModel viewModel;

  const ApplicationIdField({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label:
            "eDigitalFilingFileAttachments.fileAttachments.applicationId".tr(),
        showLabel: true,
        isRequired: false,
        child: CustomTextField(
          initialValue: viewModel.request.applicationRefNo,
          readOnly: true,
          maxLength: 30,
          counterText: "",
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
          ],
          filled: true,
          fillColor: AppColors.tableCellColorGroupedRow,
        ));
  }
}
