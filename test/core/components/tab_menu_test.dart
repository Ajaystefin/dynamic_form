import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/chip.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";

void main() {
  Widget createTabMenuWidget({
    required Map<String, String> routes,
    required Map<String, String> labels,
    required String activeKey,
    Map<String, bool Function()>? conditionalRoutes,
    void Function(String)? onTabChange,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TabMenu<String>(
          routes: routes,
          labels: labels,
          activeKey: activeKey,
          conditionalRoutes: conditionalRoutes,
          onTabChange: onTabChange,
        ),
      ),
    );
  }

  group("TabMenu Widget Tests", () {
    testWidgets("should render basic tab menu with routes and labels",
        (WidgetTester tester) async {
      final routes = {"home": "/home", "profile": "/profile"};
      final labels = {"home": "Home", "profile": "Profile"};

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabMenu<String>), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(CustomChip), findsNWidgets(2));
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
    });

    testWidgets("should apply active styling to the active tab",
        (WidgetTester tester) async {
      final routes = {"home": "/home", "profile": "/profile"};
      final labels = {"home": "Home", "profile": "Profile"};

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
        ),
      );
      await tester.pumpAndSettle();

      final chips =
          tester.widgetList<CustomChip>(find.byType(CustomChip)).toList();

      // First chip (Home) should be active
      expect(chips[0].isActive, isTrue);
      expect(chips[0].label, equals("Home"));

      // Second chip (Profile) should be inactive
      expect(chips[1].isActive, isFalse);
      expect(chips[1].label, equals("Profile"));
    });

    testWidgets(
        "should call onTabChange when tab is tapped and callback is provided",
        (WidgetTester tester) async {
      final routes = {"home": "/home", "profile": "/profile"};
      final labels = {"home": "Home", "profile": "Profile"};
      String? selectedTab;

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
          onTabChange: (key) {
            selectedTab = key;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the Profile tab
      final profileChips = find.descendant(
        of: find.byType(CustomChip),
        matching: find.text("Profile"),
      );
      expect(profileChips, findsOneWidget);

      await tester.tap(profileChips);
      await tester.pump();

      expect(selectedTab, equals("profile"));
    });

    testWidgets("should show all tabs when conditional routes return true",
        (WidgetTester tester) async {
      final routes = {
        "home": "/home",
        "profile": "/profile",
        "admin": "/admin",
      };
      final labels = {"home": "Home", "profile": "Profile", "admin": "Admin"};
      final conditionalRoutes = {
        "admin": () => true,
        "profile": () => true,
        "home": () => true,
      };

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
          conditionalRoutes: conditionalRoutes,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
      expect(find.text("Admin"), findsOneWidget);
      expect(find.byType(CustomChip), findsNWidgets(3));
    });

    testWidgets("should handle empty routes map", (WidgetTester tester) async {
      await tester.pumpWidget(
        createTabMenuWidget(
          routes: {},
          labels: {},
          activeKey: "",
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabMenu<String>), findsOneWidget);
      expect(find.byType(CustomChip), findsNothing);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets("should handle single route", (WidgetTester tester) async {
      final routes = {"home": "/home"};
      final labels = {"home": "Home"};

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomChip), findsOneWidget);
      expect(find.text("Home"), findsOneWidget);

      final chip = tester.widget<CustomChip>(find.byType(CustomChip));
      expect(chip.isActive, isTrue);
    });

    testWidgets("should handle null conditional routes",
        (WidgetTester tester) async {
      final routes = {"home": "/home", "profile": "/profile"};
      final labels = {"home": "Home", "profile": "Profile"};

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
          conditionalRoutes: null,
        ),
      );
      await tester.pumpAndSettle();

      // All tabs should be visible when conditionalRoutes is null
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
      expect(find.byType(CustomChip), findsNWidgets(2));
    });

    testWidgets("should handle conditional routes with some keys missing",
        (WidgetTester tester) async {
      final routes = {
        "home": "/home",
        "profile": "/profile",
        "admin": "/admin",
      };
      final labels = {"home": "Home", "profile": "Profile", "admin": "Admin"};
      final conditionalRoutes = {
        "admin": () => false, // Only admin has conditional route
      };

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
          conditionalRoutes: conditionalRoutes,
        ),
      );
      await tester.pumpAndSettle();

      // Home and Profile should be visible (no conditional route = always
      // visible)
      // Admin should be hidden
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
      expect(find.text("Admin"), findsNothing);
    });

    testWidgets("should apply correct padding and spacing to Wrap widget",
        (WidgetTester tester) async {
      final routes = {"home": "/home", "profile": "/profile"};
      final labels = {"home": "Home", "profile": "Profile"};

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
        ),
      );
      await tester.pumpAndSettle();

      final paddings = tester.widgetList<Padding>(find.byType(Padding));
      bool foundCorrectPadding = false;
      for (final padding in paddings) {
        if (padding.padding == const EdgeInsets.symmetric(vertical: 4)) {
          foundCorrectPadding = true;
          break;
        }
      }
      expect(foundCorrectPadding, isTrue);

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, equals(8.0));
      expect(wrap.runSpacing, equals(8.0));
    });

    testWidgets("should handle different active keys correctly",
        (WidgetTester tester) async {
      final routes = {
        "home": "/home",
        "profile": "/profile",
        "settings": "/settings",
      };
      final labels = {
        "home": "Home",
        "profile": "Profile",
        "settings": "Settings",
      };

      // Test with profile as active
      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "profile",
        ),
      );
      await tester.pumpAndSettle();

      final chips =
          tester.widgetList<CustomChip>(find.byType(CustomChip)).toList();

      // Find which chip is the profile chip and verify it's active
      bool foundActiveProfile = false;
      for (final chip in chips) {
        if (chip.label == "Profile") {
          expect(chip.isActive, isTrue);
          foundActiveProfile = true;
        } else {
          expect(chip.isActive, isFalse);
        }
      }
      expect(foundActiveProfile, isTrue);
    });

    testWidgets("should handle tab change callback with different key types",
        (WidgetTester tester) async {
      // Test with enum-like string keys
      final routes = {"tab_1": "/tab1", "tab_2": "/tab2"};
      final labels = {"tab_1": "Tab 1", "tab_2": "Tab 2"};
      String? lastSelectedTab;

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "tab_1",
          onTabChange: (key) {
            lastSelectedTab = key;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Tab 2
      await tester.tap(find.text("Tab 2"));
      await tester.pump();

      expect(lastSelectedTab, equals("tab_2"));
    });

    testWidgets(
        "should navigate using router.go when onTabChange is not provided",
        (WidgetTester tester) async {
      final routes = {"home": "/home", "profile": "/profile"};
      final labels = {"home": "Home", "profile": "Profile"};

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
          // No onTabChange callback provided
        ),
      );
      await tester.pumpAndSettle();

      // This will test the router.go path, but since we can't easily mock
      // the router in this setup, we'll just ensure the tap doesn't crash
      await tester.tap(find.text("Profile"));
      await tester.pump();

      // If we get here without exception, the router.go path was executed
      expect(find.text("Profile"), findsOneWidget);
    });
  });

  group("TabMenu Integration Tests", () {
    testWidgets("should work with complex conditional logic",
        (WidgetTester tester) async {
      bool showAdmin = false;
      bool showProfile = true;

      final routes = {
        "home": "/home",
        "profile": "/profile",
        "admin": "/admin",
      };
      final labels = {"home": "Home", "profile": "Profile", "admin": "Admin"};
      final conditionalRoutes = {
        "admin": () => showAdmin,
        "profile": () => showProfile,
      };

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
          conditionalRoutes: conditionalRoutes,
        ),
      );
      await tester.pumpAndSettle();

      // Initially admin is hidden, profile is shown
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
      expect(find.text("Admin"), findsNothing);

      // Update conditions and rebuild
      showAdmin = true;
      showProfile = false;

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "home",
          conditionalRoutes: conditionalRoutes,
        ),
      );
      await tester.pumpAndSettle();

      // Now admin is shown, profile is hidden
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsNothing);
      expect(find.text("Admin"), findsOneWidget);
    });

    testWidgets("should handle rapid tab changes", (WidgetTester tester) async {
      final routes = {"a": "/a", "b": "/b", "c": "/c"};
      final labels = {"a": "A", "b": "B", "c": "C"};
      final selectedTabs = <String>[];

      await tester.pumpWidget(
        createTabMenuWidget(
          routes: routes,
          labels: labels,
          activeKey: "a",
          onTabChange: selectedTabs.add,
        ),
      );
      await tester.pumpAndSettle();

      // Rapidly tap different tabs
      await tester.tap(find.text("B"));
      await tester.pump();
      await tester.tap(find.text("C"));
      await tester.pump();
      await tester.tap(find.text("A"));
      await tester.pump();

      expect(selectedTabs, equals(["b", "c", "a"]));
    });
  });

  group("TabMenu View More / View Less Tests", () {
    Widget createFIWidget({
      required Map<String, String> routes,
      required Map<String, String> labels,
      required String activeKey,
      required Set<String> collapsedKeys,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TabMenu<String>(
            routes: routes,
            labels: labels,
            activeKey: activeKey,
            showViewMore: true,
            collapsedKeys: collapsedKeys,
          ),
        ),
      );
    }

    testWidgets("should show collapsed view initially (FI mode)",
        (tester) async {
      final routes = {
        "a": "/a",
        "b": "/b",
        "c": "/c",
        "d": "/d",
      };
      final labels = {
        "a": "A",
        "b": "B",
        "c": "C",
        "d": "D",
      };

      await tester.pumpWidget(
        createFIWidget(
          routes: routes,
          labels: labels,
          activeKey: "a",
          collapsedKeys: {"a", "b"}, // allowed when collapsed
        ),
      );
      await tester.pumpAndSettle();

      // Should see only A & B in collapsed mode
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);

      // C & D should not be visible
      expect(find.text("C"), findsNothing);
      expect(find.text("D"), findsNothing);

      // Button "View more" must exist
      expect(find.text("common.viewMore"), findsOneWidget);
    });

    testWidgets("should expand and show all tabs when tapping View more",
        (tester) async {
      final routes = {
        "a": "/a",
        "b": "/b",
        "c": "/c",
        "d": "/d",
      };
      final labels = {
        "a": "A",
        "b": "B",
        "c": "C",
        "d": "D",
      };

      await tester.pumpWidget(
        createFIWidget(
          routes: routes,
          labels: labels,
          activeKey: "a",
          collapsedKeys: {"a", "b"},
        ),
      );
      await tester.pumpAndSettle();

      // Expand
      await tester.tap(find.text("common.viewMore"));
      await tester.pump();

      // Now all should be visible
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("C"), findsOneWidget);
      expect(find.text("D"), findsOneWidget);

      // Button should now say "View less"
      expect(find.text("common.viewLess"), findsOneWidget);
    });

    testWidgets("should collapse again when tapping View less", (tester) async {
      final routes = {
        "a": "/a",
        "b": "/b",
        "c": "/c",
      };
      final labels = {
        "a": "A",
        "b": "B",
        "c": "C",
      };

      await tester.pumpWidget(
        createFIWidget(
          routes: routes,
          labels: labels,
          activeKey: "a",
          collapsedKeys: {"a"},
        ),
      );
      await tester.pumpAndSettle();

      // Expand
      await tester.tap(find.text("common.viewMore"));
      await tester.pump();

      expect(find.text("C"), findsOneWidget);

      // Collapse again
      await tester.tap(find.text("common.viewLess"));
      await tester.pump();

      // C should disappear again
      expect(find.text("C"), findsNothing);

      // Collapsed should show only 'a'
      expect(find.text("A"), findsOneWidget);
    });

    testWidgets(
        "should always show active tab even if not in"
        " collapsedKeys (auto include)", (tester) async {
      final routes = {
        "a": "/a",
        "b": "/b",
        "c": "/c",
      };
      final labels = {
        "a": "A",
        "b": "B",
        "c": "C",
      };

      // Active key 'c' is NOT inside collapsedKeys → must remain visible
      await tester.pumpWidget(
        createFIWidget(
          routes: routes,
          labels: labels,
          activeKey: "c",
          collapsedKeys: {"a"},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("A"), findsOneWidget);
      expect(find.text("C"), findsOneWidget); // auto included
      expect(find.text("B"), findsNothing);
    });

    testWidgets(
        "should hide View more "
        "button when all "
        "tabs are included in collapsedKeys", (tester) async {
      final routes = {
        "x": "/x",
        "y": "/y",
      };
      final labels = {
        "x": "X",
        "y": "Y",
      };

      // All keys collapsed → nothing to expand → View more button must NOT
      // appear
      await tester.pumpWidget(
        createFIWidget(
          routes: routes,
          labels: labels,
          activeKey: "x",
          collapsedKeys: {"x", "y"},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("common.viewMore"), findsNothing);
      expect(find.text("common.viewLess"), findsNothing);
    });

    testWidgets("should ignore collapsedKeys when showViewMore = false",
        (tester) async {
      final routes = {
        "a": "/a",
        "b": "/b",
        "c": "/c",
      };
      final labels = {
        "a": "A",
        "b": "B",
        "c": "C",
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabMenu<String>(
              routes: routes,
              labels: labels,
              activeKey: "a",
              collapsedKeys: const {"a"}, // ignored
              showViewMore: false, // FI mode disabled
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // All visible
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("C"), findsOneWidget);

      // No toggle button
      expect(find.text("common.viewMore"), findsNothing);
    });
  });
}
