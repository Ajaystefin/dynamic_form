import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/admin/role_right_mapping/model.dart';
import 'package:wcas_frontend/features/admin/role_right_mapping/state.dart';
import 'package:wcas_frontend/features/admin/role_right_mapping/widgets/access_right_table.dart';

class BuildReferenceTable extends StatelessWidget {
  final RoleRightMappingState state;
  final RoleRightMappingViewModel viewModel;
  const BuildReferenceTable(
      {super.key, required this.state, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    switch (state.referencesLoaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Container();
      default:
        return AccessRightTableField(
          viewModel: viewModel,
        );
    }
  }
}
