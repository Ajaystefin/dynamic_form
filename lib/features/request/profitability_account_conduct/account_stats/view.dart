import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/view_desktop.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/view_mobile.dart";

class AccountStatsView extends StatelessWidget {
  const AccountStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountStatsViewModel>(
      create: (context) => AccountStatsViewModel()..init(context),
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
