import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class CcsysApprovalViewModel extends Cubit<CcsysApprovalState> {
  CcsysApprovalViewModel()
      : super(CcsysApprovalState(
          loaderStatus: LoadingStatus.loading,
        ));

  late RequestRepository repository;
  final HtmlEditorController controller = HtmlEditorController();
  List<Comment> comments = [];
  Comment? comment;
  List<Reference> applicationTypes = [];

  UserRole? userRole = Globals.user?.currentRole?.userRole;
  late String roleCode;
  Request requests = Globals.request!;

  Future<void> init(context) async {
    logger.i('initialising CcsysApprovalViewModel');
    repository = RequestRepository.instance;
    applicationTypes = [Reference(name: "CCSYS")];

    // Reassign userRole to ensure it's fresh from Globals
    userRole = Globals.user?.currentRole?.userRole;

    if (userRole != null) {
      getUserRole(userRole!);
    } else {
      logger.e('UserRole is null during init');
    }
  }

  void getUserRole(UserRole commentUserRole) {
    switch (commentUserRole) {
      case UserRole.relationshipOfficer:
        roleCode = ServerConstants.userRoleCode[UserRole.relationshipOfficer]!;
        break;
      case UserRole.relationshipManagerBussiness:
        roleCode = ServerConstants
            .userRoleCode[UserRole.relationshipManagerBussiness]!;
        break;
      case UserRole.businessUnitHead:
        roleCode = ServerConstants.userRoleCode[UserRole.businessUnitHead]!;
        break;
      case UserRole.creditCordinator:
        roleCode = ServerConstants.userRoleCode[UserRole.creditCordinator]!;
        break;
      default:
        roleCode = "";
    }
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
    ));
  }

  bool get showRecommendButton => Utils.checkRoles([
        UserRole.relationshipManagerBussiness,
        UserRole.relationshipOfficer,
        UserRole.commercialAreaManager,
        UserRole.teamLeaderBusiness,
        UserRole.segmentHeadBusiness,
      ]);

  bool get showApproveButton => Utils.checkRoles([
        UserRole.ccuMaker,
        UserRole.ccuChecker,
      ]);

  void onSavePress() {
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    // LayoutViewModel().goToNextRoute();
  }
}
