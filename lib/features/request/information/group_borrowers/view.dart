import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/information/group_borrowers/model.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/view_desktop.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/view_mobile.dart";

class GroupBorrowersView extends StatelessWidget {
  const GroupBorrowersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupBorrowersViewModel>(
      create: (context) => GroupBorrowersViewModel()..init(context),
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
