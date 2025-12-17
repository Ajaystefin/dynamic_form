import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';

import 'state.dart';

class UserListViewModel extends Cubit<UserListState> {
  UserListViewModel()
      : super(UserListState(loaderStatus: LoadingStatus.loading));
  late AdminRepository repository;

  Future<void> init(context) async {
    Globals.request = null;
    logger.i('initialising UserListViewModel');
    repository = AdminRepository.instance;
    await getUserList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// for display filtered table contents
  List<User>? filteredUsers = [];
  List<User>? users = [];
  //userID search value
  String? userIdSearch;
  // userRole search value
  String? userRoleSearch;
  //user name search value
  String? userNameSearch;
// to fetch user list from api
  Future<void> getUserList() async {
    try {
      users = await repository.getUserList();
      filteredUsers =
          (users ?? []).map((user) => User.fromJson(user.toJson())).toList();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      AlertManager().showFailureToast(e.toString());
      // logger.e('Error fetching reference data: $e');
    }
  }

// filter the table details w.r.t the search fields
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
        return user.availableRoles?.any((role) =>
                role.name
                    ?.toLowerCase()
                    .contains(userRoleSearch!.toLowerCase()) ??
                false) ??
            false;
      }).toList();
    }

    logger.i(filteredUsers);
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  List<String> getRoleNamesForUser(int index) {
    if (filteredUsers == null || index >= filteredUsers!.length) return [];

    final user = filteredUsers![index];
    return user.availableRoles
            ?.where((role) => role.name?.trim().isNotEmpty ?? false)
            .map((role) => role.name!.trim())
            .toList() ??
        [];
  }
}
