import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/view_mobile.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

class CreateSecurityView extends StatelessWidget {
  const CreateSecurityView({this.security, this.pageMode, super.key});
  final Security? security;
  final PageMode? pageMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateSecurityViewModel>(
      create: (context) =>
          CreateSecurityViewModel()..init(security, pageModeFromArgs: pageMode),
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
