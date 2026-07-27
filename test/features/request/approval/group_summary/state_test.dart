import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/group_summary/state.dart";

void main() {
  group("GroupSummaryState", () {
    GroupSummaryTabs nonDefaultTab() {
      return GroupSummaryTabs.values.firstWhere(
        (tab) => tab != GroupSummaryTabs.ownershipCorporateStructure,
        orElse: () => GroupSummaryTabs.ownershipCorporateStructure,
      );
    }

    test("constructor uses default values", () {
      const state = GroupSummaryState();

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(
        state.activeTab,
        GroupSummaryTabs.ownershipCorporateStructure,
      );
    });

    test("constructor sets custom loaderStatus and activeTab", () {
      final tab = nonDefaultTab();

      final state = GroupSummaryState(
        loaderStatus: LoadingStatus.loaded,
        activeTab: tab,
      );

      expect(state.loaderStatus, LoadingStatus.loaded);
      expect(state.activeTab, tab);
    });

    test("copyWith updates loaderStatus only", () {
      const state = GroupSummaryState();

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(
        updatedState.activeTab,
        GroupSummaryTabs.ownershipCorporateStructure,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(
        state.activeTab,
        GroupSummaryTabs.ownershipCorporateStructure,
      );
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates activeTab only", () {
      final tab = nonDefaultTab();
      const state = GroupSummaryState();

      final updatedState = state.copyWith(
        activeTab: tab,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loading);
      expect(updatedState.activeTab, tab);

      expect(state.loaderStatus, LoadingStatus.loading);
      expect(
        state.activeTab,
        GroupSummaryTabs.ownershipCorporateStructure,
      );
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates both loaderStatus and activeTab", () {
      final tab = nonDefaultTab();
      const state = GroupSummaryState();

      final updatedState = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        activeTab: tab,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.activeTab, tab);
    });

    test("copyWith keeps existing values when no values are provided", () {
      final tab = nonDefaultTab();

      final state = GroupSummaryState(
        loaderStatus: LoadingStatus.loaded,
        activeTab: tab,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.activeTab, tab);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith keeps existing loaderStatus when loaderStatus is null", () {
      final tab = nonDefaultTab();

      final state = GroupSummaryState(
        loaderStatus: LoadingStatus.loaded,
        activeTab: tab,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.activeTab, tab);
    });

    test("copyWith keeps existing activeTab when activeTab is null", () {
      final tab = nonDefaultTab();

      final state = GroupSummaryState(
        loaderStatus: LoadingStatus.loaded,
        activeTab: tab,
      );

      final updatedState = state.copyWith();

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.activeTab, tab);
    });
  });
}
