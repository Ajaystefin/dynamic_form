import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// CompanyRimField stateless widget
class CompanyRimField extends StatelessWidget {
  /// Creates [CompanyRimField] instance
  const CompanyRimField({required this.viewModel, super.key});

  /// DigitalEfilingViewModel view model to handle actions
  final UploadDocumentDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.companyRim".tr(),
      isRequired: true,
      child: (!viewModel.isGroupApp)
          ? CustomTextField(
              initialValue: viewModel.selectedCustomerRim.toString(),
              readOnly: true,
              filled: true,
              fillColor: AppColors.tableCellColorGroupedRow,
            )
          : Row(
              children: [
                if (viewModel.isFinancialStatementsSelected() ||
                    viewModel.isCreditLensSelected())
                  Flexible(
                    // flex: 1,
                    child: CustomCheckbox(
                      value: viewModel.isSelectAllCompanyRims,
                      onChange: ({bool? value}) {
                        viewModel.toggleSelectAllCompanyRims(
                          value: value ?? false,
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      child: Text(
                        "eDigitalFilingFileAttachments."
                                "fileAttachments.selectAllCompanyRims"
                            .tr(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                Flexible(
                  // flex: 2,
                  child: CustomMultiSelectDropdown<Customer>(
                    isEnabled: (viewModel.isFinancialStatementsSelected() ||
                            viewModel.isCreditLensSelected())
                        ? !viewModel.isSelectAllCompanyRims
                        : viewModel.isGroupApp,
                    key: UniqueKey(),
                    semanticLabel: "facilities.createFacility.borrowerRim".tr(),
                    validationMessage: viewModel.isSelectAllCompanyRims
                        ? null
                        : "common.validation.requiredField".tr(),
                    items: viewModel.rimList, // List<Reference>
                    selectedItems: viewModel.isSelectAllCompanyRims
                        ? null
                        : viewModel.selectedCompanyRims,
                    onSelected: (selectedValue) {
                      viewModel.updateCompanyRim(selectedValue);
                    },
                    itemBuilder: (context, item, {isDisabled, isSelected}) {
                      return dropdownItemBuildWidget(
                        item.customerRimNo
                            .toString(), // show the borrower/project name
                        isSelected: isSelected ?? false,
                      );
                    },
                    dropdownBuilder: (context, data) {
                      return dropdownMultiItemBuildScrollWidget(
                        data,
                        (index) => Chip(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelStyle:
                              const TextStyle(fontSize: AppStyle.columnName),
                          label: Text("${data?[index].customerRimNo}"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
