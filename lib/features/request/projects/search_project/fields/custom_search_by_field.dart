import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";
import "package:wcas_frontend/features/request/projects/search_project/widgets/textfield_with_button.dart";

/// Custom search input field with an attached search button.
///
/// This widget is used on the Search Project screen to render a dynamic search
/// field based on the selected search criteria.
class CustomSearchByField extends StatelessWidget {
  /// Creates a custom search-by field.
  const CustomSearchByField({required this.viewModel, super.key});

  /// Search project view model.
  final SearchProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool isValid = viewModel.canEdit;
    return TextfieldWithButton(
      isRequired: true,
      // filled: !isValid,
      // readOnly: !isValid,
      validator: CustomValidator.requiredField,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(
            viewModel.searchCriteriaValue?.reference4 ?? "[a-zA-Z0-9 ]",
          ),
        ),
      ],
      isLoading: viewModel.customerRimNoLoadingStatus == LoadingStatus.loading,
      value: viewModel.dropDownFeildText ?? "",
      controller: viewModel.controllerDropDownFeildText,
      viewModel: viewModel,
      label: viewModel.searchCriteriaValue?.name ?? "",
      maxLength: int.tryParse(
        viewModel.searchCriteriaValue?.reference3.toString() ?? "50",
      ),
      onSaved: (value) {
        viewModel.dropDownFeildText = value;
      },
      hintText: '${'project.searchProject.pleaseEnter'.tr()} '
          "${viewModel.searchCriteriaValue?.name}",
      showbuttonLabel: false,
      buttonLabel: "project.searchProject.search".tr(),
      buttonOnPressed: viewModel.onCustomerRimNoSearchPressed,
      onSubmit: (value) => viewModel.onSubmitPressed(context),
    );
  }
}
