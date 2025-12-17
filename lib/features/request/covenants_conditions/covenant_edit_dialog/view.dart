import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class CovenantEditDialogView extends StatelessWidget {
  final bool? isNew;
  final Covenant? covenant;

  const CovenantEditDialogView({
    super.key,
    this.isNew,
    this.covenant,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CovenantEditDialogViewModel>(
        create: (context) => CovenantEditDialogViewModel(covenant, isNew)
          ..init(
            context,
            isNew,
            covenant,
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
        ));
  }
}
