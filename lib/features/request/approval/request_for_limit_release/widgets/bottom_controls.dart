import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/flexbox.dart";
// import 'package:wcas_frontend/core/components/label.dart';
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/comments/widgets/button_dropdown.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/widgets/application_output_selection_table.dart";

class BottomControls extends StatelessWidget {
  const BottomControls({
    required this.viewModel,
    required this.context,
    super.key,
  });
  final RequestForLimitReleaseViewModel viewModel;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel layoutViewModel = context.watch<LayoutViewModel>();

    Future<void> submitApplication(FOLTypeAction folAction) async {
      if (viewModel.returnPrefill != null &&
          folAction == FOLTypeAction.returnFromDocCCU &&
          !viewModel.isReturnSelected) {
        viewModel.selectedUserId = viewModel.returnPrefill?.value;
        debugPrint("selectedUserId return: ${viewModel.selectedUserId}");
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
        if (viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUMaker]!
            .call())
          CustomDropdownMenuButton(
            label: "approval.requestForLimitRelease.sendtoCCUMaker".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.sendToCcuMakerMap),
            showValueWithLabel: true,
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
        if (viewModel.buttonVisibilityStatus[ApprovalFields.returns]?.call() ??
            false)
          CustomDropdownMenuButton(
            label: "approval.requestForFOL.return".tr(),
            options:
                viewModel.getUserListDropDownItems(viewModel.returnCcuMakerMap),
            showValueWithLabel: true,
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
            showValueWithLabel: true,
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
            options:
                viewModel.getUserListDropDownItems(viewModel.returnCcuMakerMap),
            showValueWithLabel: true,
            callBack: (userId) {
              viewModel.selectedUserId = userId;
            },
            onButtonPressed: () =>
                submitApplication(FOLTypeAction.returnFromDocCCU),
          ),
        if (viewModel.buttonVisibilityStatus[ApprovalFields.previewApplication]
                ?.call() ??
            false)
          CustomButton(
            label: "approval.requestForLimitRelease.previewApplication".tr(),
            semanticLabel:
                "approval.requestForLimitRelease.previewApplication".tr(),
            onPressed: () {
              DialogHelper.showCustomDialog(
                barrierDismissible: true,
                actions: [
                  CustomButton(
                    semanticLabel:
                        "approval.requestForLimitRelease.accept".tr(),
                    label: "approval.requestForLimitRelease.accept".tr(),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  CustomButton(
                    semanticLabel:
                        "approval.requestForLimitRelease.cancel".tr(),
                    label: "approval.requestForLimitRelease.cancel".tr(),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ],
                title: "approval.requestForLimitRelease.confirmation".tr(),
                content: AppOutputSelectionTableWidget(
                  viewModel: viewModel,
                ),
                context: context,
              );
            },
          ),
        if (viewModel
                .buttonVisibilityStatus[ApprovalFields.acceptCloseApplication]!
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
    );
  }
}
