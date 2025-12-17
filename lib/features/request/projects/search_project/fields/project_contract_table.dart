import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/projects/search_project/model.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';
import 'package:wcas_frontend/models/request/project/project.dart';

class ProjectContractTable extends StatelessWidget {
  const ProjectContractTable({super.key, required this.viewModel});
  final SearchProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    List<TableColumn> getColumns = [
      ...(viewModel.searchCriteriaItems?.map((ref) {
            return TableColumn(label: Text(ref.name ?? ''));
          }).toList() ??
          []),
      const TableColumn(label: Text('Action')), // Add your custom label here
    ];

    List<List<Widget>> getRows({
      required SearchByOption selectedSearchByValue,
      required List<Project> projects,
      required List<Contract> contracts,
    }) {
      switch (selectedSearchByValue) {
        case SearchByOption.project:
          return getProjectRows(projects);
        case SearchByOption.contract:
          return getContractRows(contracts);
      }
    }

    return Column(
      spacing: 10,
      children: [
        CustomRawTable(
          columns: getColumns,
          rows: getRows(
              selectedSearchByValue: viewModel.selectedSearchByValue,
              projects: viewModel.projects ?? [],
              contracts: viewModel.contracts ?? []),
        )
      ],
    );
  }

  List<List<Widget>> getProjectRows(List<Project> projects) {
    return projects
        .map((project) => [
              Text(project.code ?? ''),
              Text(project.name ?? ''),
              Text(project.ultimateOwner ?? ''),
              Text(project.ownerEntity ?? ''),
              Text(project.ownerRim.toString()),
              Text(project.ownerEntityRim.toString()),
              Text(project.contract?.first.contractName ?? ''),
              Text("${project.contract?.first.rimNo}"),
              TextButton(
                onPressed: () {
                  viewModel.onPressedProjectView();
                },
                child: Text(
                  'project.searchProject.view'.tr(),
                  semanticsLabel: 'project.searchProject.view'.tr(),
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkBlue,
                  ),
                ),
              ),
            ])
        .toList();
  }

  List<List<Widget>> getContractRows(List<Contract> contracts) {
    return contracts
        .map((contract) => [
              Text(contract.contractCode.toString()),
              Text(contract.projectName ?? ''),
              Text(contract.projectUltimateOwner ?? ''),
              Text(contract.projectOwnerEntity ?? ''),
              Text(contract.contractName?.toString() ?? ''),
              Text("${contract.rimNo}"),
              TextButton(
                onPressed: () {
                  viewModel.onPressedContractView();
                },
                child: Text(
                  'project.searchProject.view'.tr(),
                  semanticsLabel: 'project.searchProject.view'.tr(),
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkBlue,
                  ),
                ),
              ),
            ])
        .toList();
  }
}
