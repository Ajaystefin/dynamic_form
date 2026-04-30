import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/chip.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/models/request/customer.dart";

class TabMenu<T> extends StatefulWidget {
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
  final Map<T, String> routes;
  final Map<T, String> labels;
  final Map<T, bool Function()>? conditionalRoutes;
  final T activeKey;
  final void Function(T)? onTabChange;
  final List<T> showAsteriskTabs;
  final Customer? customer;

  /// NEW: show "View more / View less" (FI only). Default = false (Country/Corporate).
  final bool showViewMore;

  /// NEW: Which keys should remain visible when collapsed.
  /// For FI, pass TabConstants.fiCollapsedTabs. Optional for non-FI.
  final Set<T>? collapsedKeys;

  @override
  State<TabMenu<T>> createState() => _TabMenuState<T>();
}

class _TabMenuState<T> extends State<TabMenu<T>> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // 1) Build the ordered list of *visible keys* (your existing logic)
    final List<T> orderedKeys = widget.routes.entries
        .where((route) {
          if (widget.conditionalRoutes != null &&
              (widget.conditionalRoutes?.containsKey(route.key) ?? false)) {
            return widget.conditionalRoutes![route.key]!();
          }
          return true; // not gated => visible
        })
        .map((e) => e.key)
        .toList();

    // 2) Choose which keys to show based on expanded/collapsed
    //    - Non-FI => always show all (no toggle)
    //    - FI expanded => show all
    //    - FI collapsed => show only collapsedKeys ∩ visible, but ALWAYS keep
    // the active tab visible
    List<T> visibleKeys;
    if (!widget.showViewMore) {
      visibleKeys = orderedKeys;
    } else if (_expanded || widget.collapsedKeys == null) {
      visibleKeys = orderedKeys;
    } else {
      // Collapsed: intersect visible with whitelist
      final List<T> base =
          orderedKeys.where((k) => widget.collapsedKeys!.contains(k)).toList();

      // Ensure the currently active tab chip is still visible (nice UX)
      if (!base.contains(widget.activeKey) &&
          orderedKeys.contains(widget.activeKey)) {
        base.add(widget.activeKey);
      }
      visibleKeys = base;
    }

    // 3) Map keys -> chips (your existing CustomChip + routing/asterisk logic)
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
            final route = widget.routes[key]!;
            router.go(route);
          }
        },
      );
    }).toList();

    // 4) Render:
    //    - Non-FI => just the Wrap (your original)
    //    - FI => Wrap + "View more/View less" toggle (only if there exists something to expand)
    final bool canToggle = widget.showViewMore && widget.collapsedKeys != null;
    final bool isCollapsibleUseful = canToggle &&
        // There must be at least one key that’s *not* in the collapsed set to
        // make "View more" meaningful
        orderedKeys.any((k) => !widget.collapsedKeys!.contains(k));

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
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? "common.viewLess".tr() : "common.viewMore".tr(),
                style: const TextStyle(
                  decoration: TextDecoration.underline, color: AppColors.black,
                  // (Optional) control thickness or color
                  // decorationThickness: 1.5,
                  // decorationColor: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
