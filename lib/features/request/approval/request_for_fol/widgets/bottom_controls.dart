import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/flexbox.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/comments/widgets/button_dropdown.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/model.dart";

class BottomControls extends StatelessWidget {
  const BottomControls({
    required this.viewModel,
    required this.context,
    super.key,
  });
  final RequestForFolViewModel viewModel;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();

    Future<void> submitApplication(
      FOLTypeAction folAction, {
      UserRole? userRole,
    }) async {
      String bpmRole = "";
      // if (folAction == FOLTypeAction.finalFolGenerated &&
      //     Utils.checkRole(UserRole.documentationChecker)) {
      //   if (viewModel.isOptionsVisible == false) {
      //     viewModel.showOpts();
      //     return;
      //   }
      // }
      if (viewModel.returnPrefill != null &&
          folAction == FOLTypeAction.returnFromDocCCU &&
          !viewModel.isReturnSelected) {
        viewModel.selectedUserId = viewModel.returnPrefill?.value;
        debugPrint("selectedUserId return: ${viewModel.selectedUserId}");
      }
      if (userRole != null) {
        final String role = ServerConstants.userRoleCode[userRole] ?? "";
        debugPrint("bpmRole : $role");
        bpmRole = Globals.superUserRoles
                .map((roles) => roles[role])
                .firstWhereOrNull((value) => value != null) ??
            "";
        debugPrint("bpmRole : $bpmRole");
      }
      final List<String> result =
          await viewModel.submitApplication(folAction, bpmRole: bpmRole);
      if (result.isNotEmpty) {
        if (context.mounted &&
            result.first == "layout.topmenu.comfirmation".tr()) {
          await layoutViewModel.showConfirmationDialog(context, result.last);
        } else if (context.mounted) {
          await layoutViewModel.showWarningDialog(context, result);
        }
      }
    }

