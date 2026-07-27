import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_list/model.dart";
import "package:wcas_frontend/features/admin/user_list/state.dart";

/// Table widget that displays and filters the user list.
class UserListTable extends StatelessWidget {
  /// Creates a [UserListTable].
  const UserListTable({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used to manage user list data and filtering.
  final UserListViewModel viewModel;

  /// Current state of the user list screen.
  final UserListState state;

  /// Builds the user list table.
  @override
  Widget build(BuildContext context) {
    switch (state.tableLoader) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      default:
        return CustomRawTable(
          rowsPerPage: 10,
          key: UniqueKey(),
          columns: getTableColumns(),
          rows: getRows(),
          columnSpacing: 90.w,
          columnHeaderHeight: 30.w,
        );
    }
  }

  /// Returns the table rows including search fields and user rows.
  List<List<Widget>> getRows() {
    final List<List<Widget>> widgets = [
      getSearchFields(),
      ...List.generate(
          viewModel.filteredUsers == null ? 0 : viewModel.filteredUsers!.length,
          (index) {
        final roles = viewModel.getRoleNamesForUser(index).join(", ");
        return [
          TextButton(
            onPressed: () {
              // navigation to details page
              if (viewModel.filteredUsers!.isNotEmpty) {
                router.go(
                  Routes.adminUserDetails,
                  extra: viewModel.filteredUsers?[index],
                );
              }
            },
            child: Text(
              viewModel.filteredUsers?[index].id ?? "",
              style: const TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.highlightedTextColor,
                color: AppColors.highlightedTextColor,
              ),
            ),
          ),
          Text(
            viewModel.filteredUsers?[index].name ?? "",
          ),
          Text(
            roles,
          ),
        ];
      }),
    ];
    return widgets;
  }

  /// Returns the table column definitions.
  List<TableColumn> getTableColumns() {
    final columnNames = [
      TableColumn(
        width: 60.w,
        label: Text("admin.userManagementList.userTableUserId".tr()),
      ),
      TableColumn(
        width: 180.w,
        label: Text("admin.userManagementList.userTableUsername".tr()),
      ),
      TableColumn(
        width: 180.w,
        label: Text("admin.userManagementList.userTableUserRoles".tr()),
      ),
    ];

    return columnNames;
  }

  /// Returns the search field row used to filter the table.
  List<Widget> getSearchFields() {
    return [
      CustomTextField(
        initialValue: viewModel.userIdSearch,
        onSubmitted: (value) {
          viewModel.userIdSearch = value;
          viewModel.filterTable();
        },
      ),
      CustomTextField(
        initialValue: viewModel.userNameSearch,
        onSubmitted: (value) {
          viewModel.userNameSearch = value;
          viewModel.filterTable();
        },
      ),
      CustomTextField(
        initialValue: viewModel.userRoleSearch,
        onSubmitted: (value) {
          viewModel.userRoleSearch = value;
          viewModel.filterTable();
        },
      ),
    ];
  }
}
