import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/features/request/information/security_perfection/view_desktop.dart";
import "package:wcas_frontend/features/request/information/security_perfection/view_mobile.dart";

/// Responsive view for the Security Perfection feature.
class SecurityPerfectionView extends StatelessWidget {
  /// Creates a [SecurityPerfectionView] widget.
  const SecurityPerfectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SecurityPerfectionViewModel>(
      create: (context) => SecurityPerfectionViewModel()..init(context),
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
