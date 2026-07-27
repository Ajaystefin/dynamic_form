import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/view_desktop.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/view_mobile.dart";

/// Entry point for the Fee Structure screen.
class FeeStructureView extends StatelessWidget {
  /// Creates a fee structure view.
  const FeeStructureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeeStructureViewModel>(
      create: (context) => FeeStructureViewModel()..init(context),
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
