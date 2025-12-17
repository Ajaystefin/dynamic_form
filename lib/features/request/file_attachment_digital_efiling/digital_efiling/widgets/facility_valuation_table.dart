import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/components/icon_button.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';

class FacilityValuationWidget extends StatefulWidget {
  final List<dynamic> documentData;
  final DigitalEfilingViewModel viewModel;

  const FacilityValuationWidget(
      {super.key, required this.documentData, required this.viewModel});

  @override
  State<FacilityValuationWidget> createState() =>
      _FacilityValuationWidgetState();
}

class _FacilityValuationWidgetState extends State<FacilityValuationWidget> {
  String accountFilter = '';
  String docTypeFilter = '';
  bool isDateAscending = true;
  late final DigitalEfilingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    List<dynamic> filteredData = widget.documentData.where((doc) {
      String acNo = doc['acNo']?.toString().toLowerCase() ?? '';
      String docType = doc['docType']?.toString().toLowerCase() ?? '';
      return acNo.contains(accountFilter.toLowerCase()) &&
          docType.contains(docTypeFilter.toLowerCase());
    }).toList();

// Sort by scanDate
    filteredData.sort((a, b) {
      DateTime dateA = DateTimeUtils.parseDateFile(a['scanDate']);
      DateTime dateB = DateTimeUtils.parseDateFile(b['scanDate']);
      return isDateAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      columnHeaderHeight: 30.w,
      columns: _getCommentColumns(),
      rowModels: _getCommentRows(filteredData, viewModel),
      rowsPerPage: 10,
      sortable: true,
    );
  }

  List<TableColumn> _getCommentColumns() {
    return [
      TableColumn(
          width: 250.w,
          label:
              Text("eDigitalFilingFileAttachments.digitalEfiling.refNo".tr())),
      TableColumn(
          width: 250.w,
          label:
              Text("eDigitalFilingFileAttachments.digitalEfiling.acNo".tr())),
      TableColumn(
          width: 280.w,
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.docType".tr())),
      TableColumn(
        width: 250.w,
        label:
            Text("eDigitalFilingFileAttachments.digitalEfiling.scanDate".tr()),
      ),
      TableColumn(
          width: 250.w,
          label:
              Text("eDigitalFilingFileAttachments.digitalEfiling.status".tr())),
      TableColumn(
          width: 250.w,
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.remarks".tr())),
      TableColumn(
          width: 280.w,
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.fileLink".tr())),
    ];
  }

  Widget _filterField(
      String? text, FilterType filterType, Function(String) onChanged) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            width: 80.w,
            semanticLabel: filterType.name,
            initialValue: text,
            fillColor: AppColors.white,
            filled: true,
            counterText: '',
            textStyle: const TextStyle(fontSize: 13),
            onSubmitted: onChanged,
          ),
        ),
      ],
    );
  }

  List<RowModel> _getCommentRows(
      List<dynamic> data, DigitalEfilingViewModel viewModel) {
    RowModel filterRow = RowModel(widget: [
      const SizedBox(),
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
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ], isFilterRow: true);

    List<RowModel> rows = data.map((doc) {
      return RowModel(widget: [
        Text(doc['refNo']?.toString() ?? '-'),
        Text(doc['acNo']?.toString() ?? '-'),
        Text(doc['docType']?.toString() ?? '-'),
        Text(doc['scanDate']?.toString() ?? '-'),
        Text(doc['status']?.toString() ?? '-'),
        Text(doc['remarks']?.toString() ?? '-'),
        dynamicIcon(
          icon: Icons.file_present,
          iconSize: 20,
          iconColor: AppColors.buttonBackground,
          borderColor: AppColors.textFieldBorder,
          padding: 4,
          borderRadius: 4,
          onTap: () {
            viewModel.downloadDocument(doc['fileLink'], doc['fileName']);
          },
        ),
      ], isFilterRow: false);
    }).toList();

    return [filterRow, ...rows];
  }
}
