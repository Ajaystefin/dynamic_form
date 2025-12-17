import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/flexbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart';
import 'package:wcas_frontend/features/request/approval/request_for_limit_release/widgets/application_output_selection_table.dart';

class BottomControls extends StatelessWidget {
  final RequestForLimitReleaseViewModel viewModel;
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
          if (viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUMaker]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForLimitRelease.sendtoCCUMaker".tr(),
              initialOption: CustomDropdownItem(
                value: "approval.requestForLimitRelease.sendtoCCUMaker".tr(),
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

          if (viewModel.buttonVisibilityStatus[ApprovalFields.sendtoCCUChecker]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForLimitRelease.sendtoCCUChecker".tr(),
              initialOption: CustomDropdownItem(
                value: "approval.requestForLimitRelease.sendtoCCUChecker".tr(),
                onPressed: () {},
              ),
              options: userList,
            ),

          if (viewModel.buttonVisibilityStatus[ApprovalFields.returntoCCUMaker]
                  ?.call() ??
              false)
            CustomDropdownButton(
              label: "approval.requestForLimitRelease.returntoCCUMaker".tr(),
              initialOption: CustomDropdownItem(
                value: "approval.requestForLimitRelease.returntoCCUMaker".tr(),
                onPressed: () {},
              ),
              options: userList,
            ),

          if (viewModel
                  .buttonVisibilityStatus[ApprovalFields.previewApplication]
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
                  .buttonVisibilityStatus[ApprovalFields.acceptCloseApplication]
                  ?.call() ??
              false)
            CustomButton(
              semanticLabel:
                  "approval.requestForLimitRelease.acceptCloseApplication".tr(),
              label:
                  "approval.requestForLimitRelease.acceptCloseApplication".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
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
