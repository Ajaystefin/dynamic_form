import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';

class BarGraphFilter extends StatelessWidget {
  final HomeViewModel viewModel;
  final DashboardAgeingType selectedGraphFilter;
  const BarGraphFilter(this.viewModel,
      {required this.selectedGraphFilter, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => viewModel.onSelectGraphFilter(selectedGraphFilter),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: viewModel.selectedGraphFilter == selectedGraphFilter
                ? BorderRadius.circular(8)
                : null,
            color: viewModel.selectedGraphFilter == selectedGraphFilter
                ? AppColors.primary
                : null),
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.spacing),
          child: Text(
            dashboardFilterMapToUI[selectedGraphFilter] ?? "",
            style: TextStyle(
                color: viewModel.selectedGraphFilter == selectedGraphFilter
                    ? AppColors.white
                    : null),
          ),
        ),
      ),
    );
  }
}
