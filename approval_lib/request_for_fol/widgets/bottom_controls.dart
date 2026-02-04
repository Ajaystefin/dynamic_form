import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/flexbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/request_for_fol/model.dart';
import 'package:wcas_frontend/features/request/approval/request_for_fol/widgets/user_selection_button_dropdown.dart';

class BottomControls extends StatelessWidget {
  final RequestForFolViewModel viewModel;
  final BuildContext context;

  const BottomControls(
      {required this.viewModel, required this.context, super.key});

  @override
  Widget build(BuildContext context) {
    return FlexBox(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 10,
        runSpacing: 10,
        children: [
          if (viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]!
                      .call() &&
                  Globals.checkCurrentStatus([FOLTypeAction.initiateFinalFOL])
              //  && Globals.checkCurrentStatus([RequestStatus.approved])
              )
            CustomButton(
                label: "approval.requestForFOL.initiateFinalFOL".tr(),
                semanticLabel: "approval.requestForFOL.initiateFinalFOL".tr(),
                onPressed: () => viewModel
                    .submitApplicationFOL(FOLTypeAction.initiateFinalFOL)),

          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.documentationSubmitted]!
                  .call() &&
              Globals.checkCurrentStatus(
                  [FOLTypeAction.documentationSubmitted]))
            CustomButton(
              label: "approval.requestForFOL.documentationSubmitted".tr(),
              semanticLabel:
                  "approval.requestForFOL.documentationSubmitted".tr(),
              onPressed: () {
                viewModel
                    .submitApplicationFOL(FOLTypeAction.documentationSubmitted);
              },
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.initiateFitToLend]!
                  .call() &&
              Globals.checkCurrentStatus([FOLTypeAction.initialFitToLend]))
            CustomButton(
              label: "approval.requestForFOL.initiateFitToLend".tr(),
              semanticLabel: "approval.requestForFOL.initiateFitToLend".tr(),
              onPressed: () {
                viewModel.submitApplicationFOL(FOLTypeAction.initialFitToLend);
              },
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.sendToDocumentation]!
                  .call() &&
              Globals.checkCurrentStatus([FOLTypeAction.sendToDocumentation]))
            // CustomDropdownButton(
            //   label: "approval.requestForFOL.sendToDocumentation".tr(),
            //   initialOption: CustomDropdownItem(
            //     value: "Send to Documentation",
            //     onPressed: () {},
            //   ),
            //   options: viewModel.userList,
            // ),
            RecommendationDropdown(
              options: viewModel.userList,
              label: "approval.requestForFOL.sendToDocumentation".tr(),
              viewModel: viewModel,
              userAction: UserAction.recommended, // need to verify
            ),
          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.returnToDocumentationMaker]!
                  .call() &&
              Globals.checkCurrentStatus([FOLTypeAction.returnFromDocCCU]))
            // CustomDropdownButton(
            //   label: "approval.requestForFOL.returnToDocumentationMaker".tr(),
            //   initialOption: CustomDropdownItem(
            //     value: "Return to Documentation Maker",
            //     onPressed: () {},
            //   ),
            //   options: viewModel.userList,
            // ),
            RecommendationDropdown(
              options: viewModel.userList,
              label: "approval.requestForFOL.returnToDocumentationMaker".tr(),
              viewModel: viewModel,
              userAction: UserAction.recommended, // need to verify
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.rightFirstTime]
                  ?.call() ??
              false)
            Column(
              children: [
                Text("approval.requestForFOL.rightFirstTime".tr(),
                    semanticsLabel:
                        "approval.requestForFOL.rightFirstTime".tr()),
                CustomRadioButton(
                  isRequired: true,
                  options: viewModel.yesNo,
                  scrollDirection: Axis.horizontal,
                  selectedValue: '',
                  selectedColor: AppColors.primary,
                  unselectedColor: Colors.grey,
                  onChanged: (value) {},
                ),
              ],
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.sendToRORM]
                  ?.call() ??
              false)
            // CustomDropdownButton(
            //   label: "approval.requestForFOL.sendToRORM".tr(),
            //   initialOption: CustomDropdownItem(
            //     value: "Send to RO/RM",
            //     onPressed: () {},
            //   ),
            //   options: viewModel.userList,
            // ),
            RecommendationDropdown(
              options: viewModel.userList,
              label: "approval.requestForFOL.sendToRORM".tr(),
              viewModel: viewModel,
              userAction: UserAction.recommended, // need to verify
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.draftFolGenerated]!
                  .call() &&
              Globals.checkCurrentStatus([FOLTypeAction.draftFolGenerated]))
            CustomButton(
              label: "approval.requestForFOL.draftFolGenerated".tr(),
              semanticLabel: "approval.requestForFOL.draftFolGenerated".tr(),
              onPressed: () {
                viewModel.submitApplicationFOL(FOLTypeAction.draftFolGenerated);
              },
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]!
                  .call() &&
              Globals.checkCurrentStatus([FOLTypeAction.finalFolGenerated]))
            CustomButton(
              label: "approval.requestForFOL.finalFOLGenerated".tr(),
              semanticLabel: "approval.requestForFOL.finalFOLGenerated".tr(),
              onPressed: () {
                viewModel.submitApplicationFOL(FOLTypeAction.finalFolGenerated);
              },
            ),

          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.documentationCompleted]!
                  .call() &&
              Globals.checkCurrentStatus(
                  [FOLTypeAction.documentationCompleted]))
            CustomButton(
              label: "approval.requestForFOL.documentationCompleted".tr(),
              semanticLabel:
                  "approval.requestForFOL.documentationCompleted".tr(),
              onPressed: () {
                viewModel
                    .submitApplicationFOL(FOLTypeAction.documentationCompleted);
              },
            ),

          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.sendToDocumentationChecker]!
                  .call() &&
              Globals.checkCurrentStatus(
                  [FOLTypeAction.sendToDocumentationChecker]))
            // CustomDropdownButton(
            //   label: "approval.requestForFOL.sendToDocumentationChecker".tr(),
            //   initialOption: CustomDropdownItem(
            //     value: "Send to Documentation Checker",
            //     onPressed: () {},
            //   ),
            //   options: viewModel.userList,
            // ),
            RecommendationDropdown(
              options: viewModel.userList,
              label: "approval.requestForFOL.sendToDocumentationChecker".tr(),
              viewModel: viewModel,
              userAction: UserAction.recommended, // need to verify
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]!.call()
              // && Globals.checkCurrentStatus([FOLTypeAction.returnFromDocCCU]) // check the key
              )
            // CustomDropdownButton(
            //   label: "approval.requestForFOL.return".tr(),
            //   initialOption: CustomDropdownItem(
            //     value: "Return",
            //     onPressed: () {},
            //   ),
            //   options: viewModel.userList,
            // ),
            RecommendationDropdown(
              options: viewModel.userList,
              label: "approval.requestForFOL.return".tr(),
              viewModel: viewModel,
              userAction: UserAction.recommended, // need to verify
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.stage]?.call() ??
              false)
            Column(
              children: [
                LabelWidget(
                  label: "approval.requestForFOL.stage".tr(),
                  isRequired: true,
                  child: CustomDropdown<String>(
                    semanticLabel: "approval.requestForFOL.stage".tr(),
                    width: 200,
                    items: viewModel.stageList,
                  ),
                ),
              ],
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]!.call()
              // && Globals.checkCurrentStatus([FOLTypeAction.sendToCCU]) // doc says FOL not required
              )
            CustomButton(
              label: "approval.requestForFOL.sendToCCU".tr(),
              semanticLabel: "approval.requestForFOL.sendToCCU".tr(),
              onPressed: () {
                viewModel.submitApplicationFOL(FOLTypeAction.sendToCCU);
              },
            ),

          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.sendToDocumentationMaker]!
                  .call() &&
              Globals.checkCurrentStatus(
                  [FOLTypeAction.sendToDocumentationMaker]))
            // CustomDropdownButton(
            //   label: "approval.requestForFOL.sendToDocumentationMaker".tr(),
            //   initialOption: CustomDropdownItem(
            //     value: "Send to Documentation Maker",
            //     onPressed: () {},
            //   ),
            //   options: userList,
            // ),
            RecommendationDropdown(
              options: viewModel.userList,
              label: "approval.requestForFOL.sendToDocumentationMaker".tr(),
              viewModel: viewModel,
              userAction: UserAction.recommended, // need to verify
            ),
          // if (canView(ApprovalFields.saveAndContinue))
          //   CustomButton(
          //     label: "common.saveAndContinue".tr(),
          //     onPressed: () {
          //       viewModel.onSavePress(isContinue: true);
          //     },
          //   ),
          // CustomButton(
          //   label: "common.save".tr(),
          //   onPressed: () {
          //     viewModel.onSavePress(isContinue: false);
          //   },
          // ),
        ]);
  }
}
