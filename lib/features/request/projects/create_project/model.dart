import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/create_project/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/create_project/state.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

/// ### Fields:
/// - `formKey`: A global key used to validate and manage the form state.
/// - `repository`: An instance of `ProjectRepository` used to interact with the
/// backend.
/// - `project`: The current `Project` object being created or edited.
/// - `contracts`: A list of `Contract` objects associated with the project.
///
/// ### Methods:
/// - `init(context)`: Initializes the repository and fetches project details.
/// - `getProjectDetailsData()`: Calls the API to retrieve project details and
/// updates the state.
/// - `onSave()`: Validates the form and saves the project details via the
/// repository.
/// - `onCreate()`: Validates the form and creates a new project via the
/// repository.
/// - `onDiscard()`: Resets the form and project data to default values.
class CreateProjectViewModel extends SafeCubit<CreateProjectState>
    with DraftMixin<CreateProjectViewModel> {
  CreateProjectViewModel()
      : super(CreateProjectState(loaderStatus: LoadingStatus.loading));

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // CreateFacilityArgs? facilityArgsFromFacility;
  late ProjectRepository repository;
  late Project project = Project();
  late List<Contract> contracts = [];
  bool isCreateProject = true;

  bool get canEdit => true; //(pageMode == PageMode.edit);
  PageMode pageMode = PageMode.na;

  // --------------------------------------------------
  // CONTROLLERS
  // --------------------------------------------------
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController ultimateOwnerController = TextEditingController();
  final TextEditingController ownerEntityController = TextEditingController();
  final TextEditingController ownerRimController = TextEditingController();
  final TextEditingController entityRimController = TextEditingController();
  final TextEditingController projectValueController = TextEditingController();
  final TextEditingController projectValueCurrentController =
      TextEditingController();
  final TextEditingController initialProjectValueController =
      TextEditingController();
  final TextEditingController projectSummaryController =
      TextEditingController();
  final TextEditingController projectCompletionController =
      TextEditingController();
  TextEditingController defectLiabilityEndDateController =
      TextEditingController();
  TextEditingController projectPeriodController = TextEditingController();

  // --------------------------------------------------
  // DATE STATE (DateTime is authoritative)
  // --------------------------------------------------
  DateTime? projectPeriod;
  DateTime? defectLiabilityEndDate;

  String? selectedDoctype;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.projects;

  @override
  String get draftFormKey => project.projectCode != null
      ? "${Routes.editViewProject}_${project.projectCode}"
      : "${Routes.editViewProject}_${project.projectName}";

  @override
  DraftHandler<CreateProjectViewModel> get draftHandler =>
      EditProjectDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the repository and fetches project details.
  Future<void> init(
    context, {
    required bool isCreateProjectView,
    required Project projectItemView,
  }) async {
    try {
      Globals.request?.applicationRefNo ?? "";

      debugPrint("------");
      debugPrint(Globals.request?.applicationRefNo);

      await AuthRepository.instance
          .updateRole(Globals.user!.currentRole!, request: Globals.request);

      repository = ProjectRepository.instance;
      isCreateProject = isCreateProjectView;

      if (isCreateProject) {
        pageMode = AuthRepository.getPageMode(RightConstants.createProject);
      } else {
        project = projectItemView;
        pageMode = AuthRepository.getPageMode(RightConstants.editProject);

        if (project.projectId != null) {
          await getContractDetailsData(project);
        } else {
          final Map<String, dynamic>? payload = project.projectCode != null &&
                  project.projectCode!.isNotEmpty
              ? {"projectCode": project.projectCode}
              : project.projectName != null && project.projectName!.isNotEmpty
                  ? {"projectName": project.projectName}
                  : null;
          if (payload != null) {
            final ({List<Project> projects}) result =
                await repository.getSearchProjectDetails(
              payload: payload,
              isProject: true,
            );
            if (result.projects.isNotEmpty) {
              project = result.projects.first;
              await getContractDetailsData(project);
            }
          } else {
            router.go(Routes.searchProject);
          }
        }
        if (canEdit) {
          registerDraftCallback();
          await loadDraftIfAvailable();
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

// --------------------------------------------------
  // SYNC MODEL FROM CONTROLLERS (for save + draft)
  // --------------------------------------------------
  void syncModelFromControllers() {
    project
      ..projectName = projectNameController.text
      ..projectUltimateOwnerName = ultimateOwnerController.text
      ..projectOwnerEntityName = ownerEntityController.text
      ..projectOwnerRimNo = int.tryParse(ownerRimController.text)
      ..projectOwnerEntityRimNo = int.tryParse(entityRimController.text)
      ..projectValue = projectValueController.text
      ..projectValueCurrent = projectValueCurrentController.text
      ..initialProjectValue = initialProjectValueController.text
      ..projectSummary = projectSummaryController.text
      ..projectCompletion = double.tryParse(projectCompletionController.text);
  }

  // --------------------------------------------------
  // SYNC CONTROLLERS FROM MODEL (for draft restore)
  // --------------------------------------------------
  void syncControllersFromModel() {
    projectNameController.text = project.projectName ?? "";
    ultimateOwnerController.text = project.projectUltimateOwnerName ?? "";
    ownerEntityController.text = project.projectOwnerEntityName ?? "";
    ownerRimController.text = project.projectOwnerRimNo?.toString() ?? "";
    entityRimController.text =
        project.projectOwnerEntityRimNo?.toString() ?? "";
    projectValueController.text = project.projectValue ?? "";
    projectValueCurrentController.text = project.projectValueCurrent ?? "";
    initialProjectValueController.text =
        project.initialProjectValue ?? "Not Available";
    projectSummaryController.text = project.projectSummary ?? "";
    projectCompletionController.text =
        project.projectCompletion?.toString() ?? "";
  }

  @override
  Future<void> close() {
    projectNameController.dispose();
    ultimateOwnerController.dispose();
    ownerEntityController.dispose();
    ownerRimController.dispose();
    entityRimController.dispose();
    projectValueController.dispose();
    projectValueCurrentController.dispose();
    initialProjectValueController.dispose();
    projectSummaryController.dispose();
    projectCompletionController.dispose();
    unregisterDraftCallback();
    return super.close();
  }

  void onProjectPeriodSelected(DateTime? date) {
    projectPeriod = date;
    projectPeriodController.text = DateTimeUtils.formatMonthYear(date);
  }

  void onLiabilityEndDateSelected(DateTime? date) {
    defectLiabilityEndDate = date;
    defectLiabilityEndDateController.text = DateTimeUtils.formatMonthYear(date);
  }

  /// Fetches project details from the repository and updates the state.
  Future<void> getContractDetailsData(Project? project) async {
    try {
      contracts = await repository.getProjectContractDetails(project);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      router.go(Routes.searchProject);
    }
  }

  /// Validates the form and saves the project details.
  Future<void> onSave(BuildContext context, bool isValidate) async {
    formKey.currentState?.save();
    if (!isValidate) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast("common.validation.emptyFields".tr());
      return;
    }

    try {
      project.projectCode = await repository.saveProjectDetails(
        isCreateProject: isCreateProject,
        project: project,
      );

      if (isCreateProject) {
        AlertManager()
            .showSuccessToast("project.createNewProject.projectSaved".tr());
      } else {
        unawaited(deleteDraft());
        if (context.mounted) {
          showDialogSuccessAppRefNo(context, isCreate: false, project: project);
        }
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> onCreate(BuildContext context, bool isValidate) async {
    formKey.currentState?.save();
    if (!isValidate) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast("common.validation.emptyFields".tr());
      return;
    }

    try {
      final String? message = await repository.saveProjectDetails(
        isCreateProject: isCreateProject,
        project: project,
      );

      isCreateProject = false;
      if (message != null &&
          message.toString() != "project.createNewProject.projectSaved".tr()) {
        project.projectCode = message;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      // router.go(Routes.editViewProject, extra: project);
      if (context.mounted) {
        showDialogSuccessAppRefNo(context, isCreate: true, project: project);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Resets the form and project data to default values.
  void onDiscard() {
    formKey.currentState?.reset();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    router.go(Routes.searchProject);
  }

  void onPressedLinkContract() {
    if (!isCreateProject) {
      if (canEdit) {
        unawaited(Globals.onAutoSave?.call());
      }
    }
    router.go(Routes.linkContract, extra: project);
  }

  void onPressedContractCodeInTable(int i) {
    if (!isCreateProject) {
      if (canEdit) {
        unawaited(Globals.onAutoSave?.call());
      }
    }
    router.go(
      Routes.editContract,
      extra: {
        "contract": contracts[i], // or contracts if it's already a Contract
        "project": project, // your Project instance
      },
    );
  }

  Future<void> onGenerateSummary(String? docType) async {
    try {
      await repository.generateProjectExposureSummary(
        docType,
        project.projectCode,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> onBacktoRequestStatusPressed(BuildContext context) async {
    if ((Globals.request?.applicationRefNo ?? "").isNotEmpty) {
      if (context.mounted) {
        context.go(Routes.facilitySummaryView);
      }
    } else {
      if (!isCreateProject) {
        if (canEdit) {
          unawaited(Globals.onAutoSave?.call());
        }
      }
      if (context.mounted) {
        isCreateProject
            ? router.go(Routes.searchProject)
            : router.go(Routes.searchProject);
        //context.go(Routes.home);
      }
    }
  }

  String? projectCodeValidator(String? value) {
    final v = (value ?? "").trim();
    if (v.isEmpty) return "project.code.required".tr();
    if (v.length != 16) return "project.code.lengthInvalid".tr(args: ["16"]);
    final regex = RegExp(r"^\d{4}(0[1-9]|1[0-2])PROJ\d{6}$");
    if (!regex.hasMatch(v)) return "project.code.formatInvalid".tr();
    return null;
  }

  void showDialogSuccessAppRefNo(
    BuildContext context, {
    bool? isCreate,
    Project? project,
  }) {
    if (isCreate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogHelper.showCustomDialog(
          barrierDismissible: false,
          onClosePressed: () {
            context.pop();
            if (isCreate) {
              router.go(
                Routes.editViewProject, extra: project,

                // extra: {
                //   'project': project,
                //   'facilityArgs': args?.facilityArgs, // pass-through, nullable
                // },
              );
            }
          },
          width: Scale.scaleHorizontally(350),
          context: context,
          title: "requestInformation.requestInformation.confirmation".tr(),
          content: CustomSelectableText(
            text: isCreate
                ? "project.createNewProject.projectsuccessCreate".tr(
                    namedArgs: {
                      "projectCode": project?.projectCode.toString() ?? "",
                    },
                  )
                : "project.createNewProject.projectsuccessViewEdit".tr(
                    namedArgs: {
                      "projectCode": project?.projectCode.toString() ?? "",
                    },
                  ),
          ),
          actions: [
            CustomButton(
              label: "requestInformation.requestInformation.okay".tr(),
              onPressed: () {
                context.pop();
                if (isCreate) {
                  router.go(Routes.editViewProject, extra: project);
                }
              },
            ),
          ],
        );
      });
    } else {
      AlertManager().showSuccessToast("common.dataSaveSuccess".tr());
    }
  }

  //The Business group users, namely RMB, TLB, RMB, CAM, SHB (Business Unit
  //Heads) should be able to create project.
  //Credit team user (Credit Coordinator, Credit Analyst, CC Proxy, BOD Proxy)
  //shall be able to view the projects but cannot edit.
  bool editAccessRolesCheck() {
    return (Utils.checkRoles([
      UserRole.relationshipManager,
      UserRole.relationshipOfficer,
      UserRole.relationshipManagerBussiness,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]))
        ? true
        : false;
  }

  bool viewAccessRolesCheck() {
    return (Utils.checkRoles([
      UserRole.creditCordinator,
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
    ]))
        ? true
        : false;
  }
}

class ProjectCodeGenerator {
  /// Format: YYYYMMPROJ######
  /// Example: 202504PROJ000001
  static String generate({required int serial, DateTime? now}) {
    final dt = now ?? DateTime.now();
    final year = dt.year.toString().padLeft(4, "0");
    final month = dt.month.toString().padLeft(2, "0");
    final serialStr = serial.toString().padLeft(6, "0");
    const prj = "PROJ";
    return "$year$month$prj$serialStr";
  }

  /// Simple next serial (replace with real logic if you fetch last serial from
  /// backend)
  static String generateNext({int? lastSerial, DateTime? now}) {
    final nextSerial = (lastSerial ?? 0) + 1;
    return generate(serial: nextSerial, now: now);
  }

  static bool isValid(String code) {
    final regex = RegExp(r"^\d{4}(0[1-9]|1[0-2])PROJ\d{6}$");
    return regex.hasMatch(code);
  }
}
