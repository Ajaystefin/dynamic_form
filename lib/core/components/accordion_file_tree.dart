import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Defines the file types supported by the accordion view.
enum AccordionFileType {
  /// Represents the primary file type.
  primary,

  /// Represents the secondary file type.
  secondary,

  /// Represents the tertiary file type.
  teritory,
}

/// A customizable accordion widget for displaying expandable file content.
class CustomFileAccordion extends StatefulWidget {
  /// Creates a [CustomFileAccordion].
  const CustomFileAccordion({
    required this.title,
    required this.children,
    super.key,
    this.isEnabled,
    this.onExpand,
    this.onTitleTap,
    this.textStyle,
    this.initiallyExpanded,
    this.showLeadingIcon = true,
    this.subtitle,
    this.trailing,
    this.expansionController,
    this.expandedTextColor,
    this.iconColor,
    this.textColor,
    this.accordionType = AccordionFileType.primary,
    this.primaryIcon,
    this.isSelected = false,
    this.selectedColor,
  });

  /// Title.
  final String title;

  /// Children.
  final List<Widget> children;

  /// Enabled.
  final bool? isEnabled;

  /// Expand callback.
  final Function()? onExpand;

  /// Title tap callback.
  final Function()? onTitleTap;

  /// Type.
  final AccordionFileType? accordionType;

  /// Initially expanded.
  final bool? initiallyExpanded;

  /// Subtitle.
  final String? subtitle;

  /// Show leading icon.
  final bool showLeadingIcon;

  /// Primary icon.
  final Widget? primaryIcon;

  /// Expansion controller.
  final ExpansionTileController? expansionController;

  /// Trailing widget.
  final Widget? trailing;

  /// Expanded text color.
  final Color? expandedTextColor;

  /// Icon color.
  final Color? iconColor;

  /// Text color.
  final Color? textColor;

  /// Text style.
  final TextStyle? textStyle;

  /// Selected state.
  final bool isSelected;

  /// Selected color.
  final Color? selectedColor;

  @override
  State<CustomFileAccordion> createState() => _CustomFileAccordionState();
}

class _CustomFileAccordionState extends State<CustomFileAccordion> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  Color? tileColor() {
    // If selected, return the selected color
    if (widget.isSelected) {
      return widget.selectedColor ?? AppColors.primary.withValues(alpha: 0.1);
    }

    // Otherwise return the accordion type color
    switch (widget.accordionType) {
      case AccordionFileType.primary:
        return AppColors.accordionPrimary;
      case AccordionFileType.secondary:
        return AppColors.accordionSecondary;
      default:
        return null;
    }
  }

  @override
  void initState() {
    if (widget.initiallyExpanded ?? false) {
      _isExpanded.value = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      dense: true,
      tileColor: tileColor(),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isExpanded,
        builder: (context, isExpand, _) {
          return ExpansionTile(
            controller: widget.expansionController,
            shape: const BeveledRectangleBorder(),
            enabled: widget.isEnabled ?? true,
            iconColor: isExpand ? AppColors.primary : null,
            title: Text(
              widget.title,
              style: widget.textStyle ?? const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            // minTileHeight: 2,
            // tilePadding: EdgeInsets.all(1),
            leading: Visibility(
              visible: widget.showLeadingIcon,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExpand ? Icons.arrow_drop_down : Icons.arrow_right,
                    color: widget.iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    isExpand
                        ? FontAwesomeIcons.folderOpen
                        : FontAwesomeIcons.folder,
                    color: widget.iconColor,
                    size: 14,
                  ),
                  // Display the additional primary icon if provided.
                  if (widget.primaryIcon != null) ...[
                    widget.primaryIcon!,
                    // const SizedBox(width: 3.0),
                  ],
                ],
              ),
            ),
            initiallyExpanded: widget.initiallyExpanded ?? false,
            expandedAlignment: Alignment.topLeft,
            subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
            controlAffinity: ListTileControlAffinity.trailing,
            showTrailingIcon: widget.trailing != null,
            textColor: isExpand
                ? widget.expandedTextColor ?? AppColors.primary
                : widget.textColor ?? AppColors.black,
            dense: true,
            trailing: widget.trailing,
            onExpansionChanged: (val) {
              _isExpanded.value = val;
              widget.onExpand?.call();
            },
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: widget.children,
              ),
            ],
          );
        },
      ),
    );
  }
}
