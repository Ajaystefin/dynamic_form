import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';

class LimitAllocationTable extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const LimitAllocationTable({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.limitAllocation".tr(),
      child: SizedBox(
        height: 0.2.h,
        child: SingleChildScrollView(
          child: CustomRawTable(
            key: UniqueKey(),
            columns: [
              TableColumn(
                  label: Text('facilities.createFacility.customerRIM'.tr())),
              TableColumn(
                  label: Text('facilities.createFacility.amountAed'.tr())),
            ],
            rows: (viewModel.borrowersByRimInTable).map((borrower) {
              return [
                Center(
                  child: Text("RIM NO ${borrower.name ?? ""}"),
                ),
                Center(
                  child: CustomTextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(21),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    initialValue: borrower.description,
                    keyboardType: TextInputType.number,
                    onChanged: (allocationAmount) {
                      viewModel.compareAllocationAmount(
                          allocationAmount, borrower);
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
