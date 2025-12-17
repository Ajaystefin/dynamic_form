import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/features/request/projects/search_project/model.dart';
import 'package:wcas_frontend/features/request/projects/search_project/state.dart';

class SearchBy extends StatelessWidget {
  final SearchProjectViewModel viewModel;
  final SearchProjectState state;
  const SearchBy({super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LabelWidget(
          label: 'project.searchProject.searchBy'.tr(),
          isRequired: false,
          showLabel: true,
          child: CustomRadioButton<SearchByOption>(
            options: viewModel.searchByItems,
            selectedValue: viewModel.selectedSearchByValue,
            onChanged: viewModel.onChangedSearchByValue,
            itemBuilder: (context, item, isSelected, isEnabled) => Text(
              '${item.name[0].toUpperCase()}${item.name.substring(1)}',
            ),
            isRequired: true,
            scrollDirection: Axis.horizontal,
            textStyle: const TextStyle(fontSize: 12),
          ))
    ]);
  }
}
