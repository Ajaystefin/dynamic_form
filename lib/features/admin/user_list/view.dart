import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/admin/user_list/model.dart";
import "package:wcas_frontend/features/admin/user_list/view_desktop.dart";
// import 'view_mobile.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserListViewModel>(
      create: (context) => UserListViewModel()..init(context),
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
      ),
    );
  }
}
