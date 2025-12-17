import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';

class ContractorsTable extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const ContractorsTable(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    List<TableColumn> getColumns = [
      TableColumn(
          forcedWidth: 130,
          label: Text(
              "project.viewEditContractDetails.contractorTable.contractorName"
                  .tr())),
      TableColumn(
          label:
              Text("project.viewEditContractDetails.contractorTable.rim".tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.segment".tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.type".tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.contractCode"
                  .tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.contractValue"
                  .tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.completion"
                  .tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.paymaster"
                  .tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.guarantees"
                  .tr())),
      TableColumn(
          label: Text(
              "project.viewEditContractDetails.contractorTable.total".tr())),
    ];

    List<List<Widget>> getRows() {
      List<Contract> contracts = viewModel.contracts;
      return List.generate(
          contracts.length,
          (i) => [
                Text(contracts[i].contractName ?? ""),
                Text("${contracts[i].rimNo}"),
                Text(contracts[i].segment ?? ""),
                Text(contracts[i].type ?? ""),
                TextButton(
                    onPressed: () => router.go(Routes.editContract),
                    child: Text("${contracts[i].contractCode}",
                        style: const TextStyle(
                          fontSize: AppStyle.fontSizeSmall,
                        ))),
                Text("${contracts[i].contractorValue}"),
                Text("${contracts[i].completion}"),
                Text("${contracts[i].paymasterName}"),
                Text("${contracts[i].guarantees}"),
                Text("${contracts[i].total}"),
              ]);
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: CustomRawTable(
              key: UniqueKey(), columns: getColumns, rows: getRows()),
        )
      ],
    );
  }
}
