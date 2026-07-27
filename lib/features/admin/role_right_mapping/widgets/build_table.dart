import "package:flutter/material.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/state.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/widgets/access_right_table.dart";

/// Builds the reference/access rights table based on the current state.
class BuildReferenceTable extends StatelessWidget {
  /// Creates a [BuildReferenceTable].
  const BuildReferenceTable({
    required this.state,
    required this.viewModel,
    super.key,
  });

  /// Current role right mapping state.
  final RoleRightMappingState state;

  /// View model containing role right mapping data.
  final RoleRightMappingViewModel viewModel;

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
