import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';
import 'package:wcas_frontend/models/request/project/project.dart';
import 'package:wcas_frontend/repositories/project_repository.dart';
import 'state.dart';

/// ### Fields:
/// - `formKey`: A global key used to validate and manage the form state.
/// - `repository`: An instance of `ProjectRepository` used to interact with the backend.
/// - `project`: The current `Project` object being created or edited.
/// - `contracts`: A list of `Contract` objects associated with the project.
///
/// ### Methods:
/// - `init(context)`: Initializes the repository and fetches project details.
/// - `getProjectDetailsData()`: Calls the API to retrieve project details and updates the state.
/// - `onSave()`: Validates the form and saves the project details via the repository.
/// - `onCreate()`: Validates the form and creates a new project via the repository.
/// - `onDiscard()`: Resets the form and project data to default values.
class CreateProjectViewModel extends Cubit<CreateProjectState> {
  CreateProjectViewModel()
      : super(CreateProjectState(loaderStatus: LoadingStatus.loading));

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late ProjectRepository repository;
  late Project project = Project();
  late List<Contract> contracts = [];
  bool isCreateProject = true;

  /// Initializes the repository and fetches project details.
  void init(context, {required bool isCreateProjectView}) async {
    repository = ProjectRepository.instance;
    isCreateProject = isCreateProjectView;
    await getProjectDetailsData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches project details from the repository and updates the state.
  Future<void> getProjectDetailsData() async {
    try {
      project = await repository.getProjectDetails();
      contracts = project.contract ?? [];
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Validates the form and saves the project details.
  Future<void> onSave(bool isValidate) async {
    if (!isValidate) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast("common.validation.emptyFields".tr());

      return;
    }
    if(isCreateProject==false)
         { AlertManager().showSuccessToast(
          "Project details have been revised successfully against Project Code ${project.code} and linked with Project Code ${project.code}"
          
          );
          return;
          }

    await repository.saveProjectDetails(
        isCreateProject: false, project: project);
  }

 Future<void> onCreate(BuildContext context, bool isValidate) async {
  if (!isValidate) {
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    AlertManager().showFailureToast("common.validation.emptyFields".tr());
    return;
  }

  try {
    final message = await repository.saveProjectDetails(
      isCreateProject: true,
      project: project,
    );

    isCreateProject = false;

    AlertManager().showSuccessToast(
      "$message against Project Code ${project.code}"
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    router.go(Routes.editViewProject);
  } catch (e) {
    AlertManager().showFailureToast(e.toString());
    emit(state.copyWith(loaderStatus: LoadingStatus.error));
  }
}

  /// Resets the form and project data to default values.
  void onDiscard() {
    project = Project(code: '202504PROJ000001');
    formKey.currentState?.reset();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onPressedLinkContract() {
  router.go(Routes.linkContract);
  }

  void onGeneratePdf() {}

  void onGenerateWord() {}
}
