import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";
import "package:wcas_frontend/features/request/projects/search_project/widgets/textfield_with_button.dart";

class CustomSearchByField extends StatelessWidget {
  const CustomSearchByField({required this.viewModel, super.key});
  final SearchProjectViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    // final bool isValid = viewModel.canEdit;
    return TextfieldWithButton(
      isRequired: true,
      showLabel: true,
      // filled: !isValid,
      // readOnly: !isValid,
      validator: CustomValidator.requiredField,
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
