import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';

import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class SelectionTable extends StatefulWidget {
  final DigitalEfilingViewModel viewModel;
  final LoadingStatus loaderStatus;
  const SelectionTable(
      {required this.viewModel, super.key, required this.loaderStatus});

  @override
  State<SelectionTable> createState() => _SelectionTableState();
}

class _SelectionTableState extends State<SelectionTable> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    switch (widget.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.loaded:
        return StatefulBuilder(builder: (context, stateful) {
          return ValueListenableBuilder<Customer?>(
              valueListenable: widget.viewModel.selectedCustomer,
              builder: (context, customerValue, _) {
                return CustomRawTable(
                    key: UniqueKey(),
                    rowsPerPage: 5,
                    initialPage: currentPage,
                    onPageChange: (page) {
                      currentPage = page;
                    },
                    autoFitWidth: false,
                    showPagination: true,
                    columns: getColumns(),
                    rows: _buildRows(customerValue));
              });
        });

      default:
        return Container();
    }
  }

  List<List<Widget>> _buildRows(Customer? customerValue) {
    //Data rows
    final dataRows = <List<Widget>>[];

    for (Customer? customer in widget.viewModel.dailogCustomers) {
      {
        dataRows.add([
          Transform.scale(
            scale: 0.7,
            child: Radio(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              groupValue: customerValue,
              value: customer,
              onChanged: (value) {
                if (value != null) {
                  widget.viewModel.selectedCustomer.value = customer;
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            child: CustomTooltip(
              message: widget.viewModel.isGroupNameSelection
                  ? customer?.groups?.id.toString() ?? ''
                  : customer?.customerRimNo.toString() ?? '',
              child: Text(
                widget.viewModel.isGroupNameSelection
                    ? customer?.groups?.id.toString() ?? ''
                    : customer?.customerRimNo.toString() ?? '',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            child: CustomTooltip(
              message: widget.viewModel.isGroupNameSelection
                  ? customer?.groups?.name.toString() ?? ''
                  : customer?.preferredName ?? '',
              child: Text(
                widget.viewModel.isGroupNameSelection
                    ? customer?.groups?.name.toString() ?? ''
                    : customer?.preferredName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ]);
      }
    }
    return dataRows;
  }

  List<TableColumn> getColumns() {
    return [
      TableColumn(
        forcedWidth: context.isMobile ? 30.w : 30.w,
        label: const SizedBox(),
      ),
      TableColumn(
        width: 245.w,
        label: Text(
          widget.viewModel.isGroupNameSelection
              ? "requestInformation.createRequest.groupId".tr()
              : "requestInformation.createRequest.customerRim".tr(),
        ),
      ),
      TableColumn(
        width: 245.w,
        label: Text(
          widget.viewModel.isGroupNameSelection
              ? "requestInformation.createRequest.groupName".tr()
              : "requestInformation.createRequest.customerName".tr(),
        ),
      ),
    ];
  }
}
