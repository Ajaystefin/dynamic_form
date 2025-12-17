import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/model.dart';

class ContractComments extends StatelessWidget {
  final EditContractViewModel viewModel;

  const ContractComments({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final commentInputs = viewModel.getCommentInputs();
    final comments = viewModel.getComments();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabelWidget(label: "Comments"),
        ...List.generate(commentInputs.length, (index) {
          return CustomTextArea(
            semanticLabel: "project.viewEditContractDetails.contractScope".tr(),
            maxLines: 4,
            minLines: 4,
            initialValue: commentInputs[index],
            maxLength: 500,
            onChanged: (val) => viewModel.updateCommentInput(index, val),
          );
        }),
        Row(
          children: [
            CustomButton(
              label: "project.viewEditContractDetails.add".tr(),
              semanticLabel: "project.viewEditContractDetails.add".tr(),
              onPressed: () => viewModel.addCommentInput(),
            ),
            const Gap(direction: Axis.horizontal),
            CustomButton(
              label: "project.viewEditContractDetails.save".tr(),
              semanticLabel: "project.viewEditContractDetails.save".tr(),
              onPressed: () => viewModel.submitComments(),
            ),
          ],
        ),
        const Gap(),
        ...comments.map((comment) => ListTile(
              title: Text(comment.text),
              subtitle: Text(
                "Added on ${DateFormat.yMMMd().add_jm().format(comment.timestamp)}",style: AppStyle.documentSubTypeStyle)
             
            )),
      ],
    );
  }
}