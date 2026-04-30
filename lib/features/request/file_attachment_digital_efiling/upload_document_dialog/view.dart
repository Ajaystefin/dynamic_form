import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/view_mobile.dart";
import "package:wcas_frontend/models/request/customer.dart";

class UploadDocumentDialogView extends StatelessWidget {
  const UploadDocumentDialogView({
    required this.groupRim,
    required this.customerRim,
    required this.applicationId,
    required this.rimList,
    super.key,
    this.grpId,
  });
  final String groupRim;
  final String customerRim;
  final String applicationId;
  final String? grpId;
  final List<Customer> rimList;

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
