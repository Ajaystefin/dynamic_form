import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";

/// Displays the roles assigned to the user.
class UserRoles extends StatelessWidget {
  /// Creates a [UserRoles] widget.
  const UserRoles({required this.viewModel, super.key});

  /// View model used to access user role details.
  final UserDetailViewModel viewModel;

  /// Builds the user roles display field.
  @override
  Widget build(BuildContext context) {
    final roles = viewModel.userDetails?.availableRoles ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.roles".tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.textFieldBorder),
            ),
            child: roles.isEmpty
                ? const Text("—", style: TextStyle(fontSize: 12))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: roles
                        .map(
                          (role) => Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accordionSecondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SelectableText(
                              role.code ?? "",
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
