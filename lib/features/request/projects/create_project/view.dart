import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class CreateProjectView extends StatelessWidget {
  final bool isCreateProject;
  const CreateProjectView({this.isCreateProject = true, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateProjectViewModel>(
        create: (context) => CreateProjectViewModel()
          ..init(context, isCreateProjectView: isCreateProject),
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            switch (sizingInformation.deviceScreenType) {
              case DeviceScreenType.desktop:
                return ViewDesktop(isCreateProject);

              case DeviceScreenType.tablet:
                return ViewDesktop(isCreateProject);

              case DeviceScreenType.mobile:
                return ViewMobile(isCreateProject);

              default:
                return ViewDesktop(isCreateProject);
            }
          },
        ));
  }
}
