import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/features/admin/file_access/view_desktop.dart";
import "package:wcas_frontend/features/admin/file_access/view_mobile.dart";

/// Entry view for file access management.
class FileAccessView extends StatelessWidget {
  /// Creates a [FileAccessView].
  const FileAccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileAccessViewModel>(
      create: (context) => FileAccessViewModel()..init(context),
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
