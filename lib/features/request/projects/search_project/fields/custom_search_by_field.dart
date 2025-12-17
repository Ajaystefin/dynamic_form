import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/search_project/model.dart';
import 'package:wcas_frontend/features/request/projects/search_project/widgets/textfield_with_button.dart';

class CustomSearchByField extends StatelessWidget {
  const CustomSearchByField({super.key, required this.viewModel});
  final SearchProjectViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      isRequired: true,
      showLabel: true,
      validator: CustomValidator.requiredField,
      isLoading: viewModel.customerRimNoLoadingStatus == LoadingStatus.loading,
      value: viewModel.customerRimNo ?? '',
      viewModel: viewModel,
      label: viewModel.searchCriteriaValue?.name ?? '',
      onSaved: (value) {
        viewModel.customerRimNo = value;
      },
      hintText:
          '${'project.searchProject.pleaseEnter'.tr()} ${viewModel.searchCriteriaValue?.name}',
      showbuttonLabel: false,
      buttonLabel: "project.searchProject.search".tr(),
      buttonOnPressed: viewModel.onCustomerRimNoSearchPressed,
      onSubmit: (value) => viewModel.onCustomerRimNoSearchPressed,
    );
  }
}
