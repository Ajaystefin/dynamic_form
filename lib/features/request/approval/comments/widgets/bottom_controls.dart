import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/flexbox.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/comments/model.dart";
import "package:wcas_frontend/features/request/approval/comments/widgets/button_dropdown.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/view.dart";

class BottomControls extends StatelessWidget {
  const BottomControls({
    required this.viewModel,
    required this.context,
    super.key,
    this.canSubmit = true,
  });
  final CommentsViewModel viewModel;
  final BuildContext context;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();
    bool isValid = true;
    Future<void> submitApplication(UserAction userAction) async {
      final List<UserAction> rsaActions = [
        // show rsa popup on useractions
        UserAction.declined,
        UserAction.approved,
        UserAction.approveOnBehalfOf,
      ];
      final List<UserAction> aedActions = [
        // show AED popup on useractions
        UserAction.recommended,
        UserAction.approved,
        UserAction.approveOnBehalfOf,
      ];
      if (viewModel.initialText.isEmpty) {
        AlertManager().showFailureToast(
          "approval.creditAssessment.pleaseEnterRemarks".tr(),
        );
        return;
      }
      if (viewModel.recommendPrefill != null &&
          userAction == UserAction.recommended &&
          !viewModel.isRecommendSelected) {
        viewModel.selectedUserId = viewModel.recommendPrefill?.value;
        debugPrint("selectedUserId recommend: ${viewModel.selectedUserId}");
      } else if (viewModel.returnPrefill != null &&
          userAction == UserAction.returned &&
          !viewModel.isReturnSelected) {
        viewModel.selectedUserId = viewModel.returnPrefill?.value;
        debugPrint("selectedUserId return: ${viewModel.selectedUserId}");
      }
      final List<String> selectedValue = viewModel.selectedUserId.split(":");
      final String selectedUserId = selectedValue.first;

      if (selectedUserId.isEmpty &&
          [
            UserAction.recommended,
            UserAction.approveOnBehalfOf,
            UserAction.returned,
          ].contains(userAction)) {
        AlertManager().showFailureToast(
          "approval.comments.selectUserbeforeSubmit".tr(),
        );
        return;
      }
      if ([UserAction.approved, UserAction.approveOnBehalfOf]
          .contains(userAction)) {
        if (viewModel.selectedDelegation.isEmpty) {
          AlertManager().showFailureToast(
            "approval.comments.selectDelegationbeforeSubmit".tr(),
          );
          return;
        }
      }
      if (UserAction.declined == userAction) {
        if (viewModel.selectedReason.isEmpty) {
          AlertManager().showFailureToast(
            "approval.comments.selectReasonbeforeSubmit".tr(),
          );
          return;
        }
      }
      if (aedActions.contains(userAction)) {
        final String? errorDescription =
            await viewModel.validateApproval(userAction);
        final List<String> description =
            errorDescription?.split(RegExp(r"\s*;\s*")) ?? [];
        if (description.isNotEmpty && context.mounted) {
          final bool value = await showAEDWarningDialog(context, description);
          if (!value) {
            return;
          }
        }
      }
      if (rsaActions.contains(userAction) &&
          context.mounted &&
          viewModel.isRSAEnabled) {
        isValid = await showRsaDialog(context);
      }
      if (isValid) {
        final List<String> result =
            await viewModel.submitApplication(userAction);
        if (result.isNotEmpty) {
          if (context.mounted &&
              result.first == "layout.topmenu.comfirmation".tr()) {
            await layoutViewModel.showConfirmationDialog(context, result.last);
          } else if (context.mounted) {
            await layoutViewModel.showWarningDialog(context, result);
          }
        }
      } else {
        AlertManager().showFailureToast("approval.comments.failedToAuth".tr());
      }
    }

