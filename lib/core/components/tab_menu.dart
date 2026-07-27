import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/chip.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// A reusable tab-chip menu.
///
/// Features:
/// - Shows tabs as `CustomChip`s
/// - Can hide/show some tabs using "View more / View less"
/// - Can conditionally hide tabs using [conditionalRoutes]
/// - Preserves the original tab order defined in [routes]
///
/// ## Order rule (important)
/// The chip order always follows the insertion order of [routes]
/// (e.g. `TabConstants.remarksRoutes`). We only *filter* the list; we never
/// insert or append items in a way that changes order.
///
/// ## View more / View less (FI-only)
/// When [showViewMore] is true and [collapsedKeys] is provided:
/// - Expanded: show all visible tabs
/// - Collapsed: hide the tabs listed in [collapsedKeys]
///   (but always keep [activeKey] visible)
class TabMenu<T> extends StatefulWidget {
  /// Creates a [TabMenu].
  const TabMenu({
    required this.routes,
    required this.activeKey,
    required this.labels,
    super.key,
    this.conditionalRoutes,
    this.onTabChange,
    this.showAsteriskTabs = const [],
    this.customer,
    this.showViewMore = false, // default keeps old behavior
    this.collapsedKeys, // optional
  });

  /// Map of tab keys to route strings.  The insertion order of this map defines the tab display order.
  final Map<T, String> routes;

  /// Map of tab keys to localization keys (display labels).
  final Map<T, String> labels;

  /// Optional rules to hide certain tabs based on runtime conditions.
  final Map<T, bool Function()>? conditionalRoutes;

  /// Current active tab (highlighted).
  final T activeKey;

  /// Callback invoked when a tab is selected.
  final void Function(T)? onTabChange;

  /// Tabs that should display an asterisk indicator.
  final List<T> showAsteriskTabs;

  /// Customer associated with the current tab context.
  final Customer? customer;

  /// show "View more / View less" (FI only). Default = false (Country/Corporate).
  final bool showViewMore;

  /// Which keys should remain visible when collapsed.
  /// For FI, pass TabConstants.fiCollapsedTabs. Optional for non-FI.
  final Set<T>? collapsedKeys;

  @override
  State<TabMenu<T>> createState() => _TabMenuState<T>();
}

class _TabMenuState<T> extends State<TabMenu<T>> {
  /// When true: expanded (shows all tabs). When false: collapsed.
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Build a list of tabs in the same order as widget.routes,
    //   removing tabs blocked by conditionalRoutes.
    final List<T> orderedVisibleKeys = widget.routes.entries
        .where((route) {
          if (widget.conditionalRoutes != null &&
              (widget.conditionalRoutes?.containsKey(route.key) ?? false)) {
            return widget.conditionalRoutes![route.key]!();
          }
          return true; // not gated => visible
        })
        .map((routeEntry) => routeEntry.key)
        .toList();

    // Decide which keys are shown based on collapsed/expanded state.
    List<T> visibleKeys;
    if (!widget.showViewMore) {
      // Non-FI (or no collapse config) => show everything.
      visibleKeys = orderedVisibleKeys;
    } else if (_isExpanded || widget.collapsedKeys == null) {
      visibleKeys = orderedVisibleKeys;
    } else {
      // Collapsed: hide the "extra" keys (FI-only), but ALWAYS keep active visible.
      // Order stays exactly as TabConstants because we filter from orderedKeys.
      visibleKeys = orderedVisibleKeys.where((key) {
        final bool isHiddenWhenCollapsed = widget.collapsedKeys!.contains(key);
        return !isHiddenWhenCollapsed || key == widget.activeKey;
      }).toList();
    }

    // Map keys -> chips (your existing CustomChip + routing/asterisk logic)
    final List<CustomChip> chips = visibleKeys.map((key) {
      final bool isActive = key == widget.activeKey;
      return CustomChip(
        showAsterisk: widget.showAsteriskTabs.contains(key),
        isActive: isActive,
        label: widget.labels[key]!.tr(),
        onPressed: () {
          //Autosave function - This is to ensure that any unsaved changes are
          //saved as draft before leaving the current page.
          unawaited(Globals.onAutoSave?.call());
          if (widget.onTabChange != null) {
            widget.onTabChange!(key);
          } else {
            final String route = widget.routes[key]!;
            router.go(route);
          }
        },
      );
    }).toList();

    //Show toggle only if there is at least one key to hide in collapsed mode.
    //    - Non-FI => just the Wrap (your original)
    //    - FI => Wrap + "View more/View less" toggle (only if there exists something to expand)
    final bool canToggle = widget.showViewMore && widget.collapsedKeys != null;

    final bool isCollapsibleUseful = canToggle &&
        orderedVisibleKeys
            .any((tabKey) => widget.collapsedKeys!.contains(tabKey));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
          const Gap(),
          if (isCollapsibleUseful)
            TextButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? "common.viewLess".tr() : "common.viewMore".tr(),
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: AppColors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
