import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

class SelectionTable extends StatefulWidget {
  const SelectionTable({
    required this.viewModel,
    required this.loaderStatus,
    super.key,
  });
  final CcsysCreateRequestViewModel viewModel;
  final LoadingStatus loaderStatus;

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
        return StatefulBuilder(
          builder: (context, stateful) {
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
                  rows: _buildRows(customerValue),
                );
              },
            );
          },
        );

      default:
        return Container();
    }
  }

  List<List<Widget>> _buildRows(Customer? customerValue) {
    //Data rows
    final dataRows = <List<Widget>>[];

    for (final Customer? customer in widget.viewModel.dailogCustomers) {
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
              message: customer?.customerRimNo.toString() ?? "",
              child: Text(
                customer?.customerRimNo.toString() ?? "",
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            child: CustomTooltip(
              message: customer?.customerName ?? "",
              child: Text(
                customer?.customerName ?? "",
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
          "requestInformation.createRequest.customerRim".tr(),
        ),
      ),
      TableColumn(
        width: 245.w,
        label: Text(
          "requestInformation.createRequest.customerName".tr(),
        ),
      ),
    ];
  }
}