    return FlexBox(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (viewModel.buttonVisibilityStatus[ApprovalFields.previewApplication]
                ?.call() ??
            false)
          CustomButton(
            label: "approval.comments.previewApplication".tr(),
            semanticLabel: "approval.comments.previewApplication".tr(),
            onPressed: () {
              // viewModel.downloadOutputForm();
              DialogHelper.showCustomDialog(
                width: 350.w,
                barrierDismissible: true,
                title: "approval.comments.previewApplication".tr(),
                content: const ListOutputFormsDialogView(),
                context: context,
              );
            },
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
        if (!viewModel.isReadOnly) ...[
          // start for OneOffLimit
          if (viewModel.isOneOffLimit &&
              viewModel.businessUnitHead
                  .contains(Globals.user?.currentRole?.roleId)) ...[
            if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!
                    .call() &&
                !viewModel.isInitByUser &&
                viewModel.isOneOffLimit)
              CustomDropdownMenuButton(
                key: ValueKey("limit_${viewModel.returnPrefill?.value}"),
                label: "approval.comments.return".tr(),
                initialOption: viewModel.returnPrefill,
                options:
                    viewModel.getUserListDropDownItems(viewModel.returnUserMap),
                showValueWithLabel: true,
                callBack: (userId) {
                  viewModel.isReturnSelected = true;
                  viewModel.selectedUserId = userId;
                },
                onButtonPressed: () => submitApplication(UserAction.returned),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.approve]!
                    .call() &&
                Globals.checkCurrentStatus(
                  [RequestStatus.pendingForApproval],
                ) &&
                viewModel.isApproveButtonVisible)
              CustomButton(
                semanticLabel: "approval.comments.approve".tr(),
                label: "approval.comments.approve".tr(),
                onPressed: () => submitApplication(UserAction.approved),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.approveonbehalf]!
                    .call() &&
                Globals.checkCurrentStatus(
                  [RequestStatus.pendingForApproval],
                ) &&
                viewModel.isApproveOnBehalfButtonVisible)
              CustomDropdownMenuButton(
                label: "approval.comments.approveOnBehalfOf".tr(),
                options: viewModel
                    .getUserListDropDownItems(viewModel.approveUserMap),
                showValueWithLabel: true,
                callBack: (userId) {
                  viewModel.selectedUserId = userId;
                },
                onButtonPressed: () =>
                    submitApplication(UserAction.approveOnBehalfOf),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.approvalDelegation]!
                    .call() &&
                viewModel.isApproveDelegationButtonVisible)
              Column(
                children: [
                  Text(
                    "approval.comments.approvalDelegation".tr(),
                    semanticsLabel: "approval.comments.approvalDelegation".tr(),
                  ),
                  CustomDropdown<String>(
                    width: 200,
                    semanticLabel: "approval.comments.approvalDelegation".tr(),
                    hintText: "approval.comments.approvalDelegation".tr(),
                    items: viewModel.approvalDelegationList,
                    onSelected: (selectedValue) {
                      viewModel.selectedDelegation = selectedValue.first;
                    },
                    onClear: (selectedValue) {
                      viewModel.selectedDelegation = "";
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return dropdownItemBuildWidget(
                        item,
                        isListTile: true,
                        isSelected: isSelected,
                      );
                    },
                    dropdownBuilder: (context, data) {
                      return Text(
                        data ?? "",
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                ],
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.decline]!
                    .call() &&
                Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
              CustomButton(
                label: "approval.comments.decline".tr(),
                semanticLabel: "approval.comments.decline".tr(),
                onPressed: () => submitApplication(UserAction.declined),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.reasonForDecline]!
                    .call() &&
                Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
              Column(
                children: [
                  Text(
                    "approval.comments.reasonForDecline".tr(),
                    semanticsLabel: "approval.comments.reasonForDecline".tr(),
                  ),
                  CustomDropdown<String>(
                    width: 200,
                    semanticLabel: "approval.comments.reasonForDecline".tr(),
                    hintText: "approval.comments.reasonForDecline".tr(),
                    items: Globals.reasonForDecline,
                    onSelected: (selectedValue) {
                      viewModel.selectedReason = selectedValue.first;
                    },
                    onClear: (selectedValue) {
                      viewModel.selectedReason = "";
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return dropdownItemBuildWidget(
                        item,
                        isListTile: true,
                        isSelected: isSelected,
                      );
                    },
                    dropdownBuilder: (context, data) {
                      return Text(
                        data ?? "",
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                ],
              ),
          ],
          // end for OneOffLimit

          // for proxy approval roles
          if (viewModel.proxyApprovalList
              .contains(Globals.user?.currentRole?.roleId)) ...[
            if (viewModel.buttonVisibilityStatus[ApprovalFields.approve]!
                    .call() &&
                viewModel.isApproveButtonVisible)
              CustomButton(
                semanticLabel: "approval.comments.approve".tr(),
                label: "approval.comments.approve".tr(),
                onPressed: () => submitApplication(UserAction.approved),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.approvalDelegation]!
                    .call() &&
                viewModel.isApproveDelegationButtonVisible)
              Column(
                children: [
                  Text(
                    "approval.comments.approvalDelegation".tr(),
                    semanticsLabel: "approval.comments.approvalDelegation".tr(),
                  ),
                  CustomDropdown<String>(
                    width: 200,
                    semanticLabel: "approval.comments.approvalDelegation".tr(),
                    hintText: "approval.comments.approvalDelegation".tr(),
                    items: viewModel.approvalDelegationList,
                    onSelected: (selectedValue) {
                      viewModel.selectedDelegation = selectedValue.first;
                    },
                    onClear: (selectedValue) {
                      viewModel.selectedDelegation = "";
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return dropdownItemBuildWidget(
                        item,
                        isListTile: true,
                        isSelected: isSelected,
                      );
                    },
                    dropdownBuilder: (context, data) {
                      return Text(
                        data ?? "",
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                ],
              ),
          ],

          // for segment head roles
          if (viewModel.segmentHeadList
              .contains(Globals.user?.currentRole?.roleId)) ...[
            if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!
                    .call() &&
                !viewModel.isInitByUser)
              CustomDropdownMenuButton(
                key: ValueKey("sh_${viewModel.returnPrefill?.value}"),
                label: "approval.comments.return".tr(),
                initialOption: viewModel.returnPrefill,
                options:
                    viewModel.getUserListDropDownItems(viewModel.returnUserMap),
                showValueWithLabel: true,
                callBack: (userId) {
                  viewModel.isReturnSelected = true;
                  viewModel.selectedUserId = userId;
                },
                onButtonPressed: () => submitApplication(UserAction.returned),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.approve]!
                    .call() &&
                Globals.checkCurrentStatus(
                  [RequestStatus.pendingForApproval],
                ) &&
                viewModel.isApproveButtonVisible)
              CustomButton(
                semanticLabel: "approval.comments.approve".tr(),
                label: "approval.comments.approve".tr(),
                onPressed: () => submitApplication(UserAction.approved),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.approveonbehalf]!
                    .call() &&
                Globals.checkCurrentStatus(
                  [RequestStatus.pendingForApproval],
                ) &&
                viewModel.isApproveOnBehalfButtonVisible)
              CustomDropdownMenuButton(
                label: "approval.comments.approveOnBehalfOf".tr(),
                options: viewModel
                    .getUserListDropDownItems(viewModel.approveUserMap),
                showValueWithLabel: true,
                callBack: (userId) {
                  viewModel.selectedUserId = userId;
                },
                onButtonPressed: () =>
                    submitApplication(UserAction.approveOnBehalfOf),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.approvalDelegation]!
                    .call() &&
                viewModel.isApproveDelegationButtonVisible)
              Column(
                children: [
                  Text(
                    "approval.comments.approvalDelegation".tr(),
                    semanticsLabel: "approval.comments.approvalDelegation".tr(),
                  ),
                  CustomDropdown<String>(
                    width: 200,
                    semanticLabel: "approval.comments.approvalDelegation".tr(),
                    hintText: "approval.comments.approvalDelegation".tr(),
                    items: viewModel.approvalDelegationList,
                    onSelected: (selectedValue) {
                      viewModel.selectedDelegation = selectedValue.first;
                    },
                    onClear: (selectedValue) {
                      viewModel.selectedDelegation = "";
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return dropdownItemBuildWidget(
                        item,
                        isListTile: true,
                        isSelected: isSelected,
                      );
                    },
                    dropdownBuilder: (context, data) {
                      return Text(
                        data ?? "",
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                ],
              ),
          ],

          // for Credit Analyst
          if (Utils.checkRole(UserRole.creditAnalyst)) ...[
            if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!
                    .call() &&
                !viewModel.isInitByUser &&
                viewModel.isRMselected)
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
            if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!
                        .call() &&
                    !viewModel.isInitByUser // new added
                )
              CustomDropdownMenuButton(
                key: ValueKey("ca_${viewModel.returnPrefill?.value}"),
                label: "approval.comments.return".tr(),
                initialOption: viewModel.returnPrefill,
                options:
                    viewModel.getUserListDropDownItems(viewModel.returnUserMap),
                showValueWithLabel: true,
                callBack: (userId) {
                  viewModel.isReturnSelected = true;
                  viewModel.selectedUserId = userId;
                  final String role = userId.split(":").last;
                  viewModel.setSelectedUser(role);
                },
                onButtonPressed: () => submitApplication(UserAction.returned),
              ),
          ],

          if (!viewModel.isRiskRatingInit &&
              Utils.checkRole(UserRole.creditAnalyst)) ...[
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRAROC]!
                    .call() &&
                !viewModel.rarocAmendAppType
                    .contains(Globals.request?.applicationType?.reference1))
              CustomButton(
                label: "approval.comments.amendRAROC".tr(),
                onPressed: () => router.go(
                  Routes.relationshipProfitabilitySummary,
                  extra: PageMode.edit,
                ),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendFacilities]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendFacilities".tr(),
                label: "approval.comments.amendFacilities".tr(),
                onPressed: () =>
                    router.go(Routes.facilitySummaryView, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendSecurities]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendSecurities".tr(),
                label: "approval.comments.amendSecurities".tr(),
                onPressed: () =>
                    router.go(Routes.securitySummaryView, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendCovenants".tr(),
                label: "approval.comments.amendCovenants".tr(),
                onPressed: () =>
                    router.go(Routes.covenantsSummary, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendConditions]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendConditions".tr(),
                label: "approval.comments.amendConditions".tr(),
                onPressed: () =>
                    router.go(Routes.conditionsSummary, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[
                        ApprovalFields.amendFacilitySecurityLinkage]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel:
                    "approval.comments.amendFacilitySecurityLinkage".tr(),
                label: "approval.comments.amendFacilitySecurityLinkage".tr(),
                onPressed: () => router.go(
                  Routes.facilitySecurityLinkage,
                  extra: PageMode.edit,
                ),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.amendRiskRating]!
                    .call() &&
                !viewModel.riskRatingAmendAppType
                    .contains(Globals.request?.applicationType?.reference1))
              CustomButton(
                semanticLabel: "approval.comments.amendRiskRating".tr(),
                label: "approval.comments.amendRiskRating".tr(),
                onPressed: () =>
                    router.go(Routes.riskRating, extra: PageMode.edit),
              ),
          ],

          // for risk rating
          if (!viewModel.isRiskRatingInit &&
              viewModel.proxyList
                  .contains(Globals.user?.currentRole?.roleId)) ...[
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRAROC]!
                    .call() &&
                !viewModel.rarocAmendAppType
                    .contains(Globals.request?.applicationType?.reference1))
              CustomButton(
                label: "approval.comments.amendRAROC".tr(),
                onPressed: () => router.go(
                  Routes.relationshipProfitabilitySummary,
                  extra: PageMode.edit,
                ),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendFacilities]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendFacilities".tr(),
                label: "approval.comments.amendFacilities".tr(),
                onPressed: () =>
                    router.go(Routes.facilitySummaryView, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendSecurities]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendSecurities".tr(),
                label: "approval.comments.amendSecurities".tr(),
                onPressed: () =>
                    router.go(Routes.securitySummaryView, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendCovenants".tr(),
                label: "approval.comments.amendCovenants".tr(),
                onPressed: () =>
                    router.go(Routes.covenantsSummary, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendConditions]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendConditions".tr(),
                label: "approval.comments.amendConditions".tr(),
                onPressed: () =>
                    router.go(Routes.conditionsSummary, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[
                        ApprovalFields.amendFacilitySecurityLinkage]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel:
                    "approval.comments.amendFacilitySecurityLinkage".tr(),
                label: "approval.comments.amendFacilitySecurityLinkage".tr(),
                onPressed: () => router.go(
                  Routes.facilitySecurityLinkage,
                  extra: PageMode.edit,
                ),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.amendRiskRating]!
                    .call() &&
                !viewModel.riskRatingAmendAppType
                    .contains(Globals.request?.applicationType?.reference1))
              CustomButton(
                semanticLabel: "approval.comments.amendRiskRating".tr(),
                label: "approval.comments.amendRiskRating".tr(),
                onPressed: () =>
                    router.go(Routes.riskRating, extra: PageMode.edit),
              ),
          ],

