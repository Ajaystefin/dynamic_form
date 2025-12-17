import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/models/login/user.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class UserDetailView extends StatelessWidget {
  final User? userListItem;
  const UserDetailView({super.key, required this.userListItem});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
              const PreviousFocusIntent(),
        },
        child: Actions(
            actions: <Type, Action<Intent>>{
              NextFocusIntent: CallbackAction<NextFocusIntent>(
                onInvoke: (intent) {
                  FocusScope.of(context).nextFocus();
                  return null;
                },
              ),
              PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
                onInvoke: (intent) {
                  FocusScope.of(context).previousFocus();
                  return null;
                },
              ),
            },
            child: BlocProvider<UserDetailViewModel>(
                create: (context) =>
                    UserDetailViewModel()..init(context, userListItem),
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
                ))));
  }
}
