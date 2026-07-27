import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Displays the business segment information in the top section.
class BusinessSegment extends StatelessWidget {
  /// Creates a [BusinessSegment].
  const BusinessSegment({
    required this.request,
    super.key,
  });

  /// Request containing the business segment details.
  final Request request;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: ((request.appBusinessSegment ?? "").isNotEmpty)
          ? "common.components.applicationHeader.applicationSegment".tr()
          : "dashboard.home.customerSegment".tr(),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: CustomSelectableText(
        text: ((request.appBusinessSegment ?? "").isNotEmpty)
            ? request.appBusinessSegment ??
                (request.businessSegment?.name ?? "")
                    .capitalizeFirstLetterFirstSecond()
            : (request.businessSegment?.name ?? "")
                .capitalizeFirstLetterFirstSecond(),
        style: const TextStyle(color: AppColors.black),
      ),
    );
  }
}
