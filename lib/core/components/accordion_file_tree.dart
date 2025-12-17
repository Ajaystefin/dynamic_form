import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

enum AccordionFileType { primary, secondary, teritory }

class CustomFileAccordion extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool? isEnabled;
  final Function()? onExpand;
  final Function()? onTitleTap;
  final AccordionFileType? accordionType;
  final bool? initiallyExpanded;
  final String? subtitle;
  final bool showLeadingIcon;
  final Widget? primaryIcon;
  final ExpansionTileController? expansionController;
  final Widget? trailing;
  final Color? expandedTextColor;
  final Color? iconColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final bool isSelected;
  final Color? selectedColor;

  const CustomFileAccordion({
    super.key,
    required this.title,
    required this.children,
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
                    ),
                    Icon(
                        isExpand
                            ? FontAwesomeIcons.folderOpen
                            : FontAwesomeIcons.folder,
                        color: widget.iconColor,
                        size: 14),
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
                if (widget.onExpand != null) {
                  widget.onExpand!();
                }
              },
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: widget.children,
                ),
              ],
            );
          }),
    );
  }
}
