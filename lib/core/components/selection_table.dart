import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Displays a selectable customer list in a paginated table.
///
/// Allows the user to choose a single customer or group using radio buttons.
class SelectionTable extends StatefulWidget {
  /// Creates a [SelectionTable].
  const SelectionTable({
    required this.customers,
    required this.selectedCustomer,
    required this.isGroupNameSelection,
    required this.loaderStatus,
    super.key,
  });

  /// Customers displayed in the table.
  final List<Customer?> customers;

  /// Currently selected customer.
  final ValueNotifier<Customer?> selectedCustomer;

  /// Indicates whether the table displays group information
  /// instead of customer information.
  final bool isGroupNameSelection;

  /// Current loading state of the table data.
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
              valueListenable: widget.selectedCustomer,
              builder: (context, customerValue, _) {
                return CustomRawTable(
                  key: UniqueKey(),
                  rowsPerPage: 5,
                  initialPage: currentPage,
                  onPageChange: (page) {
                    currentPage = page;
                  },
                  autoFitWidth: false,
                  columns: _getColumns(),
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
    final dataRows = <List<Widget>>[];

    for (final customer in widget.customers) {
      dataRows.add([
        Transform.scale(
          scale: 0.7,
          child: Radio<Customer?>(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            groupValue: customerValue,
            value: customer,
            onChanged: (value) {
              if (value != null) {
                widget.selectedCustomer.value = value;
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 8),
          alignment: Alignment.centerLeft,
          child: CustomTooltip(
            message: widget.isGroupNameSelection
                ? customer?.groups?.id.toString() ?? ""
                : customer?.customerRimNo.toString() ?? "",
            child: Text(
              widget.isGroupNameSelection
                  ? customer?.groups?.id.toString() ?? ""
                  : customer?.customerRimNo.toString() ?? "",
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 8),
          alignment: Alignment.centerLeft,
          child: CustomTooltip(
            message: widget.isGroupNameSelection
                ? customer?.groups?.name.toString() ?? ""
                : customer?.concatCustomerFullName ??
                customer?.displayRIMName ??
                "",
            child: Text(
              widget.isGroupNameSelection
                  ? customer?.groups?.name.toString() ?? ""
                  :  customer?.concatCustomerFullName ??
                customer?.displayRIMName ??
                "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ]);
    }

    return dataRows;
  }

  List<TableColumn> _getColumns() {
    return [
      TableColumn(
        forcedWidth: context.isMobile ? 30.w : 30.w,
        label: const SizedBox(),
      ),
      TableColumn(
        width: 245.w,
        label: Text(
          widget.isGroupNameSelection
              ? "requestInformation.createRequest.groupId".tr()
              : "requestInformation.createRequest.customerRim".tr(),
        ),
      ),
      TableColumn(
        width: 245.w,
        label: Text(
          widget.isGroupNameSelection
              ? "requestInformation.createRequest.groupName".tr()
              : "requestInformation.createRequest.customerName".tr(),
        ),
      ),
    ];
  }
}
