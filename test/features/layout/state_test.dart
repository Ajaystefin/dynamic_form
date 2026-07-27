import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/layout/state.dart";

void main() {
  group("LayoutState", () {
    test("constructs with provided values", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      expect(state.currentRoute, "/dashboard");
      expect(state.hideSideMenu, false);
    });

    test("copyWith updates currentRoute when value is provided", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      final updatedState = state.copyWith(
        currentRoute: "/requests",
      );

      expect(updatedState.currentRoute, "/requests");
      expect(updatedState.hideSideMenu, false);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates hideSideMenu when value is provided", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      final updatedState = state.copyWith(
        hideSideMenu: true,
      );

      expect(updatedState.currentRoute, "/dashboard");
      expect(updatedState.hideSideMenu, true);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith updates both currentRoute and hideSideMenu", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      final updatedState = state.copyWith(
        currentRoute: "/approval",
        hideSideMenu: true,
      );

      expect(updatedState.currentRoute, "/approval");
      expect(updatedState.hideSideMenu, true);
      expect(updatedState, isNot(same(state)));
    });

    test("copyWith keeps existing values when no values are provided", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      final copiedState = state.copyWith();

      expect(copiedState.currentRoute, "/dashboard");
      expect(copiedState.hideSideMenu, false);
      expect(copiedState, isNot(same(state)));
    });

    test("copyWith keeps false hideSideMenu when null is provided", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      final copiedState = state.copyWith();

      expect(copiedState.currentRoute, "/dashboard");
      expect(copiedState.hideSideMenu, false);
    });

    test("copyWith keeps true hideSideMenu when null is provided", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: true,
      );

      final copiedState = state.copyWith();

      expect(copiedState.currentRoute, "/dashboard");
      expect(copiedState.hideSideMenu, true);
    });

    test("toString returns expected formatted value", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: true,
      );

      expect(
        state.toString(),
        "LayoutState(currentRoute: /dashboard, hideSideMenu: true)",
      );
    });

    test("equality returns true for identical instance", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      expect(state == state, isTrue);
    });

    test("equality returns true when values are same", () {
      const state1 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      const state2 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      expect(state1 == state2, isTrue);
      expect(state1, equals(state2));
    });

    test("equality returns false when currentRoute is different", () {
      const state1 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      const state2 = LayoutState(
        currentRoute: "/requests",
        hideSideMenu: false,
      );

      expect(state1 == state2, isFalse);
      expect(state1, isNot(equals(state2)));
    });

    test("equality returns false when hideSideMenu is different", () {
      const state1 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      const state2 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: true,
      );

      expect(state1 == state2, isFalse);
      expect(state1, isNot(equals(state2)));
    });

    test("equality returns false when compared with different object type", () {
      const state = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      expect(state.toString() == "/dashboard", isFalse);
    });

    test("hashCode is same when values are same", () {
      const state1 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      const state2 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      expect(state1.hashCode, state2.hashCode);
    });

    test("hashCode is different when currentRoute is different", () {
      const state1 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      const state2 = LayoutState(
        currentRoute: "/requests",
        hideSideMenu: false,
      );

      expect(state1.hashCode, isNot(state2.hashCode));
    });

    test("hashCode is different when hideSideMenu is different", () {
      const state1 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: false,
      );

      const state2 = LayoutState(
        currentRoute: "/dashboard",
        hideSideMenu: true,
      );

      expect(state1.hashCode, isNot(state2.hashCode));
    });

    test("supports empty currentRoute value", () {
      const state = LayoutState(
        currentRoute: "",
        hideSideMenu: false,
      );

      expect(state.currentRoute, "");
      expect(state.hideSideMenu, false);
      expect(
        state.toString(),
        "LayoutState(currentRoute: , hideSideMenu: false)",
      );
    });
  });
}
