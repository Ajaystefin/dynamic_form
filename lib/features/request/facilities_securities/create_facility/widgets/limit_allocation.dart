import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

/// Widget for displaying and managing limit allocation entries.
class LimitAllocationTable extends StatelessWidget {
  /// Creates a limit allocation table widget.
  const LimitAllocationTable({
    required this.viewModel,
    super.key,
  });

  /// View model containing limit allocation data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String borrowerKeyPart = viewModel.borrowersByRimInTable
        .map((borrowerRef) => (borrowerRef.id ?? borrowerRef.name).toString())
        .join("_");

    final Key tableKey = ValueKey("limit_allocation_table_$borrowerKeyPart");

    return LabelWidget(
      label: "facilities.createFacility.limitAllocation".tr(),
      child: SizedBox(
        height: 0.2.h,
        child: SingleChildScrollView(
          child: CustomRawTable(
            key: tableKey, // changes when selection changes
            columns: [
              TableColumn(
                label: Text("facilities.createFacility.customerRIM".tr()),
              ),
              TableColumn(
                label: Text("facilities.createFacility.amountAed".tr()),
              ),
            ],
            rows: viewModel.borrowersByRimInTable.map((borrower) {
              return [
                Center(child: Text("RIM NO ${borrower.name ?? ""}")),
                Center(
                  child: CustomTextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorFormatter(),
                    ],
                    initialValue: borrower.description,
                    keyboardType: TextInputType.number,
                    onChanged: (allocationAmount) {
                      viewModel.compareAllocationAmount(
                        allocationAmount,
                        borrower,
                      );
                    },
                  ),
                ),
              ];
            }).toList(),
          ),
        ),
      ),
    );
  }
}
