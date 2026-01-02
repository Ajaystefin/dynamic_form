import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class CommonTabsViewModel extends Cubit<CommonTabsState> {
  /// Constructor that initializes the view model with a loading state
  CommonTabsViewModel()
      : super(CommonTabsState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  final Map<RemarksTabs, UnifiedEditorController> _rteControllers = {};
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Customer? selectedCustomer =
      Globals.selectedCustomer ?? Globals.request?.customers?.first;
  Comment? commentData = Comment();
  final ScrollController scrollController = ScrollController();

  /// Get the controller for a specific tab
  UnifiedEditorController getRteController(RemarksTabs tab) {
    return _rteControllers.putIfAbsent(
      tab,
      () => UnifiedEditorController(),
    );
  }

  List<RemarksTabs> otherRemarksTabs = [
    RemarksTabs.feeStructure,
    RemarksTabs.guarantorFinancials,
    RemarksTabs.financialRatiosAndAnalysis
  ];

  /// Getter that returns the current global request instance
  Request get request {
    return Globals.request!;
  }

  List<RemarksTabs> showAsteriskTabs = [];

  /// Determines if the current active tab requires validation based on asterisk tabs
  bool get shouldValidateField => showAsteriskTabs.contains(state.activeTab);

  PageMode pageMode = PageMode.na;

  bool get isReadOnlyMode => pageMode == PageMode.view;

  /// Initializes the view model with optional tab parameter and loads initial data
  Future<void> init(context, {RemarksTabs? tab}) async {
    logger.i('initialising CommonTabsViewModel');
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);

    if (tab != null) {
      emit(state.copyWith(activeTab: tab));
    }
    repository = RequestRepository.instance;
    await setAsterisks();
    await getRemarks();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Sets which tabs should display asterisks based on business segment and customer type
  Future<void> setAsterisks() async {
    showAsteriskTabs =
        Utils.getMandatoryRemarksTabs(selectedCustomer ?? Customer());
  }

  /// Fetches remarks data for the selected customer and active tab from the repository
  Future<void> getRemarks() async {
    try {
      commentData = await repository.getRemarkStrategyData(
              selectedCustomer,
              ServerConstants.commentTypeId[CommentsType.remarks],
              ServerConstants.remarksTabId[state.activeTab]) ??
          Comment();
    } catch (e) {
      commentData = Comment();
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Changes the active tab and loads corresponding data or navigates to external routes
  void changeTab(RemarksTabs tab) async {
    if (otherRemarksTabs.contains(tab)) {
      router.go(TabConstants.remarksRoutes[tab]!);
    } else {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading, activeTab: tab));
      await getRemarks();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Handles customer selection change by updating selected customer and reloading data
  Future<void> onChangeCustomer(Customer customer) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    selectedCustomer = customer;
    Globals.selectedCustomer = customer;
    setAsterisks();
    await getRemarks();
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
    ));
  }

  /// Saves the comment data to the repository with validation and optional navigation
  Future<void> onSavePress(
      {required BuildContext context, bool shouldNavigate = false}) async {
    try {
      String richText = await getRteController(state.activeTab).getText();

      if (shouldValidateField && richText.isEmpty) {
        AlertManager().showFailureToast(
            'common.validation.pleaseEnter'.tr() + "common.comment".tr());
        return;
      }

      emit(state.copyWith(
          buttonLoaderStatus: LoadingStatus.loading,
          shouldNavigate: shouldNavigate));
      Comment comment = Comment.fromInputData(
        strategyComment: richText,
        categoryType: state.activeTab.name,
        type: CommentsType.remarks,
        entityType: EntityIdentifier.remarks,
        categoryId: ServerConstants.remarksTabId[state.activeTab],
        rimNo: selectedCustomer?.customerRimNo,
      );
      if (richText.isNotEmpty) {
        await repository.saveRemarkStrategyData(selectedCustomer, comment);
        AlertManager().showSuccessToast("common.commentSaveSuccess".tr());
      }
      if (shouldNavigate) {
        navigate();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(buttonLoaderStatus: LoadingStatus.loaded));
    }
  }

  /// Navigates to the next tab in sequence or to the next route if at the end
  void navigate() {
    bool isCurrentRouteFound = false;
    for (MapEntry<RemarksTabs, String> entry
        in TabConstants.remarksRoutes.entries) {
      if (isCurrentRouteFound) {
        // can move to next tab/route
        changeTab(entry.key);
        return;
      }
      if (entry.key == state.activeTab) {
        isCurrentRouteFound = true;
      }
    }
    LayoutViewModel().goToNextRoute();
  }
}
