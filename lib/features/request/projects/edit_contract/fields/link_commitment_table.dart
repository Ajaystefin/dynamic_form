import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";

class LinkCommitmentTable extends StatelessWidget {
  const LinkCommitmentTable(this.viewModel, {super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      columns: [
        TableColumn(
          label: Text(
            "project.viewEditContractDetails.projectAllocationNumber".tr(),
          ),
        ),
        TableColumn(
          label: Text("project.viewEditContractDetails.facilityType".tr()),
        ),
        TableColumn(
          label: Text("project.viewEditContractDetails.limitAmount".tr()),
        ),
        TableColumn(
          label: Text("project.viewEditContractDetails.currentos".tr()),
        ),
      ],
      // CHANGE: use the list that your selection methods update
      rows: List.generate(
          viewModel.contract.linkCommitmentNumberWith?.length ?? 0, (index) {
        final data = viewModel.contract.linkCommitmentNumberWith?[index];
        return [
          Text(
            ProjectContractNumericHelper.safeText(
              data?.projectAllocationAccount,
            ),
          ),
          Text(
            viewModel.buildNames(
              options: viewModel.facilityType ?? [],
              id: data?.facilityType,
            ),
          ),
          // Text(ProjectContractNumericHelper.safeText(data?.facilityType)),
          Text(ProjectContractNumericHelper.safeText(data?.limitAmountInAED)),
          Text(ProjectContractNumericHelper.safeText(data?.currentOSInAED)),
        ];
      }),
    );
  }
}
