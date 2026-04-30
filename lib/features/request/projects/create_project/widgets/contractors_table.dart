import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/request/project/contract.dart";

class ContractorsTable extends StatelessWidget {
  const ContractorsTable(this.viewModel, {super.key});
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<TableColumn> getColumns = [
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.contractCode".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.contractorName".tr(),
        ),
      ),
      TableColumn(
        label: Text("project.viewEditContractDetails.contractorTable.rim".tr()),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.segment".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.type".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.contractValue".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.completion".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.paymaster".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.guarantees".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "project.viewEditContractDetails.contractorTable.total".tr(),
        ),
      ),
    ];

    List<List<Widget>> getRows() {
      final List<Contract> contracts = viewModel.contracts;
      return List.generate(
        contracts.length,
        (i) => [
          TextButton(
            onPressed: () => viewModel.onPressedContractCodeInTable(i),
            child: Text(
              ProjectContractNumericHelper.safeTextLower(
                contracts[i].contractCode,
              ),
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].contractName,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].rimNo,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].segment,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].contractorType,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].contractValue,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].completionPercentage,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].paymaster,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].cbdExposureGuarantees,
            ),
          ),
          Text(
            ProjectContractNumericHelper.safeTextLower(
              contracts[i].cbdExposureTotal,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        CustomRawTable(key: UniqueKey(), columns: getColumns, rows: getRows()),
        if (viewModel.contracts.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text("common.emptyState".tr()),
          ),
      ],
    );
  }
}
