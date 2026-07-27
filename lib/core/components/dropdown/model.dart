import "package:flutter/material.dart";
import "package:flutter/services.dart";

/// Dropdown item model.
class CustomDropdownItem {
  /// Creates a [CustomDropdownItem].
  CustomDropdownItem({
    required this.value,
    String? label,
    this.roleCode,
    this.title,
    this.onPressed,
    this.isHeader = false,
    this.headerName,
  }) : label = label ?? value.toString();

  /// Display label.
  final String? label;

  /// Role code.
  String? roleCode;

  /// Item value.
  final dynamic value;

  /// Group title.
  final String? title;

  /// Item action callback.
  final Function()? onPressed;

  /// Indicates whether the item is a header.
  final bool isHeader;

  /// Header name.
  String? headerName;
}

/// Groups dropdown items by title.
List<ItemGroup> groupItemsByTitle(List<CustomDropdownItem> items) {
  final map = <String?, List<CustomDropdownItem>>{};

  for (final item in items) {
    if (!map.containsKey(item.title)) {
      map[item.title] = [];
    }
    map[item.title]!.add(item);
  }

  return map.entries.map((entry) => ItemGroup(entry.key, entry.value)).toList();
}

/// Group of dropdown items.
class ItemGroup {
  /// Creates an [ItemGroup].
  ItemGroup(this.title, this.items);

  /// Group title.
  final String? title;

  /// Group items.
  final List<CustomDropdownItem> items;
}

/// Handles keyboard navigation events.
void handleKeyEvent(KeyEvent event, FocusNode focusNode) {
  if (event is KeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // Move selection down
      if (focusNode.hasFocus) {
        focusNode.nextFocus();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // Move selection up
      if (focusNode.hasFocus) {
        focusNode.previousFocus();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      // Select the current item
      focusNode.unfocus(); // Close the dropdown
    }
  }
}
