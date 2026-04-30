import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/features/request/information/create_request/view_desktop.dart";
import "package:wcas_frontend/features/request/information/create_request/view_mobile.dart";

class CreateRequestView extends StatelessWidget {
  const CreateRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateRequestViewModel>(
      create: (context) => CreateRequestViewModel()..init(),
      child: Shortcuts(
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
        ),
      ),
    );
  }
}
