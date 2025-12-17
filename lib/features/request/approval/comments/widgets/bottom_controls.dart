import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/flexbox.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/comments/model.dart';
import 'package:wcas_frontend/features/request/approval/comments/widgets/user_selection_button_dropdown.dart';
import 'package:wcas_frontend/features/request/approval/list_output_forms_dialog/view.dart';

class BottomControls extends StatelessWidget {
  final CommentsViewModel viewModel;
  final BuildContext context;

  const BottomControls({
    super.key,
    required this.viewModel,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final userList = [
      CustomDropdownItem(value: "User 1", onPressed: () {}),
      CustomDropdownItem(value: "User 2", onPressed: () {}),
      CustomDropdownItem(value: "User 3", onPressed: () {}),
    ];

    return FlexBox(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRAROC]
                ?.call() ??
            false)
          CustomButton(
            label: "approval.comments.amendRAROC".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]?.call() ??
            false)
          Column(
            children: [
              Text("approval.comments.return".tr()),
              CustomRadioButton(
                isRequired: true,
                options: viewModel.returnOpts,
                scrollDirection: Axis.horizontal,
                selectedValue: viewModel.returnOptSelected,
                selectedColor: AppColors.primary,
                unselectedColor: Colors.grey,
                onChanged: (value) {
                  viewModel.onReturnOptChanged(value);
                },
              ),
            ],
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.amendFacilities]
                ?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.amendFacilities".tr(),
            label: "approval.comments.amendFacilities".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.amendSecurities]
                ?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.amendSecurities".tr(),
            label: "approval.comments.amendSecurities".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]
                ?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.amendCovenants".tr(),
            label: "approval.comments.amendCovenants".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.amendConditions]
                ?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.amendConditions".tr(),
            label: "approval.comments.amendConditions".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[
                    ApprovalFields.amendFacilitySecurityLinkage]
                ?.call() ??
            false)
          CustomButton(
            semanticLabel:
                "approval.comments.amendFacilitySecurityLinkage".tr(),
            label: "approval.comments.amendFacilitySecurityLinkage".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRiskRating]
                ?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.amendRiskRating".tr(),
            label: "approval.comments.amendRiskRating".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.approve]?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.approve".tr(),
            label: "approval.comments.approve".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.recommend]
                ?.call() ??
            false)
          RecommendationDropdown(
            options: userList,
            label: "approval.comments.recommend".tr(),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.approveonbehalf]
                ?.call() ??
            false)
          RecommendationDropdown(
            options: userList,
            label: "approval.comments.approveOnBehalfOf".tr(),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.approvalDelegation]
                ?.call() ??
            false)
          Column(
            children: [
              Text("approval.comments.approvalDelegation".tr(),
                  semanticsLabel: "approval.comments.approvalDelegation".tr()),
              CustomDropdown<String>(
                width: 200,
                semanticLabel: "approval.comments.approvalDelegation".tr(),
                hintText: "approval.comments.approvalDelegation".tr(),
                items: viewModel.approvalDelegationList,
              ),
            ],
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.decline]?.call() ??
            false)
          CustomButton(
            label: "approval.comments.decline".tr(),
            semanticLabel: "approval.comments.decline".tr(),
            onPressed: () => viewModel.onSavePress(isContinue: true),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.reasonForDecline]
                ?.call() ??
            false)
          Column(
            children: [
              Text("approval.comments.reasonForDecline".tr(),
                  semanticsLabel: "approval.comments.reasonForDecline".tr()),
              CustomDropdown<String>(
                width: 200,
                semanticLabel: "approval.comments.reasonForDecline".tr(),
                hintText: "approval.comments.reasonForDecline".tr(),
                items: viewModel.reasonForDecline,
              ),
            ],
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.generatePack]
                ?.call() ??
            false)
          CustomButton(
            label: "approval.comments.generatePack".tr(),
            semanticLabel: "approval.comments.generatePack".tr(),
            onPressed: () {
              DialogHelper.showCustomDialog(
                barrierDismissible: true,
                width: 350.w,
                onClosePressed: () => Navigator.pop(context),
                title: "approval.listOutputForms.title".tr(),
                content: const ListOutputFormsDialogView(),
                context: context,
              );
            },
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.closeApplication]
                ?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.closeApplication".tr(),
            label: "approval.comments.closeApplication".tr(),
            onPressed: () {},
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.noReturn]?.call() ??
            false)
          CustomButton(
            semanticLabel: "approval.comments.noReturn".tr(),
            label: "approval.comments.noReturn".tr(),
            onPressed: () {},
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.previewApplication]
                ?.call() ??
            false)
          CustomButton(
            label: "approval.comments.previewApplication".tr(),
            semanticLabel: "approval.comments.previewApplication".tr(),
            onPressed: () {
              DialogHelper.showCustomDialog(
                width: 350.w,
                barrierDismissible: true,
                title: "approval.comments.previewApplication".tr(),
                content: const ListOutputFormsDialogView(),
                context: context,
              );
            },
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.save]?.call() ??
            false)
          CustomButton(
            semanticLabel: "common.save".tr(),
            label: "common.save".tr(),
            onPressed: () => viewModel.onSavePress(),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.saveAndContinue]?.call() ??
            false)
        CustomButton(
          semanticLabel: "common.saveAndContinue".tr(),
          label: "common.saveAndContinue".tr(),
          onPressed: () => viewModel.onSavePress(isContinue: true),
        ),
      ],
    );
  }
}
