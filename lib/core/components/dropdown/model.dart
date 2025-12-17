import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDropdownItem {
  final String? label;
  final dynamic value;
  final String? title;
  final Function()? onPressed;
  final bool isHeader;

  CustomDropdownItem({
    required this.value,
    String? label,
    this.title,
    this.onPressed,
    this.isHeader = false,
  }) : label = label ?? value.toString();
}

// Helper function to group items by title
List<ItemGroup> groupItemsByTitle(List<CustomDropdownItem> items) {
  final map = <String?, List<CustomDropdownItem>>{};

  for (var item in items) {
    if (!map.containsKey(item.title)) {
      map[item.title] = [];
    }
    map[item.title]!.add(item);
  }

  return map.entries.map((entry) => ItemGroup(entry.key, entry.value)).toList();
}

// Helper class to hold grouped items
class ItemGroup {
  final String? title;
  final List<CustomDropdownItem> items;

  ItemGroup(this.title, this.items);
}

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
