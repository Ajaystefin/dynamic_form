import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/sic_code.dart";

/// This widget uses a [CustomRawTable] to render customer data and allows
/// editing of the proposed SIC code for each customer.
class SicCodeTableField extends StatelessWidget {
  const SicCodeTableField({
    required this.viewModel,
    super.key,
  });
  final SicCodeReviewViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final List<SicCodeReview>? sicCodeReviewCustomersList =
        viewModel.customerSICcodeReview;
    return CustomRawTable(
      key: UniqueKey(),
      columns: getTableColumns(),
      rowsPerPage: 10,
      rows: List.generate(
        sicCodeReviewCustomersList?.length ?? 0,
        (index) {
          return [
            Text(
              (sicCodeReviewCustomersList ?? [])[index]
                  .customerRimNo
                  .toString(),
            ),
            Text((sicCodeReviewCustomersList ?? [])[index].customerName ?? ""),
            Text(
              (sicCodeReviewCustomersList ?? [])[index]
                      .primaryBusinessActivity ??
                  "",
            ),
            Text(
              (sicCodeReviewCustomersList ?? [])[index].existingSicCode ?? "",
            ),
            CustomDropdown<Reference>(
              validationMessage: "common.validation.emptyField".tr(),
              isSearchable: true,
              items: viewModel.proposedSICcodes ?? [],
              selectedItems: [
                Reference(
                  name: viewModel.customerSICcodeReview?[index].proposedSicCode,
                ),
              ],
              itemBuilder: (context, item, isDisabled, isSelected) =>
                  dropdownItemBuildWidget(
                "${item.name} - ${item.description} ",
                isSelected: isSelected,
              ),
              dropdownBuilder: (context, item) => Text(
                item?.name ?? "",
              ),
              onSelected: (value) {
                viewModel.customerSICcodeReview?[index].proposedSicCode =
                    value.first.name;
              },
            ),
          ];
        },
      ),
    );
  }

  /// Returns a list of [TableColumn] widgets for the table header.

  List<TableColumn> getTableColumns() {
    final List<TableColumn> columns = [];
    final List<String> columnNames = getColumnNames();
    for (final String columnName in columnNames) {
      columns.add(
        TableColumn(
          label: Text(
            // key: ValueKey(columnName),
            columnName,
          ),
        ),
      );
    }
    return columns;
  }

  List<String> getColumnNames() {
    final List<String> columnNames = [
      "customerInformation.sicCodeReview.rimNumber".tr(),
      "customerInformation.sicCodeReview.customerName".tr(),
      "customerInformation.sicCodeReview.primaBusinessActivity".tr(),
      "customerInformation.sicCodeReview.existingSicCode".tr(),
      "customerInformation.sicCodeReview.proposedSICcode".tr(),
    ];
    return columnNames;
  }
}
