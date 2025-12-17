import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/flexbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/request_for_fol/model.dart';

class BottomControls extends StatelessWidget {
  final RequestForFolViewModel viewModel;
  final BuildContext context;

  BottomControls({required this.viewModel, required this.context, super.key});

  final userList = [
    CustomDropdownItem(
      value: "User 1",
      onPressed: () {},
    ),
    CustomDropdownItem(
      value: "User 2",
      onPressed: () {},
    ),
    CustomDropdownItem(
      value: "User 3",
      onPressed: () {},
    )
  ];

  @override
  Widget build(BuildContext context) {
    return FlexBox(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 10,
        runSpacing: 10,
        children: [
          if (viewModel.buttonVisibilityStatus[ApprovalFields.initiateFinalFOL]
                  ?.call() ??
              false)
            CustomButton(
              label: "approval.requestForFOL.initiateFinalFOL".tr(),
              semanticLabel: "approval.requestForFOL.initiateFinalFOL".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.documentationSubmitted]
                  ?.call() ??
              false)
            CustomButton(
              label: "approval.requestForFOL.documentationSubmitted".tr(),
              semanticLabel:
                  "approval.requestForFOL.documentationSubmitted".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.initiateFitToLend]
                  ?.call() ??
              false)
            CustomButton(
              label: "approval.requestForFOL.initiateFitToLend".tr(),
              semanticLabel: "approval.requestForFOL.initiateFitToLend".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.sendToDocumentation]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForFOL.sendToDocumentation".tr(),
              initialOption: CustomDropdownItem(
                value: "Send to Documentation",
                onPressed: () {},
              ),
              options: userList,
            ),

          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.returnToDocumentationMaker]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForFOL.returnToDocumentationMaker".tr(),
              initialOption: CustomDropdownItem(
                value: "Return to Documentation Maker",
                onPressed: () {},
              ),
              options: userList,
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
            CustomDropdownButton(
              label: "approval.requestForFOL.sendToRORM".tr(),
              initialOption: CustomDropdownItem(
                value: "Send to RO/RM",
                onPressed: () {},
              ),
              options: userList,
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.draftFolGenerated]
                  ?.call() ??
              false)
            CustomButton(
              label: "approval.requestForFOL.draftFolGenerated".tr(),
              semanticLabel: "approval.requestForFOL.draftFolGenerated".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.finalFOLGenerated]
                  ?.call() ??
              false)
            CustomButton(
              label: "approval.requestForFOL.finalFOLGenerated".tr(),
              semanticLabel: "approval.requestForFOL.finalFOLGenerated".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.documentationCompleted]
                  ?.call() ??
              false)
            CustomButton(
              label: "approval.requestForFOL.documentationCompleted".tr(),
              semanticLabel:
                  "approval.requestForFOL.documentationCompleted".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),

          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.sendToDocumentationChecker]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForFOL.sendToDocumentationChecker".tr(),
              initialOption: CustomDropdownItem(
                value: "Send to Documentation Checker",
                onPressed: () {},
              ),
              options: userList,
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForFOL.return".tr(),
              initialOption: CustomDropdownItem(
                value: "Return",
                onPressed: () {},
              ),
              options: userList,
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

          if (viewModel.buttonVisibilityStatus[ApprovalFields.sendToCCU]
                  ?.call() ??
              false)
          CustomButton(
            label: "approval.requestForFOL.sendToCCU".tr(),
            semanticLabel: "approval.requestForFOL.sendToCCU".tr(),
            onPressed: () {
              viewModel.onSavePress(isContinue: true);
            },
          ),

          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.sendToDocumentationMaker]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForFOL.sendToDocumentationMaker".tr(),
              initialOption: CustomDropdownItem(
                value: "Send to Documentation Maker",
                onPressed: () {},
              ),
              options: userList,
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
