import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/view_desktop.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/view_mobile.dart";

class AccountConductView extends StatelessWidget {
  const AccountConductView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountConductViewModel>(
      create: (context) => AccountConductViewModel()..init(context),
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
