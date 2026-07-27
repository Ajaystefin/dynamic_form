import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/view_desktop.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/view_mobile.dart";

/// Entry widget for the CCSYS customer information screen.
class CCSYSCustomerInformation extends StatelessWidget {
  /// Creates a [CCSYSCustomerInformation] widget.
  const CCSYSCustomerInformation({super.key});

  /// Builds the CCSYS customer information screen with responsive layout.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomerInformationViewModel>(
      create: (context) => CustomerInformationViewModel()..init(context),
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
