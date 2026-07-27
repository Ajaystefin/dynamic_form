import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/view_mobile.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// UploadDocumentDialog View
class UploadDocumentDialogView extends StatelessWidget {
  /// Creates instance
  const UploadDocumentDialogView({
    required this.groupRim,
    required this.customerRim,
    required this.applicationId,
    required this.rimList,
    required this.searchedBy,
    super.key,
    this.grpId,
  });

  /// group rim
  final String groupRim;

  /// customer rim
  final String customerRim;

  /// application id
  final String applicationId;

  /// group id
  final String? grpId;

  /// List of Customer
  final List<Customer> rimList;

  /// searched by
  final int searchedBy;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UploadDocumentDialogViewModel>(
      create: (context) => UploadDocumentDialogViewModel()
        ..init(
          context,
          groupRim: groupRim,
          customerRim: customerRim,
          applicationId: applicationId,
          companyRims: rimList,
          grpId: grpId,
          searchedBy: searchedBy,
        ),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            case DeviceScreenType.mobile:
              return const ViewMobile();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
