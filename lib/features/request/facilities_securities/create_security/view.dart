import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class CreateSecurityView extends StatelessWidget {
  final Security? security;
  const CreateSecurityView({this.security, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateSecurityViewModel>(
        create: (context) => CreateSecurityViewModel()..init(security),
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
        ));
  }
}
