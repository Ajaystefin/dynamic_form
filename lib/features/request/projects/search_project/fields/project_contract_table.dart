import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";
import "package:wcas_frontend/models/request/project/project.dart";

class ProjectContractTable extends StatelessWidget {
  const ProjectContractTable({required this.viewModel, super.key});
  final SearchProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Build rows depending on search context
    final List<List<Widget>> rows = _getRows(
      selectedSearchByValue: viewModel.selectedSearchByValue,
      projects: viewModel.projects ?? [],
      contracts: viewModel.contracts ?? [],
    );

    final bool hasResults = rows.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        // Table
        CustomRawTable(
          columns: [
            TableColumn(label: Text("project.searchProject.projectCode".tr())),
            TableColumn(label: Text("project.searchProject.projectName".tr())),
            TableColumn(label: Text("project.searchProject.action".tr())),
          ],
          rows: rows,
        ),

        // No results message (below the table)
        if (!hasResults)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "common.emptyState".tr(), // "No records found"
              semanticsLabel: "common.emptyState".tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  List<List<Widget>> _getRows({
    required SearchByOption selectedSearchByValue,
    required List<Project> projects,
    required List<Project> contracts,
  }) {
    switch (selectedSearchByValue) {
      case SearchByOption.project:
        return _getProjectRows(projects);
      case SearchByOption.contract:
        return _getContractRows(contracts);
    }
  }

  // Rows for Project search: [Project Code, Project Name, Action(View)]
  List<List<Widget>> _getProjectRows(List<Project> projects) {
    return projects.map((project) {
      final code = project.projectCode ?? "";
      final name = project.projectName ?? "";

      return [
        Text(code),
        Text(name),
        TextButton(
          onPressed: () {
            viewModel.onPressedProjectView(
              project: project,
            ); // pass project if needed
          },
          child: Text(
            "project.searchProject.view".tr(),
            semanticsLabel: "project.searchProject.view".tr(),
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
          ),
        ),
      ];
    }).toList();
  }

  // Rows for Contract search: still show [Project Code, Project Name,
  // Action(View)]
  List<List<Widget>> _getContractRows(List<Project> contracts) {
    return contracts.map((contract) {
      final projectCode = contract.projectCode ?? "";
      final projectName = contract.projectName ?? "";

      return [
        Text(projectCode),
        Text(projectName),
        TextButton(
          onPressed: () {
            viewModel.onPressedContractView(
              contract: contract,
            ); // navigate to linked project details
          },
          child: Text(
            "project.searchProject.view".tr(),
            semanticsLabel: "project.searchProject.view".tr(),
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkBlue,
            ),
          ),
        ),
      ];
    }).toList();
  }
}
