import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/view_desktop.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/view_mobile.dart";

/// Entry view for the customer information screen.
class CustomerInfoView extends StatelessWidget {
  /// Creates a customer information view.
  const CustomerInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomerInfoViewModel>(
      create: (context) => CustomerInfoViewModel()..init(context),
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
