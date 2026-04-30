// lib/features/request/file_attachment_digital_efiling/appendix/view.dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/view_desktop.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/view_mobile.dart";

class AppendixView extends StatelessWidget {
  const AppendixView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppendixViewModel>(
      create: (ctx) => AppendixViewModel(),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
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
