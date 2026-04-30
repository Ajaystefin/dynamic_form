import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/view_desktop.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/view_mobile.dart";

class ShareOfWalletView extends StatelessWidget {
  const ShareOfWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShareOfWalletViewModel>(
      create: (context) => ShareOfWalletViewModel()..init(context),
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
