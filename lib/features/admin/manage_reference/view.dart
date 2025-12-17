import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'model.dart';
import 'view_desktop.dart';

class ManageReferenceView extends StatelessWidget {
  const ManageReferenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManageReferenceViewModel>(
        create: (context) => ManageReferenceViewModel()..init(context),
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            switch (sizingInformation.deviceScreenType) {
              case DeviceScreenType.desktop:
                return const ViewDesktop();

              case DeviceScreenType.tablet:
                return const ViewDesktop();

              case DeviceScreenType.mobile:
                return const ViewDesktop();

              default:
                return const ViewDesktop();
            }
          },
        ));
  }
}
