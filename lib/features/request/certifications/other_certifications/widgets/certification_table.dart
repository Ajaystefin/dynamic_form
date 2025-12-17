import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/certifications/other_certifications/model.dart';
import 'package:wcas_frontend/features/request/certifications/other_certifications/state.dart';
import 'package:wcas_frontend/features/request/certifications/other_certifications/widgets/remarks_field.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class CertificateTable extends StatelessWidget {
  final List<Reference> certificates;

  const CertificateTable({
    super.key,
    required this.certificates,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtherCertificationsViewModel, OtherCertificationsState>(
      builder: (context, state) {
        final viewModel = context.read<OtherCertificationsViewModel>();

        return CustomRawTable(
          rowsPerPage: 10,
          rowHeight: 60,
          autoFitWidth: true,
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
            final referenceId = cert.id;
            if (referenceId == null) return <Widget>[];

            final detail = viewModel.getCertificationById(referenceId);

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
                  key: ValueKey('dropdown_$referenceId'),
                  initialValue: detail.selectedOption,
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomDropdown<Reference>(
                          key: ValueKey('dropdown_widget_$referenceId'),
                          showClearIcon: false,
                          isEnabled: !viewModel.isReadOnly,
                          items: viewModel.yesNoNaOptions,
                          selectedItems: detail.selectedOption != null
                              ? [detail.selectedOption!]
                              : [],
                          onSelected: (selected) {
                            if (selected.isNotEmpty) {
                              final selectedValue = selected.first;

                              final current =
                                  viewModel.certificationDataMap[referenceId];
                              if (current != null &&
                                  current.selectedOption?.id !=
                                      selectedValue.id) {
                                current.selectedOption = selectedValue;
                                current.isUpdated = true;
                              }

                              field.didChange(selectedValue);
                            }
                          },
                          dropdownBuilder: (_, item) =>
                              dropdownBuilderWidget(text: item?.name),
                          itemBuilder: (_, item, __, ___) =>
                              dropdownItemBuildWidget(item.name),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(field.errorText ?? '',
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12)),
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
                      readOnly: viewModel.isReadOnly,
                      key: ValueKey(referenceId),
                      referenceId: referenceId,
                      initialText: detail.remarks ?? '',
                      onChanged: (value) {
                        final current =
                            viewModel.certificationDataMap[referenceId];
                        if (current != null && current.remarks != value) {
                          current.remarks = value;
                          current.isUpdated = true;
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
