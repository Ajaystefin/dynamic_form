import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/chip.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class TabMenu<T> extends StatelessWidget {
  final Map<T, String> routes;
  final Map<T, String> labels;
  final Map<T, bool Function()>? conditionalRoutes;
  final T activeKey;
  final void Function(T)? onTabChange;
  final List<T> showAsteriskTabs;
  final Customer? customer;

  /// Creates a tab menu with customizable routes and labels.
  ///
  /// [routes] maps each tab key to a route path.
  /// [labels] maps each tab key to a localized label.
  /// [conditionalRoutes] maps each tab key in order to handling conditional visibility.
  /// [activeKey] indicates the currently selected tab.
  /// [onTabChange] is an optional callback triggered when a tab is selected.
  /// If provided, it overrides the default route navigation.
  const TabMenu(
      {super.key,
      required this.routes,
      required this.activeKey,
      required this.labels,
      this.conditionalRoutes,
      this.onTabChange,
      this.showAsteriskTabs = const [],
      this.customer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: routes.entries.map((route) {
          final isActive = route.key == activeKey;
          bool showChip = true;
          if (conditionalRoutes != null &&
              (conditionalRoutes?.containsKey(route.key) ?? false)) {
            showChip = conditionalRoutes![route.key]!();
          }

          return Visibility(
            visible: showChip,
            child: CustomChip(
              showAsterisk: showAsteriskTabs.contains(route.key),
              isActive: isActive,
              label: labels[route.key]!.tr(),
              onPressed: () {
                if (onTabChange != null) {
                  onTabChange!(route.key);
                } else {
                  router.go(route.value);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
