import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/icon_button.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";

class FacilityValuationWidget extends StatefulWidget {
  const FacilityValuationWidget({
    required this.documentData,
    required this.viewModel,
    super.key,
  });
  final List<DocSubTypeDetail?>? documentData;
  final DigitalEfilingViewModel viewModel;

  @override
  State<FacilityValuationWidget> createState() =>
      _FacilityValuationWidgetState();
}

class _FacilityValuationWidgetState extends State<FacilityValuationWidget> {
  String accountFilter = "";
  String docTypeFilter = "";
  String appRefFilter = "";
  bool isDateAscending = true;
  late final DigitalEfilingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final List<DocSubTypeDetail?>? filteredData =
        widget.documentData?.where((doc) {
      final String acNo = doc?.data?.acNo?.toString().toLowerCase() ?? "";
      final String docType = doc?.data?.remarks?.toString().toLowerCase() ?? "";
      final String appRef =
          doc?.data?.referenceNo?.toString().toLowerCase() ?? "";
      return acNo.contains(accountFilter.toLowerCase()) &&
          docType.contains(docTypeFilter.toLowerCase()) &&
          appRef.contains(appRefFilter.toLowerCase());
    }).toList();

// Sort by scanDate
    filteredData?.sort((a, b) {
      final DateTime dateA = DateTimeUtils.parseDateFile(a?.data?.date);
      final DateTime dateB = DateTimeUtils.parseDateFile(b?.data?.date);
      return isDateAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      columnHeaderHeight: 30.w,
      columns: _getCommentColumns(),
      rowModels: _getCommentRows(filteredData, viewModel),
      rowsPerPage: 20,
      sortable: true,
    );
  }

  List<TableColumn> _getCommentColumns() {
    return [
      TableColumn(forcedWidth: 10.w, label: const Text("")),
      TableColumn(
        width: 250.w,
        label: Text("eDigitalFilingFileAttachments.digitalEfiling.refNo".tr()),
      ),
      TableColumn(
        width: 250.w,
        label: Text("eDigitalFilingFileAttachments.digitalEfiling.acNo".tr()),
      ),
      TableColumn(
        width: 280.w,
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.docType".tr(),
        ),
      ),
      TableColumn(
        width: 250.w,
        label:
            Text("eDigitalFilingFileAttachments.digitalEfiling.scanDate".tr()),
      ),
      // TableColumn(
      //     width: 250.w,
      //     label:

      // TableColumn(
      //     width: 250.w,
      //     label: Text(
      //         "eDigitalFilingFileAttachments.digitalEfiling.remarks".tr())),
      TableColumn(
        width: 280.w,
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.fileLink".tr(),
        ),
      ),
    ];
  }

  Widget _filterField(
    String? text,
    FilterType filterType,
    Function(String) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            width: 80.w,
            semanticLabel: filterType.name,
            initialValue: text,
            fillColor: AppColors.white,
            filled: true,
            counterText: "",
            textStyle: const TextStyle(fontSize: 13),
            onSubmitted: onChanged,
          ),
        ),
      ],
    );
  }

  List<RowModel> _getCommentRows(
    List<DocSubTypeDetail?>? data,
    DigitalEfilingViewModel viewModel,
  ) {
    final RowModel filterRow = RowModel(
      widget: [
        const SizedBox(),
        _filterField(appRefFilter, FilterType.referenceNumber, (value) {
          setState(() => appRefFilter = value);
        }),
        _filterField(accountFilter, FilterType.accountNumber, (value) {
          setState(() => accountFilter = value);
        }),
        _filterField(docTypeFilter, FilterType.documentType, (value) {
          setState(() => docTypeFilter = value);
        }),
        CustomTooltip(
          message: isDateAscending ? "Sort Ascending" : "Sort Descending",
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.swap_vert,
                size: 26,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                setState(() {
                  isDateAscending = !isDateAscending;
                });
              },
            ),
          ),
        ),
        // const SizedBox(),
        // const SizedBox(),
        const SizedBox(),
      ],
      isFilterRow: true,
    );

    final List<RowModel> rows = data!.map((doc) {
      final docInfo = doc?.data;
      final date = docInfo?.date;
      return RowModel(
        widget: [
          Checkbox(
            value: docInfo?.isChecked ?? false,
            onChanged: (value) {
              viewModel.toggleDocumentSelection(
                UniqueKey().toString(),
                value ?? false,
                docInfo,
              );
            },
          ),
          Text(docInfo?.referenceNo?.toString() ?? "-"),
          Text(docInfo?.acNo?.toString() ?? "-"),
          Text(docInfo?.remarks?.toString() ?? "-"),
          Text(
            docInfo?.date == null
                ? ""
                : DateFormat("dd-MM-yyyy").format(date!).toString(),
          ),
          // Text(docInfo?.decision?.toString() ?? '-'),
          // Text(docInfo?.remarks?.toString() ?? '-'),
          dynamicIcon(
            icon: Icons.file_present,
            iconSize: 20,
            iconColor: AppColors.buttonBackground,
            borderColor: AppColors.textFieldBorder,
            padding: 4,
            borderRadius: 4,
            onTap: () {
              viewModel.downloadDocument(
                docInfo?.edmsDriveItemId,
                docInfo?.webUrl,
                docInfo?.fileName,
              );
            },
          ),
        ],
        isFilterRow: false,
      );
    }).toList();

    return [filterRow, ...rows];
  }
}
