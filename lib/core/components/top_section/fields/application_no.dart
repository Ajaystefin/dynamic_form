import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Displays the application reference number in the top section.
class ApplicationNo extends StatelessWidget {
  /// Creates an [ApplicationNo].
  const ApplicationNo({
    required this.request,
    super.key,
  });

  /// Request containing the application reference number.
  final Request request;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "common.components.applicationHeader.applicationNo".tr(),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: CustomSelectableText(
        text: request.applicationRefNo ?? "",
        style: const TextStyle(color: AppColors.black),
      ),
    );
  }
}
