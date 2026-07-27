import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";

/// Displays the user's department field in read-only mode.
class UserDepartment extends StatelessWidget {
  /// Creates a [UserDepartment] widget.
  const UserDepartment({required this.viewModel, super.key});

  /// View model used to access and update user department details.
  final UserDetailViewModel viewModel;

  /// Builds the department field.
  @override
  Widget build(BuildContext context) {
    final department = viewModel.userDetails?.department?.toString();
    final bool hasData = department?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.department".tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: "admin.userManagementDetail.department".tr(),
            controller: TextEditingController(text: department),
            readOnly: true,
            filled: true,
            fillColor: AppColors.textFieldDisabledFill,
            validator: hasData ? null : CustomValidator.requiredField,
            onSaved: (String? value) {
              if (viewModel.userDetails != null) {
                viewModel.userDetails!.department = value;
              }
            },
          ),
        ),
      ],
    );
  }
}
