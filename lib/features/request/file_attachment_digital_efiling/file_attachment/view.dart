import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/view_desktop.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/view_mobile.dart";

/// FileAttachmentView
class FileAttachmentView extends StatelessWidget {
  /// Creates instance
  const FileAttachmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileAttachmentViewModel>(
      create: (context) => FileAttachmentViewModel()..init(context),
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
