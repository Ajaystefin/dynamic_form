import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/model.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/state.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/widgets/remarks_field.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/certification_data.dart";

/// Certificate table for other certifications.
class CertificateTable extends StatelessWidget {
  /// Creates a certificate table.
  const CertificateTable({
    required this.certificates,
    super.key,
  });

  /// List of certificates displayed in the table.
  final List<Reference> certificates;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtherCertificationsViewModel, OtherCertificationsState>(
      builder: (context, state) {
        final viewModel = context.read<OtherCertificationsViewModel>();

        return CustomRawTable(
          rowsPerPage: 10,
          rowHeight: 60,
          columns: [
            TableColumn(
              forcedWidth: 300.w,
              label: Text("certification.otherCertifications.particulars".tr()),
            ),
            TableColumn(
              label: Text("certification.otherCertifications.yesNoNA".tr()),
            ),
            TableColumn(
              forcedWidth: 250.w,
              label: Text("certification.otherCertifications.remarks".tr()),
            ),
          ],
          rows: certificates.map((cert) {
            final int? referenceId = cert.id;
            if (referenceId == null) {
              return <Widget>[];
            }

            final CertificationData detail =
                viewModel.getCertificationById(referenceId);

            return [
              // Column 1: Certificate Name
              CustomTooltip(
                isRichMessage: true,
                message: cert.name ?? "",
                child: Text(cert.name ?? "", textAlign: TextAlign.start),
              ),

              // Column 2: Dropdown for Yes/No/NA
              Center(
                child: FormField<Reference>(
                  key: ValueKey("dropdown_$referenceId"),
                  initialValue: detail.selectedOption,
                  builder: (field) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomDropdown<Reference>(
                          key: ValueKey("dropdown_widget_$referenceId"),
                          showClearIcon: false,
                          isEnabled: viewModel.canEdit,
                          items: viewModel.yesNoNaOptions,
                          selectedItems: detail.selectedOption != null
                              ? [detail.selectedOption]
                              : [],
                          onSelected: (selected) {
                            if (selected.isNotEmpty) {
                              final Reference selectedValue = selected.first;

                              final CertificationData? current =
                                  viewModel.certificationDataMap[referenceId];
                              if (current != null &&
                                  current.selectedOption?.id !=
                                      selectedValue.id) {
                                current
                                  ..selectedOption = selectedValue
                                  ..isUpdated = true;
                              }

                              field.didChange(selectedValue);
                            }
                          },
                          dropdownBuilder: (_, item) =>
                              dropdownBuilderWidget(text: item?.name),
                          itemBuilder: (
                            _,
                            item, {
                            bool? isDisabled,
                            bool? isSelected,
                          }) =>
                              dropdownItemBuildWidget(item.name),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              field.errorText ?? "",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Column 3: Remarks Field
              Center(
                child: FormField<String>(
                  initialValue: detail.remarks,
                  builder: (field) {
                    return RemarksField(
                      readOnly: !viewModel.canEdit,
                      key: ValueKey(referenceId),
                      referenceId: referenceId,
                      initialText: detail.remarks ?? "",
                      onChanged: (value) {
                        final CertificationData? current =
                            viewModel.certificationDataMap[referenceId];
                        if (current != null && current.remarks != value) {
                          current
                            ..remarks = value
                            ..isUpdated = true;
                        }
                        field.didChange(value);
                      },
                    );
                  },
                ),
              ),
            ];
          }).toList(),
        );
      },
    );
  }
}
