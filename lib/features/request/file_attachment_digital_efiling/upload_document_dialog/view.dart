import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class UploadDocumentDialogView extends StatelessWidget {
  final String groupRim;
  final String customerRim;
  final String applicationId;
  final List<String>? rimList;

  const UploadDocumentDialogView(
      {super.key,
      required this.groupRim,
      required this.customerRim,
      required this.applicationId,
      this.rimList});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UploadDocumentDialogViewModel>(
        create: (context) => UploadDocumentDialogViewModel()
          ..init(context,
              groupRim: groupRim,
              customerRim: customerRim,
              applicationId: applicationId,
              rimsList: rimList),
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
