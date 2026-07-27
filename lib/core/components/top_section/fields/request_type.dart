import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Displays the request type in the top section.
class RequestType extends StatelessWidget {
  /// Creates a [RequestType].
  const RequestType({
    required this.request,
    super.key,
  });

  /// Request containing the application type details.
  final Request request;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "common.components.applicationHeader.requestType".tr(),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: CustomSelectableText(
        text: request.applicationType?.name ?? "",
        style: const TextStyle(color: AppColors.black),
      ),
    );
  }
}
