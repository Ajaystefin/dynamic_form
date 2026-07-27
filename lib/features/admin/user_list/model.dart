import "package:flutter/material.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_list/state.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

/// View model for managing the admin user list screen.
class UserListViewModel extends SafeCubit<UserListState> {
  /// Creates a [UserListViewModel].
  UserListViewModel()
      : super(
          const UserListState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for admin user list operations.
  late AdminRepository repository;

  /// Initializes the user list view model and loads user data.
  Future<void> init(BuildContext context) async {
    Globals.request = null;
    logger.i("initialising UserListViewModel");
    repository = AdminRepository.instance;
    await getUserList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Filtered users displayed in the table.
  List<User>? filteredUsers = [];

  /// Complete list of users fetched from the API.
  List<User>? users = [];

  /// Search value entered for user ID.
  String? userIdSearch;

  /// Search value entered for user role.
  String? userRoleSearch;

  /// Search value entered for user name.
  String? userNameSearch;

  /// Fetches the user list from the API.
  Future<void> getUserList() async {
    try {
      users = await repository.getUserList();
      filteredUsers =
          (users ?? []).map((user) => User.fromJson(user.toJson())).toList();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      AlertManager().showFailureToast(e.toString());
      // logger.e('Error fetching reference data: $e');
    }
  }

  /// Filters the table data based on entered search field values.
  void filterTable() {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));

    // Start with a full copy of the users list
    filteredUsers =
        (users ?? []).map((user) => User.fromJson(user.toJson())).toList();

    // Apply filters if search fields are not empty
    if (userIdSearch != null && userIdSearch!.isNotEmpty) {
      filteredUsers = filteredUsers?.where((user) {
        return user.id?.toLowerCase().contains(userIdSearch!.toLowerCase()) ??
            false;
      }).toList();
    }

    if (userNameSearch != null && userNameSearch!.isNotEmpty) {
      filteredUsers = filteredUsers?.where((user) {
        return user.name
                ?.toLowerCase()
                .contains(userNameSearch!.toLowerCase()) ??
            false;
      }).toList();
    }

    if (userRoleSearch != null && userRoleSearch!.isNotEmpty) {
      filteredUsers = filteredUsers?.where((user) {
        return user.availableRoles?.any(
              (role) =>
                  role.name
                      ?.toLowerCase()
                      .contains(userRoleSearch!.toLowerCase()) ??
                  false,
            ) ??
            false;
      }).toList();
    }

    logger.i(filteredUsers);
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  /// Returns role names for the filtered user at the provided index.
  List<String> getRoleNamesForUser(int index) {
    if (filteredUsers == null || index >= filteredUsers!.length) {
      return [];
    }

    final user = filteredUsers![index];
    return user.availableRoles
            ?.where((role) => role.name?.trim().isNotEmpty ?? false)
            .map((role) => role.name!.trim())
            .toList() ??
        [];
  }
}
