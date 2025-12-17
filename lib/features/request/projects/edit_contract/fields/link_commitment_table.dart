import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class LinkCommitmentTable extends StatelessWidget {
  final EditContractViewModel viewModel;
  const LinkCommitmentTable(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      columns: [
        TableColumn(
            label: Text(
                "project.viewEditContractDetails.projectAllocationNumber"
                    .tr())),
        TableColumn(
            label: Text("project.viewEditContractDetails.facilityType".tr())),
        TableColumn(
            label: Text("project.viewEditContractDetails.limitAmount".tr())),
        TableColumn(
            label: Text("project.viewEditContractDetails.currentos".tr())),
      ],
      rows: List.generate(viewModel.linkContract.length, (index) {
        var data = viewModel.linkContract[index];
        return [
          Text("${data.projectAllocationAccount}"),
          Text("${data.facilityType}"),
          Text("${data.limitAmountInAED}"),
          Text("${data.currentOSInAED}"),
        ];
      }),
    );
  }
}
