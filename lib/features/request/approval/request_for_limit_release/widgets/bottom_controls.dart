import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/flexbox.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/comments/widgets/button_dropdown.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/view.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart";

/// Displays the bottom action controls for the request for limit release screen.
class BottomControls extends StatelessWidget {
  /// Creates the bottom controls for request for limit release actions.
  const BottomControls({
    required this.viewModel,
    required this.context,
    super.key,
  });

  /// View model used to manage request for limit release actions and state.
  final RequestForLimitReleaseViewModel viewModel;

  /// Build context used by dialogs and submit actions.
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();

    Future<void> submitApplication(FOLTypeAction folAction) async {
      if (viewModel.returnPrefill != null &&
          folAction == FOLTypeAction.returnFromDocCCU &&
          !viewModel.isReturnSelected) {
        viewModel.selectedUserId = viewModel.returnPrefill?.value;
        logger.i("selectedUserId return: ${viewModel.selectedUserId}");
      }
      int mode = 1;
      if (folAction == FOLTypeAction.documentationCompleted) {
        mode = 0;
      }
      final List<String> result =
          await viewModel.submitApplication(folAction, mode: mode);
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
                title: "approval.comments.previewApplication".tr(),
                content: const ListOutputFormsDialogView(),
                context: context,
              );
            },
          ),
        if (!viewModel.isReadOnly) ...[
          if (viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUMaker]!
              .call())
            CustomDropdownMenuButton(
              label: "approval.requestForLimitRelease.sendtoCCUMaker".tr(),
              options: viewModel
                  .getUserListDropDownItems(viewModel.sendToCcuMakerMap),
              callBack: (userId) {
                viewModel.selectedUserId = userId;
              },
              onButtonPressed: () =>
                  submitApplication(FOLTypeAction.sendToCCUMaker),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.stage]?.call() ??
              false)
            Column(
              children: [
                // LabelWidget(
                //   label: "approval.requestForFOL.stage".tr(),
                //   isRequired: true,
                //   child: CustomDropdown<String>(
                //     semanticLabel: "approval.requestForFOL.stage".tr(),
                //     width: 250,
                //     items: viewModel.stageList,
                //     onSelected: (selectedValue) {
                //       viewModel.selectedStage = selectedValue.first;
                //     },
                //   ),
                // ),
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
          if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]
                  ?.call() ??
              false)
            CustomDropdownMenuButton(
              label: "approval.requestForFOL.return".tr(),
              options: viewModel
                  .getUserListDropDownItems(viewModel.returnCcuMakerMap),
              callBack: (userId) {
                viewModel.selectedUserId = userId;
              },
              onButtonPressed: () =>
                  submitApplication(FOLTypeAction.returnFromDocCCU),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUChecker]
                  ?.call() ??
              false)
            CustomDropdownMenuButton(
              label: "approval.requestForLimitRelease.sendtoCCUChecker".tr(),
              options: viewModel
                  .getUserListDropDownItems(viewModel.sendToCcuCheckerMap),
              callBack: (userId) {
                viewModel.selectedUserId = userId;
              },
              onButtonPressed: () =>
                  submitApplication(FOLTypeAction.sendToCCUChecker),
            ),
          if (viewModel.buttonVisibilityStatus[ApprovalFields.returntoCCUMaker]
                  ?.call() ??
              false)
            CustomDropdownMenuButton(
              label: "approval.requestForLimitRelease.returntoCCUMaker".tr(),
              options: viewModel
                  .getUserListDropDownItems(viewModel.returnCcuMakerMap),
              callBack: (userId) {
                viewModel.selectedUserId = userId;
              },
              onButtonPressed: () =>
                  submitApplication(FOLTypeAction.returnFromDocCCU),
            ),
          if (viewModel.buttonVisibilityStatus[
                      ApprovalFields.acceptCloseApplication]!
                  .call() &&
              viewModel.isButtonVisible)
            CustomButton(
              semanticLabel:
                  "approval.requestForLimitRelease.acceptCloseApplication".tr(),
              label:
                  "approval.requestForLimitRelease.acceptCloseApplication".tr(),
              onPressed: () => submitApplication(
                FOLTypeAction.documentationCompleted,
              ),
            ),
          CustomButton(
            label: "common.save".tr(),
            onPressed: () {
              viewModel.saveComment();
            },
          ),
          // CustomButton(
          //   label: "common.saveAndContinue".tr(),
          //   onPressed: () {
          //     // viewModel.onSavePress(context: context, isContinue: true);
          //     viewModel.saveComment(ifNavigate: true);
          //   },
          // ),
        ],
      ],
    );
  }
}
