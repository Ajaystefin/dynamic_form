import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Accordion types.
enum AccordionType {
  /// Primary.
  primary,

  /// Secondary.
  secondary,

  /// Tertiary.
  teritory,
}

/// Custom accordion widget.
class CustomAccordion extends StatefulWidget {
  /// Creates a [CustomAccordion].
  const CustomAccordion({
    required this.title,
    required this.children,
    super.key,
    this.isSubSection = false,
    this.isEnabled,
    this.onExpand,
    this.textStyle,
    this.initiallyExpanded,
    this.showLeadingIcon = true,
    this.subtitle,
    this.trailing,
    this.expansionController,
    this.expandedTextColor,
    this.iconColor,
    this.textColor,
    this.accordionType = AccordionType.primary,
    this.primaryIcon,
    this.tileColor,
  });

  /// Title.
  final String title;

  /// Children.
  final List<Widget> children;

  /// Enabled.
  final bool? isEnabled;

  /// Subsection flag.
  final bool isSubSection;

  /// Expand callback.
  final Function()? onExpand;

  /// Accordion type.
  final AccordionType? accordionType;

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

  /// Tile color.
  final Color? tileColor;

  /// Text style.
  final TextStyle? textStyle;
  
  @override
  State<CustomAccordion> createState() => _CustomAccordionState();
}

class _CustomAccordionState extends State<CustomAccordion> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  Color? tileColor() {
    switch (widget.accordionType) {
      case AccordionType.primary:
        return AppColors.accordionPrimary;
      case AccordionType.secondary:
        return AppColors.accordionSecondary;
      default:
        return widget.tileColor;
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
    return Semantics(
      label: widget.title,
      container: true,
      enabled: widget.isEnabled,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isExpanded,
        builder: (context, isExpand, _) {
          return ListTileTheme(
            tileColor: tileColor(),
            child: ExpansionTile(
              controller: widget.expansionController,
              shape: const BeveledRectangleBorder(),
              enabled: widget.isEnabled ?? true,
              iconColor: isExpand ? AppColors.primary : null,
              title: CustomSelectableText(
                text: widget.title,
                style: widget.textStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
              leading: Visibility(
                visible: widget.showLeadingIcon,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: widget.isSubSection ? 8.0 : 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExpand ? Icons.arrow_drop_down : Icons.arrow_right,
                        color: widget.iconColor,
                      ),
                      // Display the additional primary icon if provided.
                      if (widget.primaryIcon != null) ...[
                        widget.primaryIcon!,
                        const SizedBox(width: 3),
                      ],
                    ],
                  ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: widget.children,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
