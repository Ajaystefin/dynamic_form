import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/models/request/request.dart";

class GroupName extends StatelessWidget {
  const GroupName({required this.request, super.key});
  final Request request;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "common.components.applicationHeader.groupId".tr(),
      // label: 'common.components.applicationHeader.groupName'.tr(), dont add
      // again group Name - check this id -uat- 1223931
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: CustomSelectableText(
        text: () {
          // Build display text: "Group Name (Group ID)"
          final String groupName = request.groupName ?? "";
          final String groupId = request.groupId?.toString() ?? "";
          final String idPart = groupId.isNotEmpty ? " ($groupId)" : "";
          return "$groupName$idPart";
        }(),
        style: const TextStyle(color: AppColors.black),
      ),
    );
  }
}
