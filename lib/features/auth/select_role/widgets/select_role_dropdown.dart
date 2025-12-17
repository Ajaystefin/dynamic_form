import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/auth/select_role/model.dart';
import 'package:wcas_frontend/features/auth/select_role/state.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/globals.dart';

class SelectRoleDropdown extends StatelessWidget {
  final SelectRoleViewModel viewModel;
  final SelectRoleState state;
  final double? width;
  const SelectRoleDropdown(
      {super.key, required this.viewModel, required this.state, this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        spacing: 60,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          Text(
            "  ${"auth.selectRole.welcomeTitle".tr()}${Globals.user?.name?.toUpperCase()}",
            style: const TextStyle(
              fontSize: AppStyle.fontSizeLarge,
              color: AppColors.accordionPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          CustomDropdown<Role>(
            showHoverColor: true,
            hoverColor: AppColors.primary,
            width: width ?? 220.w,
            semanticLabel: 'auth.selectRole.selectRole'.tr(),
            maxDropdownHeight: context.isMobile ? 100 : null,
            hintText: 'auth.selectRole.selectRole'.tr(),
            selectedItems: viewModel.userRole == null
                ? [Role(name: 'auth.selectRole.selectRole'.tr())]
                : [viewModel.userRole],
            onSelected: (selectedValue) {
              viewModel.userRole = selectedValue.first;
            },
            items: Globals.user?.availableRoles,
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: viewModel.errorMessage == null
                    ? AppColors.textFieldBorder
                    : AppColors.failure,
              ),
            ),
            dropdownBuilder: (context, item) => Padding(
              padding: EdgeInsets.only(left: 10.w, top: 10.w),
              child: Text(
                item?.name ?? "",
                style: const TextStyle(
                  color: AppColors.accordionPrimary,
                  fontSize: AppStyle.fontSizeMedium,
                ),
              ),
            ),
            dropdownSuffixProps: const DropdownSuffixProps(
              dropdownButtonProps: DropdownButtonProps(
                color: AppColors.accordionPrimary,
              ),
            ),
            itemBuilder: (context, item, isDisabled, isSelected) => Ink(
              color: isSelected ? AppColors.primary : AppColors.darkBlue,
              padding: const EdgeInsets.symmetric(
                vertical: AppStyle.spacingSmall,
                horizontal: AppStyle.spacingSmall,
              ),
              child: Text(
                item.name ?? "",
                style: const TextStyle(
                  color: AppColors.accordionPrimary,
                  fontSize: AppStyle.fontSizeMedium,
                ),
              ),
            ),
          ),
          Semantics(
            label: 'common.submit'.tr(),
            button: true,
            child: CustomButton(
              width: width ?? 220.w,
              label: 'common.submit'.tr(),
              textColor: AppColors.black,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.bold).copyWith(),
              onPressed: () {
                viewModel.selectRole();
              },
              isLoading: state.selectRoleStatus == LoadingStatus.loading,
              backgroundColor: AppColors.secondary,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }
}
