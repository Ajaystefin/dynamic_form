import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";
import "package:wcas_frontend/features/admin/user_detail/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class UserIslamicRelationship extends StatelessWidget {
  const UserIslamicRelationship({required this.viewModel, super.key});
  final UserDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDetailViewModel, UserDetailState>(
      builder: (context, state) {
        return LabelWidget(
          label: "admin.userManagementList.islamicRelationshipUser".tr(),
          isRequired: true,
          showLabel: true,
          child: CustomRadioButton<Reference>(
            //isEnabled: viewModel.canEdit,
            itemBuilder: (context, item, isSelected, isEnabled) =>
                Text(item.name ?? ""),
            options: viewModel
                .getFilteredOptions(viewModel.islamicRelationshipUserOptions),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.islamicRelationshipUserOptions,
              selectedValue: viewModel.selectedIslamicRelationshipUserValue,
              fallbackFlag: viewModel.userDetails?.isIslamic,
            ),
            validator: (value) {
              return viewModel.validateSelection(
                value?.name,
                viewModel.getFilteredOptions(
                  viewModel.islamicRelationshipUserOptions,
                ),
                "admin.userManagementList.selectIslamicRelationshipUser".tr(),
              );
            },
            onChanged: (selectedRef) {
              viewModel.islamicRelationshipUserSelected(selectedRef);
            },
            selectedColor: AppColors.primary,
            unselectedColor: Colors.grey,
            scrollDirection: Axis.horizontal,
          ),
        );
      },
    );
  }
}
