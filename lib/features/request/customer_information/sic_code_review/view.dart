import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/view_desktop.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/view_mobile.dart";

class SicCodeReviewView extends StatelessWidget {
  const SicCodeReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SicCodeReviewViewModel>(
      create: (context) => SicCodeReviewViewModel()..init(context),
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
