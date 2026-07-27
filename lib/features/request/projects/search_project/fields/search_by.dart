import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";
import "package:wcas_frontend/features/request/projects/search_project/state.dart";

/// Search by radio button section for the search project screen.
class SearchBy extends StatelessWidget {
  /// Creates a search by section.
  const SearchBy({required this.viewModel, required this.state, super.key});

  /// Search project view model.
  final SearchProjectViewModel viewModel;

  /// Search project state.
  final SearchProjectState state;

  @override
  Widget build(BuildContext context) {
    // final bool isValid = viewModel.canEdit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "project.searchProject.searchBy".tr(),
          isRequired: true,
          child: CustomRadioButton<SearchByOption>(
            // isEnabled: isValid,
            options: viewModel.searchByItems,
            selectedValue: viewModel.selectedSearchByValue,
            onChanged: viewModel.onChangedSearchByValue,
            itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
                Text(
              "${item.name[0].toUpperCase()}${item.name.substring(1)}",
            ),
            isRequired: true,
            scrollDirection: Axis.horizontal,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
