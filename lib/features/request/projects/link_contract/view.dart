import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/features/request/projects/link_contract/view_desktop.dart";
import "package:wcas_frontend/features/request/projects/link_contract/view_mobile.dart";
import "package:wcas_frontend/models/request/project/project.dart";

class LinkContractView extends StatelessWidget {
  const LinkContractView({super.key, this.projectItem});
  final Project? projectItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LinkContractViewModel>(
      create: (context) => LinkContractViewModel()
        ..init(context, projectItemView: projectItem ?? Project()),
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
