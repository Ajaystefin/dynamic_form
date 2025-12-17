import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';

class CompanyRimField extends StatelessWidget {
  final FileAttachmentViewModel viewModel;
  const CompanyRimField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "eDigitalFilingFileAttachments.fileAttachments.companyRim".tr(),
        isRequired: true,
        showLabel: true,
        child: (!Utils.isGroupApplication())
            ? CustomTextField(
                initialValue: "${viewModel.request.customerRimNo}",
                readOnly: true,
                filled: true,
                fillColor: AppColors.tableCellColorGroupedRow,
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (viewModel.isFinancialStatementsSelected())
                    Flexible(
                      // flex: 1,
                      child: CustomCheckbox(
                        value: viewModel.isSelectAllCompanyRims,
                        onChange: (bool? value) {
                          viewModel.toggleSelectAllCompanyRims(value ?? false);
                        },
                        contentPadding: EdgeInsets.zero,
                        child: Text(
                          "eDigitalFilingFileAttachments.fileAttachments.selectAllCompanyRims"
                              .tr(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  Flexible(
                    // flex: 2,
                    child: CustomMultiSelectDropdown(
                      isEnabled: viewModel.isFinancialStatementsSelected()
                          ? !viewModel.isSelectAllCompanyRims
                          : Utils.isGroupApplication(),
                      selectedItems: viewModel.isSelectAllCompanyRims
                          ? null
                          : viewModel.selectedCompanyRims,
                      items: viewModel.rimList,
                      key: ValueKey(
                          '${viewModel.selectedCompanyRims.hashCode}_${viewModel.isSelectAllCompanyRims}'),
                      validationMessage: viewModel.isSelectAllCompanyRims
                          ? null
                          : "common.validation.requiredField".tr(),
                      isSearchable: true,
                      onSelected: (List<String> selectedValues) {
                        viewModel.updateCompanyRim(selectedValues);
                      },
                    ),
                  ),
                ],
              ));
  }
}
