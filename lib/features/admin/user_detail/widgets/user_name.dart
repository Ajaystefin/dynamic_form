import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";

/// Displays the user's name field in read-only mode.
class UserName extends StatelessWidget {
  /// Creates a [UserName] widget.
  const UserName({required this.viewModel, super.key});

  /// View model used to access and update user name details.
  final UserDetailViewModel viewModel;

  /// Builds the user name field.
  @override
  Widget build(BuildContext context) {
    final bool hasData = viewModel.userDetails?.name?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.userName".tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: "admin.userManagementDetail.userName".tr(),
            controller:
                TextEditingController(text: viewModel.userDetails?.name),
            readOnly: true,
            filled: true,
            fillColor: AppColors.textFieldDisabledFill,
            validator: hasData ? null : CustomValidator.requiredField,
            onSaved: (String? value) {
              viewModel.userDetails?.name = value;
            },
          ),
        ),
      ],
    );
  }
}
