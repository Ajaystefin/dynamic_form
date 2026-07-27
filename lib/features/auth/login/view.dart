import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/auth/login/model.dart";
import "package:wcas_frontend/features/auth/login/view_desktop.dart";
import "package:wcas_frontend/features/auth/login/view_mobile.dart";

/// Login screen entry point that renders the appropriate layout
/// based on the current device type.
class LoginView extends StatefulWidget {
  /// Creates a [LoginView].
  const LoginView({super.key});

  @override
  /// Creates the state for [LoginView].
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginViewModel>(
      create: (context) => LoginViewModel()..init(),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewMobile();

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
