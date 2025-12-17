import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class RequestForFolView extends StatelessWidget {
  const RequestForFolView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestForFolViewModel>(
        create: (context) => RequestForFolViewModel()..init(context),
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            switch (sizingInformation.deviceScreenType) {
              case DeviceScreenType.desktop:
                return ViewDesktop();

              case DeviceScreenType.tablet:
                return ViewDesktop();

              case DeviceScreenType.mobile:
                return ViewMobile();

              default:
                return ViewDesktop();
            }
          },
        ));
  }
}
