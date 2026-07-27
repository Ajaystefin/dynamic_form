import "package:flutter/material.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/top_section/fields/application_no.dart";
import "package:wcas_frontend/core/components/top_section/fields/business_segment.dart";
import "package:wcas_frontend/core/components/top_section/fields/customer_name.dart";
import "package:wcas_frontend/core/components/top_section/fields/group_name.dart";
import "package:wcas_frontend/core/components/top_section/fields/request_type.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Displays top-level request details such as application number,
/// customer information, business segment, and request type.
class TopSectionDetails extends StatelessWidget {
  /// Creates a [TopSectionDetails].
  const TopSectionDetails({
    required this.request,
    super.key,
  });

  /// Request data displayed in the top section.
  final Request request;

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      child: context.deviceScreenType == DeviceScreenType.mobile
          ? SizedBox(
              width: double.infinity,
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sectionFields(context),
              ),
            )
          : Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sectionFields(context),
            ),
    );
  }

  /// Builds the widgets displayed within the top section.
  ///
  /// Layout varies based on the current device screen type.
  List<Widget> sectionFields(BuildContext context) {
    return context.deviceScreenType == DeviceScreenType.mobile
        ? [
            if ((request.applicationRefNo ?? "").isNotEmpty)
              ApplicationNo(request: request),
            if ((request.customerName ?? "").isNotEmpty)
              CustomerName(request: request),
            if (request.groupName != null &&
                request.groupName!.isNotEmpty &&
                request.groupId != 0)
              GroupName(request: request),
            if (request.businessSegment != null)
              BusinessSegment(request: request),
            RequestType(request: request),
          ]
        : [
            if ((request.applicationRefNo ?? "").isNotEmpty)
              Expanded(child: ApplicationNo(request: request)),
            if ((request.customerName ?? "").isNotEmpty)
              Expanded(child: CustomerName(request: request)),
            if (request.groupName != null &&
                request.groupName!.isNotEmpty &&
                request.groupId != 0)
              Expanded(child: GroupName(request: request)),
            if (request.businessSegment != null)
              Expanded(child: BusinessSegment(request: request)),
            Expanded(child: RequestType(request: request)),
          ];
  }
}
