import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class PpcTable extends StatelessWidget {
  final EditContractViewModel viewModel;
  const PpcTable(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
        key: UniqueKey(),
        columns: [
          TableColumn(label: Text("project.viewEditContractDetails.ppc".tr())),
          TableColumn(
              label: Text("project.viewEditContractDetails.ppcDate".tr())),
          TableColumn(
              label:
                  Text("project.viewEditContractDetails.grossPPCValue".tr())),
          TableColumn(
              label: Text(
                  "project.viewEditContractDetails.cumulativePPCValue".tr())),
          TableColumn(
            label: Text("project.viewEditContractDetails.workDone".tr()),
          ),
          TableColumn(
              label: Text(
                  "project.viewEditContractDetails.cumulativeWorkDone".tr())),
          TableColumn(
              label: Text(
                  "project.viewEditContractDetails.advancedPaymentDeduction"
                      .tr())),
          TableColumn(
              label: Text(
                  "project.viewEditContractDetails.retentionDeduction".tr())),
          TableColumn(
              label: Text("project.viewEditContractDetails.netPPCValue".tr())),
          TableColumn(
              label: Text("project.viewEditContractDetails.vatAmount".tr())),
          // Other Payment
          TableColumn(
            label: Text("project.viewEditContractDetails.otherPayment".tr()),
          ),

// Net Certified Amount + VAT (Calculated)
          TableColumn(
            label: Text(
                "project.viewEditContractDetails.netCertifiedAmountWithVat"
                    .tr()),
          ),

// Actual Payment Received
          TableColumn(
            label: Text(
                "project.viewEditContractDetails.actualPaymentReceived".tr()),
          ),

// Date Payment Received
          TableColumn(
            label: Text(
                "project.viewEditContractDetails.datePaymentReceived".tr()),
          ),
        ],
        rows: List.generate(viewModel.ppc.length, (index) {
          var data = viewModel.ppc[index];
          return [
            Text("${data.ppc}"),
            Text("${data.ppcDate}"),
            Text("${data.grossPPCValue}"),
            Text("${data.cumulativePPCValue}"),
            Text("${data.workDonePercent}"),
            Text("${data.cumulativeWorkDonePercent}"),
            Text("${data.advancePaymentDeduction}"),
            Text("${data.retentionDeduction}"),
            Text("${data.netPPCValue}"),
            Text("${data.vatAmount}"),
            Text("${data.vatAmount}"),
            Text("${data.vatAmount}"),
            Text("${data.vatAmount}"),
            Text("${data.vatAmount}"),
          ];
        }));
  }
}
