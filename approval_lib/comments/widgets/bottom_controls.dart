import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/flexbox.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/comments/model.dart';
import 'package:wcas_frontend/features/request/approval/comments/widgets/user_selection_button_dropdown.dart';
import 'package:wcas_frontend/features/request/approval/list_output_forms_dialog/view.dart';

class BottomControls extends StatelessWidget {
  final CommentsViewModel viewModel;
  final BuildContext context;
  final bool canSubmit;

  const BottomControls(
      {super.key,
      required this.viewModel,
      required this.context,
      this.canSubmit = true});

  @override
  Widget build(BuildContext context) {
    return FlexBox(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: [
        // start for OneOffLimit
        if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!.call() &&
                !Globals.isInitiated ||
            viewModel.isOneOffLimit)
          RecommendationDropdown(
              options: viewModel.returnUserList,
              label: "approval.comments.return".tr(),
              viewModel: viewModel,
              userAction: UserAction.returned),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.approve]!.call() &&
            viewModel.isOneOffLimit &&
            Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
          CustomButton(
            semanticLabel: "approval.comments.approve".tr(),
            label: "approval.comments.approve".tr(),
            onPressed: () => viewModel.submitApplication(UserAction.approved),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.approveonbehalf]!
                .call() &&
            viewModel.isOneOffLimit &&
            Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
          RecommendationDropdown(
            options: viewModel.approveUserList,
            label: "approval.comments.approveOnBehalfOf".tr(),
            viewModel: viewModel,
            userAction: UserAction.approveOnBehalfOf,
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.approvalDelegation]!
                .call() &&
            viewModel.isOneOffLimit)
          Column(
            children: [
              Text("approval.comments.approvalDelegation".tr(),
                  semanticsLabel: "approval.comments.approvalDelegation".tr()),
              CustomDropdown<String>(
                width: 200,
                semanticLabel: "approval.comments.approvalDelegation".tr(),
                hintText: "approval.comments.approvalDelegation".tr(),
                items: viewModel.approvalDelegationList,
                onSelected: (selectedValue) {
                  debugPrint("selectedValue : $selectedValue");
                  viewModel.selectedDelegation = selectedValue.first;
                  debugPrint("selectedValue : ${viewModel.selectedDelegation}");
                },
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return dropdownItemBuildWidget(item.split(":").first,
                      isListTile: true, isSelected: isSelected);
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.split(":").first ?? "",
                    style: const TextStyle(fontSize: 13),
                  );
                },
              ),
            ],
          ),
        // end for OneOffLimit

        // for segment head roles
        if (viewModel.segmentHeadList
            .contains(Globals.user?.currentRole?.roleId)) ...[
          if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!.call())
            RecommendationDropdown(
                options: viewModel.returnUserList,
                label: "approval.comments.return".tr(),
                viewModel: viewModel,
                userAction: UserAction.returned),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.approve]!
                  .call() &&
              Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
            CustomButton(
              semanticLabel: "approval.comments.approve".tr(),
              label: "approval.comments.approve".tr(),
              onPressed: () => viewModel.submitApplication(UserAction.approved),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.approveonbehalf]!
                  .call() &&
              Globals.checkCurrentStatus([RequestStatus.pendingForApproval]))
            RecommendationDropdown(
              options: viewModel.approveUserList,
              label: "approval.comments.approveOnBehalfOf".tr(),
              viewModel: viewModel,
              userAction: UserAction.approveOnBehalfOf,
            ),
          if (viewModel
              .buttonVisibilityStatus[ApprovalFields.approvalDelegation]!
              .call())
            Column(
              children: [
                Text("approval.comments.approvalDelegation".tr(),
                    semanticsLabel:
                        "approval.comments.approvalDelegation".tr()),
                CustomDropdown<String>(
                  width: 200,
                  semanticLabel: "approval.comments.approvalDelegation".tr(),
                  hintText: "approval.comments.approvalDelegation".tr(),
                  items: viewModel.approvalDelegationList,
                  onSelected: (selectedValue) {
                    debugPrint("selectedValue : $selectedValue");
                    viewModel.selectedDelegation = selectedValue.first;
                    debugPrint(
                        "selectedValue : ${viewModel.selectedDelegation}");
                  },
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return dropdownItemBuildWidget(item.split(":").first,
                        isListTile: true, isSelected: isSelected);
                  },
                  dropdownBuilder: (context, data) {
                    return Text(
                      data?.split(":").first ?? "",
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
              !viewModel.isRiskRatingInit)
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
                RecommendationDropdown(
                    options: viewModel.returnUserList,
                    label: "approval.comments.return".tr(),
                    viewModel: viewModel,
                    userAction: UserAction.returned),
              ],
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!
                  .call() &&
              viewModel.isRiskRatingInit &&
              !viewModel.isInitByCA &&
              !viewModel.segmentHeadList
                  .contains(Globals.user?.currentRole?.roleId))
            RecommendationDropdown(
                options: viewModel.returnUserList,
                label: "approval.comments.return".tr(),
                viewModel: viewModel,
                userAction: UserAction.returned),
        ],

        // for risk rating
        if (!viewModel.isRiskRatingInit && viewModel.isInitByCA) ...[
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRAROC]!
              .call())
            CustomButton(
              label: "approval.comments.amendRAROC".tr(),
              onPressed: () =>
                  context.push(Routes.relationshipProfitabilitySummary),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendFacilities]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendFacilities".tr(),
              label: "approval.comments.amendFacilities".tr(),
              onPressed: () => context.push(Routes.facilitySummaryView),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendSecurities]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendSecurities".tr(),
              label: "approval.comments.amendSecurities".tr(),
              onPressed: () => context.push(Routes.securitySummaryView),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendCovenants".tr(),
              label: "approval.comments.amendCovenants".tr(),
              onPressed: () => context.push(Routes.covenantsSummary),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendConditions]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendConditions".tr(),
              label: "approval.comments.amendConditions".tr(),
              onPressed: () => context.push(Routes.conditionsSummary),
            ),
          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.amendFacilitySecurityLinkage]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel:
                  "approval.comments.amendFacilitySecurityLinkage".tr(),
              label: "approval.comments.amendFacilitySecurityLinkage".tr(),
              onPressed: () => context.push(Routes.facilitySecurityLinkage),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRiskRating]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendRiskRating".tr(),
              label: "approval.comments.amendRiskRating".tr(),
              onPressed: () => context.push(Routes.riskRating),
            ),
        ],

        if (viewModel.isRiskRatingInit && !viewModel.isInitByCA) ...[
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRAROC]!
              .call())
            CustomButton(
              label: "approval.comments.amendRAROC".tr(),
              onPressed: () =>
                  context.push(Routes.relationshipProfitabilitySummary),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendFacilities]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendFacilities".tr(),
              label: "approval.comments.amendFacilities".tr(),
              onPressed: () => context.push(Routes.facilitySummaryView),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendSecurities]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendSecurities".tr(),
              label: "approval.comments.amendSecurities".tr(),
              onPressed: () => context.push(Routes.securitySummaryView),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendCovenants]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendCovenants".tr(),
              label: "approval.comments.amendCovenants".tr(),
              onPressed: () => context.push(Routes.covenantsSummary),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendConditions]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendConditions".tr(),
              label: "approval.comments.amendConditions".tr(),
              onPressed: () => context.push(Routes.conditionsSummary),
            ),
          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.amendFacilitySecurityLinkage]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel:
                  "approval.comments.amendFacilitySecurityLinkage".tr(),
              label: "approval.comments.amendFacilitySecurityLinkage".tr(),
              onPressed: () => context.push(Routes.facilitySecurityLinkage),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.amendRiskRating]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel: "approval.comments.amendRiskRating".tr(),
              label: "approval.comments.amendRiskRating".tr(),
              onPressed: () => context.push(Routes.riskRating),
            ),
        ],

        if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!.call() &&
            !viewModel.segmentHeadList
                .contains(Globals.user?.currentRole?.roleId) &&
            !Utils.checkRole(UserRole.creditAnalyst))
          RecommendationDropdown(
              options: viewModel.returnUserList,
              label: "approval.comments.return".tr(),
              viewModel: viewModel,
              userAction: UserAction.returned),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.recommend]!
                .call() &&
            !viewModel.isOneOffLimit)
          RecommendationDropdown(
            options: viewModel.groupUserList,
            label: "approval.comments.recommend".tr(),
            viewModel: viewModel,
            userAction: UserAction.recommended,
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.decline]!.call() ||
            !viewModel.isOneOffLimit &&
                Globals.checkCurrentStatus([RequestStatus.declined]))
          CustomButton(
            label: "approval.comments.decline".tr(),
            semanticLabel: "approval.comments.decline".tr(),
            onPressed: () => viewModel.submitApplication(UserAction.declined),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.reasonForDecline]!
                .call() &&
            Globals.checkCurrentStatus([RequestStatus.declined]))
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
        if (viewModel.buttonVisibilityStatus[ApprovalFields.closeApplication]!
                .call() &&
            Globals.isInitiated &&
            Globals.checkCurrentStatus([
              // RequestStatus.initiated,
              // RequestStatus.completed,
              RequestStatus.approved
            ]))
          CustomButton(
            semanticLabel: "approval.comments.closeApplication".tr(),
            label: "approval.comments.closeApplication".tr(),
            onPressed: () async {
              await viewModel
                  .submitApplication(UserAction.acceptCloseApplication);
            },
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
      ],
    );
  }
}
