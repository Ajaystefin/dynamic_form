import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";

/// Displays the user's designation field in read-only mode.
class UserDesignation extends StatelessWidget {
  /// Creates a [UserDesignation] widget.
  const UserDesignation({required this.viewModel, super.key});

  /// View model used to access and update user designation details.
  final UserDetailViewModel viewModel;

  /// Builds the designation field.
  @override
  Widget build(BuildContext context) {
    final designation = viewModel.userDetails?.designation?.toString();
    final bool hasData = designation?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.designation".tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: "admin.userManagementDetail.designation".tr(),
            controller: TextEditingController(text: designation),
            readOnly: true,
            filled: true,
            fillColor: AppColors.textFieldDisabledFill,
            validator: hasData ? null : CustomValidator.requiredField,
            onSaved: (String? value) {
              if (viewModel.userDetails != null) {
                viewModel.userDetails!.designation = value;
              }
            },
          ),
        ),
      ],
    );
  }
}