          if (viewModel.isRiskRatingInit && !viewModel.isInitByCA) ...[
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRAROC]!
                    .call() &&
                !viewModel.rarocAmendAppType
                    .contains(Globals.request?.applicationType?.reference1))
              CustomButton(
                label: "approval.comments.amendRAROC".tr(),
                onPressed: () => router.go(
                  Routes.relationshipProfitabilitySummary,
                  extra: PageMode.edit,
                ),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendFacilities]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendFacilities".tr(),
                label: "approval.comments.amendFacilities".tr(),
                onPressed: () =>
                    router.go(Routes.facilitySummaryView, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendSecurities]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendSecurities".tr(),
                label: "approval.comments.amendSecurities".tr(),
                onPressed: () =>
                    router.go(Routes.securitySummaryView, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendCovenants".tr(),
                label: "approval.comments.amendCovenants".tr(),
                onPressed: () =>
                    router.go(Routes.covenantsSummary, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[ApprovalFields.amendConditions]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel: "approval.comments.amendConditions".tr(),
                label: "approval.comments.amendConditions".tr(),
                onPressed: () =>
                    router.go(Routes.conditionsSummary, extra: PageMode.edit),
              ),
            if (viewModel.buttonVisibilityStatus[
                        ApprovalFields.amendFacilitySecurityLinkage]
                    ?.call() ??
                false)
              CustomButton(
                semanticLabel:
                    "approval.comments.amendFacilitySecurityLinkage".tr(),
                label: "approval.comments.amendFacilitySecurityLinkage".tr(),
                onPressed: () => router.go(
                  Routes.facilitySecurityLinkage,
                  extra: PageMode.edit,
                ),
              ),
            if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.amendRiskRating]!
                    .call() &&
                !viewModel.riskRatingAmendAppType
                    .contains(Globals.request?.applicationType?.reference1))
              CustomButton(
                semanticLabel: "approval.comments.amendRiskRating".tr(),
                label: "approval.comments.amendRiskRating".tr(),
                onPressed: () =>
                    router.go(Routes.riskRating, extra: PageMode.edit),
              ),
          ],

          if (viewModel.isRiskRatingInit && viewModel.isInitByCCOOD) ...[
            if (!Utils.checkRoles([UserRole.creditAnalyst]) &&
                !viewModel.proxyList
                    .contains(Globals.user?.currentRole?.roleId) &&
                !viewModel.segmentHeadList
                    .contains(Globals.user?.currentRole?.roleId) &&
                !viewModel.proxyApprovalList
                    .contains(Globals.user?.currentRole?.roleId))
              CustomDropdownMenuButton(
                key: ValueKey("rr_${viewModel.recommendPrefill?.value}"),
                label: "approval.comments.recommend".tr(),
                initialOption: viewModel.recommendPrefill,
                options: viewModel
                    .getUserListDropDownItems(viewModel.recommendUserMap),
                showValueWithLabel: true,
                callBack: (userId) {
                  viewModel.isRecommendSelected = true;
                  viewModel.selectedUserId = userId;
                },
                onButtonPressed: () =>
                    submitApplication(UserAction.recommended),
              ),
          ] else if (!(viewModel.isOneOffLimit &&
                  viewModel.businessUnitHead
                      .contains(Globals.user?.currentRole?.roleId)) &&
              !viewModel.buttonVisibilityStatus[ApprovalFields.recommend]!
                  .call() &&
              !Utils.checkRoles([
                UserRole.creditCordinator,
                UserRole.creditAnalyst,
                UserRole.boardDirectorProxyApproval,
              ]) &&
              !viewModel.proxyList
                  .contains(Globals.user?.currentRole?.roleId) &&
              !viewModel.segmentHeadList
                  .contains(Globals.user?.currentRole?.roleId)) ...[
            CustomDropdownMenuButton(
              key: ValueKey("limit_${viewModel.recommendPrefill?.value}"),
              label: "approval.comments.recommend".tr(),
              initialOption: viewModel.recommendPrefill,
              options: viewModel
                  .getUserListDropDownItems(viewModel.recommendUserMap),
              showValueWithLabel: true,
              callBack: (userId) {
                viewModel.isRecommendSelected = true;
                viewModel.selectedUserId = userId;
              },
              onButtonPressed: () => submitApplication(UserAction.recommended),
            ),
          ],

          if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!
                  .call() &&
              !viewModel.segmentHeadList
                  .contains(Globals.user?.currentRole?.roleId) &&
              !viewModel.isOneOffLimit &&
              !Utils.checkRole(UserRole.creditAnalyst) &&
              !viewModel.isInitByUser)
            CustomDropdownMenuButton(
              key: ValueKey("return_${viewModel.returnPrefill?.value}"),
              label: "approval.comments.return".tr(),
              initialOption: viewModel.returnPrefill,
              options:
                  viewModel.getUserListDropDownItems(viewModel.returnUserMap),
              showValueWithLabel: true,
              callBack: (userId) {
                viewModel.isReturnSelected = true;
                viewModel.selectedUserId = userId;
              },
              onButtonPressed: () => submitApplication(UserAction.returned),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.recommend]!
              .call())
            CustomDropdownMenuButton(
              key: ValueKey("recommend_${viewModel.recommendPrefill?.value}"),
              label: "approval.comments.recommend".tr(),
              initialOption: viewModel.recommendPrefill,
              options: viewModel
                  .getUserListDropDownItems(viewModel.recommendUserMap),
              showValueWithLabel: true,
              callBack: (userId) {
                viewModel.isRecommendSelected = true;
                viewModel.selectedUserId = userId;
              },
              onButtonPressed: () => submitApplication(UserAction.recommended),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.decline]!
                  .call() &&
              !viewModel.businessUnitHead
                  .contains(Globals.user?.currentRole?.roleId) &&
              Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
            CustomButton(
              label: "approval.comments.decline".tr(),
              semanticLabel: "approval.comments.decline".tr(),
              onPressed: () => submitApplication(UserAction.declined),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.reasonForDecline]!
                  .call() &&
              !viewModel.businessUnitHead
                  .contains(Globals.user?.currentRole?.roleId) &&
              Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
            Column(
              children: [
                Text(
                  "approval.comments.reasonForDecline".tr(),
                  semanticsLabel: "approval.comments.reasonForDecline".tr(),
                ),
                CustomDropdown<String>(
                  width: 200,
                  semanticLabel: "approval.comments.reasonForDecline".tr(),
                  hintText: "approval.comments.reasonForDecline".tr(),
                  items: Globals.reasonForDecline,
                  onSelected: (selectedValue) {
                    viewModel.selectedReason = selectedValue.first;
                  },
                  onClear: (selectedValue) {
                    viewModel.selectedReason = "";
                  },
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return dropdownItemBuildWidget(
                      item,
                      isListTile: true,
                      isSelected: isSelected,
                    );
                  },
                  dropdownBuilder: (context, data) {
                    return Text(
                      data ?? "",
                      style: const TextStyle(fontSize: 13),
                    );
                  },
                ),
              ],
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.closeApplication]!
                  .call() &&
              viewModel.isInitByUser &&
              Globals.checkCurrentStatus([RequestStatus.approved]))
            CustomButton(
              semanticLabel: "approval.comments.closeApplication".tr(),
              label: "approval.comments.closeApplication".tr(),
              onPressed: () async {
                await viewModel
                    .submitApplication(UserAction.acceptCloseApplication);
              },
            ),
          // if (viewModel.buttonVisibilityStatus[ApprovalFields.noReturn]
          //         ?.call() ??
          //     false)
          //   CustomButton(
          //     semanticLabel: "approval.comments.noReturn".tr(),
          //     label: "approval.comments.noReturn".tr(),
          //     onPressed: () {},
          //   ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.save]?.call() ??
              false)
            CustomButton(
              semanticLabel: "common.save".tr(),
              label: "common.save".tr(),
              onPressed: () => viewModel.onSavePress(
                context: context,
              ),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.saveAndContinue]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "common.saveAndContinue".tr(),
              label: "common.saveAndContinue".tr(),
              onPressed: () =>
                  viewModel.onSavePress(context: context, isContinue: true),
            ),
        ], // end of isReadOnly
      ],
    );
  }

  Future<bool> showRsaDialog(BuildContext context) async {
    bool returnValue = false;
    await DialogHelper.showCustomDialog(
      context: context,
      title: "approval.comments.authentication".tr(),
      content: Column(
        children: [
          LabelWidget(
            isRequired: true,
            label: "approval.comments.rsaToken".tr(),
            child: CustomTextField(
              isPassword: true,
              semanticLabel: "approval.comments.rsaToken".tr(),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                return CustomValidator.requiredCustomField(
                  value,
                  "approval.comments.rsaToken".tr(),
                );
              },
              onChanged: (value) {
                viewModel.rsaDigit = value;
              },
            ),
          ),
        ],
      ),
      width: context.isDesktop ? 400.w : null,
      actions: [
        CustomButton(
          label: "approval.comments.cancel".tr(),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
          label: "approval.comments.submit".tr(),
          onPressed: () async {
            returnValue = await viewModel.validateRsaToken();
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
    return returnValue;
  }

  Future<bool> showAEDWarningDialog(
    BuildContext context,
    List<String> description,
  ) async {
    bool returnValue = false;
    await DialogHelper.showCustomDialog(
      context: context,
      title: "layout.topmenu.warning".tr(),
      content: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: description.length,
            itemBuilder: (context, index) {
              return (description[index].trim().isNotEmpty)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(description[index]),
                    )
                  : const SizedBox();
            },
          ),
          const Gap(),
        ],
      ),
      width: context.isDesktop ? 500.w : null,
      actions: [
        CustomButton(
          label: "layout.topmenu.proceed".tr(),
          onPressed: () {
            returnValue = true;
            Navigator.pop(context);
          },
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
          label: "layout.topmenu.cancelText".tr(),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    return returnValue;
  }
}
