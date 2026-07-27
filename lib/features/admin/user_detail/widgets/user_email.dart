import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
// import 'package:wcas_frontend/core/utils/validators.dart';
import "package:wcas_frontend/features/admin/user_detail/model.dart";

/// Displays the user's email field in read-only mode.
class UserEmail extends StatelessWidget {
  /// Creates a [UserEmail] widget.
  const UserEmail({required this.viewModel, super.key});

  /// View model used to access and update user email details.
  final UserDetailViewModel viewModel;

  /// Builds the email field.
  @override
  Widget build(BuildContext context) {
    // final bool hasData = viewModel.userDetails?.email?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.email".tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomTextField(
            semanticLabel: "admin.userManagementDetail.email".tr(),
            controller:
                TextEditingController(text: viewModel.userDetails?.email),
            readOnly: true,
            filled: true,
            fillColor: AppColors.accordionSecondary,
            // validator: hasData ? null : CustomValidator,
            onSaved: (String? value) {
              viewModel.userDetails?.email = value;
            },
          ),
        ),
      ],
    );
  }
}
