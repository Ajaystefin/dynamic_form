import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";

/// Displays the user's ID field in read-only mode.
class UserId extends StatelessWidget {
  /// Creates a [UserId] widget.
  const UserId({required this.viewModel, super.key});

  /// View model used to access and update user ID details.
  final UserDetailViewModel viewModel;

  /// Builds the user ID field.
  @override
  Widget build(BuildContext context) {
    final userId = viewModel.userDetails?.id;
    final bool hasData = userId?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.userId".tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: "admin.userManagementDetail.userId".tr(),
            controller: TextEditingController(text: userId),
            readOnly: true,
            filled: true,
            fillColor: AppColors.textFieldDisabledFill,
            validator: hasData ? null : CustomValidator.requiredField,
            onSaved: (String? value) {
              if (viewModel.userDetails != null) {
                viewModel.userDetails!.id = value;
              }
            },
          ),
        ),
      ],
    );
  }
}