    return FlexBox(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]!
                .call() &&
            viewModel.checkCurrentStatus([FOLTypeAction.draftFolGenerated]))
          CustomButton(
            label: "approval.requestForFOL.initiateFinalFOL".tr(),
            semanticLabel: "approval.requestForFOL.initiateFinalFOL".tr(),
            onPressed: () => submitApplication(
              FOLTypeAction.initiateFinalFOL,
              userRole: UserRole.documentationChecker,
            ),
          ),
        if (viewModel
                .buttonVisibilityStatus[ApprovalFields.documentationSubmitted]!
                .call() &&
            viewModel.checkCurrentStatus([FOLTypeAction.finalFolGenerated]))
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.documentationSubmitted".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendDcUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.documentationSubmitted),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.initiateFitToLend]!
                .call() &&
            viewModel.isInitiateFitVisible)
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.initiateFitToLend".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendDmUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.initiateFitToLend),
          ),
        if (viewModel
                    .buttonVisibilityStatus[ApprovalFields.sendToDocumentation]!
                    .call() &&
                viewModel.checkCurrentStatus(
                  [FOLTypeAction.returnForAmendmentCMO],
                ) // need to check
            )
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.sendToDocumentation".tr(),
            options: viewModel
                .getUserListDropDownItems(viewModel.sendDocumentUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.sendToDocumentation),
          ),
        // if (viewModel.buttonVisibilityStatus[
        //             ApprovalFields.returnToDocumentationMaker]!
        //         .call() &&
        //     viewModel.checkCurrentStatus([FOLTypeAction.returnFromDocCCU]))
        //   CustomDropdownMenuButton(
        //     label: "approval.requestForFOL.returnToDocumentationMaker".tr(),
        //     initialOption: viewModel.returnPrefill,
        //     options:
        //         viewModel.getUserListDropDownItems(viewModel.returnUserMap),
        //     showValueWithLabel: true,
        //     callBack: (userId) {
        //       viewModel.selectedUserId = userId;
        //     },
        //     onButtonPressed: () => submitApplication(
        //         FOLTypeAction.returnFromDocCCU), // need to verify
        //   ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.rightFirstTime]!
                .call() &&
            viewModel.isOptionsVisible)
          Column(
            children: [
              Text(
                "approval.requestForFOL.rightFirstTime".tr(),
                semanticsLabel: "approval.requestForFOL.rightFirstTime".tr(),
              ),
              CustomRadioButton(
                isRequired: true,
                options: viewModel.yesNo,
                scrollDirection: Axis.horizontal,
                selectedValue: viewModel.selectedOpt,
                selectedColor: AppColors.primary,
                unselectedColor: Colors.grey,
                onChanged: (value) {
                  viewModel.onOptChanged(value);
                },
              ),
            ],
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.sendToRORM]!
                .call() &&
            viewModel.checkCurrentStatus([
              FOLTypeAction.draftFolGenerated,
              FOLTypeAction.finalFolGenerated,
              FOLTypeAction.documentationSubmitted,
            ]))
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.sendToRORM".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendRoRmUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () => submitApplication(FOLTypeAction.sendToRoRm),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.draftFolGenerated]!
                .call() &&
            viewModel.checkCurrentStatus([FOLTypeAction.initiatedDraftFOL]))
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.draftFolGenerated".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendDcUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.draftFolGenerated),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]!
                .call() &&
            viewModel.checkCurrentStatus([FOLTypeAction.initiateFinalFOL]))
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.finalFOLGenerated".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendDcUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.finalFolGenerated),
          ),
        if (viewModel
                .buttonVisibilityStatus[ApprovalFields.documentationCompleted]!
                .call() &&
            viewModel.isCompleteVisible)
          CustomButton(
            label: "approval.requestForFOL.documentationCompleted".tr(),
            semanticLabel: "approval.requestForFOL.documentationCompleted".tr(),
            onPressed: () => submitApplication(
              FOLTypeAction.documentationCompleted,
              userRole: UserRole.ccuMaker,
            ),
          ),
        if (viewModel.buttonVisibilityStatus[
                    ApprovalFields.sendToDocumentationChecker]!
                .call() &&
            viewModel.checkCurrentStatus([
              FOLTypeAction.returnToDM,
              FOLTypeAction.executedDocsUnderReview,
            ]))
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.sendToDocumentationChecker".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendDcUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.sendToDocumentationChecker),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!.call() &&
            viewModel.isReturnVisible)
          CustomDropdownMenuButton(
            key: ValueKey(viewModel.returnPrefill?.value),
            label: "approval.requestForFOL.return".tr(),
            initialOption: viewModel.returnPrefill,
            options:
                viewModel.getUserListDropDownItems(viewModel.returnUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () => submitApplication(
              FOLTypeAction.returnFromDocCCU,
            ), // need to verify
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.stage]?.call() ??
            false)
          Column(
            children: [
              Text(
                "approval.requestForFOL.stage".tr(),
                semanticsLabel: "approval.requestForFOL.stage".tr(),
              ),
              CustomDropdown<String>(
                semanticLabel: "approval.requestForFOL.stage".tr(),
                width: 300,
                items: viewModel.stageList,
                onSelected: (selectedValue) {
                  viewModel.selectedStage = selectedValue.first;
                },
              ),
            ],
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]!
                .call() &&
            viewModel.isCCUVisible)
          CustomButton(
            label: "approval.requestForFOL.sendToCCU".tr(),
            semanticLabel: "approval.requestForFOL.sendToCCU".tr(),
            onPressed: () => submitApplication(
              FOLTypeAction.sendToCCU,
              userRole: UserRole.ccuMaker,
            ),
          ),
        if (viewModel
            .buttonVisibilityStatus[ApprovalFields.sendToDocumentationMaker]!
            .call())
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.sendToDocumentationMaker".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendDmUserMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.sendToDocumentationMaker),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.save]!.call())
          CustomButton(
            label: "common.save".tr(),
            onPressed: () {
              viewModel.onSavePress(isContinue: false);
            },
          ),
        // if (viewModel.buttonVisibilityStatus[ApprovalFields.saveAndContinue]!
        //     .call())
        //   CustomButton(
        //     label: "common.saveAndContinue".tr(),
        //     onPressed: () {
        //       viewModel.onSavePress(isContinue: true);
        //     },
        //   ),
      ],
    );
  }
}
