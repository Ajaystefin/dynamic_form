import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/credit_assessment_fi/model.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/view_desktop.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/view_mobile.dart";

class CreditAssessmentFIView extends StatelessWidget {
  const CreditAssessmentFIView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreditAssessmentFIViewModel>(
      create: (context) => CreditAssessmentFIViewModel()..init(context),
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
