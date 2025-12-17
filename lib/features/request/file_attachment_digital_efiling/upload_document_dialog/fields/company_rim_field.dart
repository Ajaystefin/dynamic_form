import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart';

class CompanyRimField extends StatelessWidget {
  final UploadDocumentDialogViewModel viewModel;
  const CompanyRimField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "eDigitalFilingFileAttachments.fileAttachments.companyRim".tr(),
        isRequired: true,
        showLabel: true,
        child: (!Utils.isGroupApplication())
            ? CustomTextField(
                initialValue: viewModel.selectedCustomerRim.toString(),
                readOnly: true,
                filled: true,
                fillColor: AppColors.tableCellColorGroupedRow,
              )
            : CustomMultiSelectDropdown(
                isEnabled: Utils.isGroupApplication(),
                selectedItems: viewModel.selectedCompanyRim,
                items: viewModel.rimList,
                key: ValueKey(viewModel.selectedCompanyRim.hashCode),
                validationMessage: "common.validation.requiredField".tr(),
                isSearchable: true,
                onSelected: (List<String> selectedValues) {
                  viewModel.updateCompanyRim(selectedValues);
                },
              ));
  }
}
