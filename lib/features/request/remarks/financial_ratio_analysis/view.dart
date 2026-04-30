import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/view_desktop.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/view_mobile.dart";

class FinancialRatioAnalysisView extends StatelessWidget {
  const FinancialRatioAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialRatioAnalysisViewModel>(
      create: (context) => FinancialRatioAnalysisViewModel()..init(context),
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

//1.issues in financial raio and analysis useradded rows not retained (ater
//adding user can delete)

//.strategy comment id guarantor and data retaining issue if present when user
//come for first time and data is in api only that case

//on add gurarntor remarks data retainging issue

//remarks added by user not added in save guarantor payload

//delete api by entity id

//add row flow in guarantor

//1stcomment section data retaingin issue

//2nd last column issue dat retain

//add guarantor case
