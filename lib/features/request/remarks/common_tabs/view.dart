import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class CommonTabsView extends StatelessWidget {
  final RemarksTabs? tab;
  const CommonTabsView({super.key, this.tab});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommonTabsViewModel>(
        create: (context) => CommonTabsViewModel()..init(context, tab: tab),
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
