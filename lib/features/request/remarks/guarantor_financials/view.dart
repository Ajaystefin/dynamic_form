import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/view_desktop.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/view_mobile.dart";

class GuarantorFinancialView extends StatelessWidget {
  const GuarantorFinancialView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GuarantorFinancialViewModel>(
      create: (context) => GuarantorFinancialViewModel()..init(context),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return ViewDesktop();

            case DeviceScreenType.tablet:
              return ViewDesktop();

            case DeviceScreenType.mobile:
              return ViewMobile();

            default:
              return ViewDesktop();
          }
        },
      ),
    );
  }
}
