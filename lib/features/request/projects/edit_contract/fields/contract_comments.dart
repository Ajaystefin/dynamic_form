import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

/// Contract comments field.
class ContractComments extends StatelessWidget {
  /// Creates a contract comments field.
  const ContractComments({required this.viewModel, super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final commentInputs = viewModel.getCommentInputs(); // List<String>
    // final comments = viewModel.commentItem; // List<Comment>

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabelWidget(label: "Comments"),

        // Input rows
        ...List.generate(commentInputs.length, (index) {
          return CustomTextArea(
            filled: !viewModel.canEdit,
            readOnly: !viewModel.canEdit,
            semanticLabel: "project.viewEditContractDetails.contractScope".tr(),
            initialValue: commentInputs[index],
            controller: viewModel.contractorCommentsController,
            maxLength: 500,
            showMaximumLengthIndicator: false,
            onChanged: (val) => viewModel.updateCommentInput(index, val),
          );
        }),

        // Actions - Need plus button enable
        // Row(
        //   children: [
        //     CustomButton(
        //       label: "project.viewEditContractDetails.add".tr(),
        //       semanticLabel: "project.viewEditContractDetails.add".tr(),
        //       onPressed: () => viewModel.addCommentInput(),
        //     ),
        //     const Gap(direction: Axis.horizontal),
        //     CustomButton(
        //       label: "project.viewEditContractDetails.save".tr(),
        //       semanticLabel: "project.viewEditContractDetails.save".tr(),
        //       onPressed: () => viewModel.submitComments(),
        //     ),
        //   ],
        // ),

        // const Gap(),

        // Saved comments list (render safely, no '!')
        // if (comments.isNotEmpty)
        //   ...comments.map((comment) {
        //     final title = comment.strategyComment ?? '';
        //     final date = comment.createdDate;
        //     // Format date safely
        //     final dateText = (date != null)
        //         ? "Added on ${DateFormat.yMMMd().add_jm().format(date)}"
        //         : "";

        //     return ListTile(
        //       title: Text(title),
        //       subtitle: Text(
        //         dateText,
        //         style: AppStyle.documentSubTypeStyle,
        //       ),
        //     );
        //   }),
      ],
    );
  }
}
