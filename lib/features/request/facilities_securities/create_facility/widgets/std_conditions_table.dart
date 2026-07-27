import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

/// Widget for displaying and managing facility conditions.
class ConditionsTable extends StatelessWidget {
  /// Creates a conditions table widget.
  const ConditionsTable({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility condition data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<TableColumn> columns = <TableColumn>[
      TableColumn(
        forcedWidth: 520.w,
        label: Text("facilities.createFacility.standardCondition".tr()),
      ),
      TableColumn(
        forcedWidth: 40,
        label: Text("facilities.createFacility.select".tr()),
      ),
      TableColumn(
        forcedWidth: 40,
        label: Text("facilities.createFacility.action".tr()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomRawTable(
          initialPage: viewModel.initialPageStandardConditions,
          onPageChange: (int pageNo) {
            viewModel.initialPageStandardConditions = pageNo;
          },
          rowsPerPage: 5,
          key:
              // NOTE: if rows are stateful, consider a stable Key instead
              UniqueKey(),
          columns: columns,
          rowHeight: 80,
          rows: List<List<Widget>>.generate(
            viewModel.standardCondition.length,
            (int index) {
              final Condition item = viewModel.standardCondition[index];

              final bool isWaivedOff =
                  viewModel.standardCondition[index].isWaivedOff ?? false;

              final TextStyle descriptionStyle = TextStyle(
                color: isWaivedOff ? AppColors.tableCellColorGroupedRow : null,
              );

              final String description = item.description ?? "";
              final bool canAmend =
                  viewModel.standardCondition[index].isAmended ?? false;
              String stripBrackets(String s) =>
                  s.replaceAll("[", "").replaceAll("]", "");
              // Build description cell; widget auto-detects [ ... ] or ...
              // placeholders.
              final Widget descriptionCell = canAmend
                  ? MultiEditableText(
                      text: description,
                      style: descriptionStyle,
                      enabled: !isWaivedOff,
                      onSubmittedFullText: (String newFullText) {
                        viewModel.standardCondition[index].description =
                            newFullText;
                      },
                    )
                  : Text(
                      stripBrackets(description), // hide brackets in plain view
                      style: descriptionStyle,
                      maxLines: 10,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    );

              return <Widget>[
                // FIRST COLUMN: description (with editable placeholders if
                // present)
                descriptionCell,

                // SECOND COLUMN: Select checkbox (disabled if waived-off)
                Center(
                  child: CustomCheckbox(
                    isEnabled:
                        !(viewModel.standardCondition[index].isWaivedOff ??
                            false),
                    value: viewModel.standardCondition[index].isSelected,
                    onChange: ({bool? value}) {
                      final bool next = value ?? false;
                      viewModel.changeStandardConditionSelect(
                        index,
                        value: next,
                      );
                    },
                  ),
                ),

                // THIRD COLUMN: actions (Amend & Waive-off)
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              "Amend",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.darkBlue,
                              ),
                            ),
                          ),
                          CustomCheckbox(
                            isEnabled: !(viewModel
                                    .standardCondition[index].isWaivedOff ??
                                false),
                            value: viewModel.standardCondition[index].isAmended,
                            onChange: ({bool? value}) {
                              viewModel.changeAmendStandardConditionSelect(
                                index,
                                value: value ?? false,
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              "Waive-off",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.darkBlue,
                              ),
                            ),
                          ),
                          CustomCheckbox(
                            value:
                                viewModel.standardCondition[index].isWaivedOff,
                            onChange: ({bool? value}) {
                              final bool next = value ?? false;
                              viewModel.changeWaivedOffStandardConditionSelect(
                                index,
                                value: next,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ),
        if (viewModel.standardCondition.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppStyle.spacingColum),
            child: Center(
              child: Text(
                "No Standard Conditions available for the facility type",
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget that displays editable multi-line text.
class MultiEditableText extends StatefulWidget {
  /// Creates a multi-line editable text widget.
  const MultiEditableText({
    required this.text,
    required this.onSubmittedFullText,
    super.key,
    this.style,
    this.enabled = true,
  });

  /// Initial text displayed in the widget.
  final String text;

  /// Style applied to the text content.
  final TextStyle? style;

  /// Indicates whether editing is enabled.
  final bool enabled;

  /// Callback invoked when the full text is submitted.
  final ValueChanged<String> onSubmittedFullText;

  @override
  State<MultiEditableText> createState() => _MultiEditableTextState();
}

class _MultiEditableTextState extends State<MultiEditableText> {
  List<ParsedPart> _parts = <ParsedPart>[];
  List<TextEditingController> _controllers = <TextEditingController>[];
  int _placeholderCount = 0;

  // Controller used when there are NO placeholders (full string edit)
  final TextEditingController _fullController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rebuildPartsAndControllers(widget.text);
  }

  @override
  void didUpdateWidget(covariant MultiEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _rebuildPartsAndControllers(widget.text);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    _fullController.dispose();
    super.dispose();
  }

  void _rebuildPartsAndControllers(String text) {
    _parts = parseDescriptionIntoParts(text);
    _placeholderCount = _parts.where((ParsedPart p) => p.isPlaceholder).length;

    // Dispose old controllers for placeholders
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }

    // Recreate placeholder controllers (empty by default; adjust if you want to
    // prefill)
    _controllers = List<TextEditingController>.generate(
      _placeholderCount,
      (int _) => TextEditingController(text: ""),
    );

    // For full edit mode, always reflect the latest string with brackets
    // stripped
    _fullController.text = text.replaceAll("[", "").replaceAll("]", "");
  }

  void _submitComposedPlaceholders() {
    final StringBuffer buffer = StringBuffer();
    int controllerIndex = 0;

    for (final ParsedPart part in _parts) {
      if (!part.isPlaceholder) {
        buffer.write(part.text);
      } else {
        String value = "";
        if (controllerIndex < _controllers.length) {
          value = _controllers[controllerIndex].text.trim();
        }
        // Keep placeholders persistent for future edits
        buffer
          ..write("[")
          ..write(value)
          ..write("]");
        controllerIndex++;
      }
    }

    widget.onSubmittedFullText(buffer.toString());
  }

  void _submitComposedFull() {
    // In full-edit mode, keep the string as-is (no brackets are reinserted)
    widget.onSubmittedFullText(_fullController.text);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = widget.style ?? const TextStyle();
    final bool hasAnyPlaceholders =
        _parts.any((ParsedPart p) => p.isPlaceholder);

    // If no placeholders exist, allow editing the entire string when enabled
    if (!hasAnyPlaceholders) {
      if (!widget.enabled) {
        return Text(
          _fullController.text,
          style: baseStyle,
          textAlign: TextAlign.left,
        );
      }

      return TextField(
        controller: _fullController,
        enabled: true,
        style: baseStyle,
        minLines: 1,
        maxLines: 5,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        onChanged: (String _) => _submitComposedFull(),
        onSubmitted: (String _) => _submitComposedFull(),
      );
    }

    // Placeholders exist -> render mixed text + inline fields
    final List<InlineSpan> spans = <InlineSpan>[];
    int placeholderSeen = 0;

    for (final ParsedPart part in _parts) {
      if (!part.isPlaceholder) {
        spans.add(TextSpan(text: part.text, style: baseStyle));
      } else {
        final TextEditingController controller =
            (placeholderSeen < _controllers.length)
                ? _controllers[placeholderSeen]
                : TextEditingController(text: "");

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40, maxWidth: 160),
              child: SizedBox(
                height: 28,
                child: TextField(
                  controller: controller,
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  style: baseStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    border: const OutlineInputBorder(),
                    // Optional: show the inner text as hint if provided
                    hintText: part.text.isEmpty ? "..." : part.text,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    // Adjust to your needs. If placeholders can be text, remove/relax this constraint.
                    FilteringTextInputFormatter.allow(RegExp("[0-9.,-]")),
                  ],
                  onChanged: (String _) => _submitComposedPlaceholders(),
                  onSubmitted: (String _) => _submitComposedPlaceholders(),
                ),
              ),
            ),
          ),
        );

        placeholderSeen++;
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}

/// Represents a parsed segment of a description.
class ParsedPart {
  /// Creates a parsed description segment.
  const ParsedPart({
    required this.isPlaceholder,
    required this.text,
  });

  /// Indicates whether the segment is a placeholder enclosed in brackets.
  final bool isPlaceholder;

  /// Text content of the segment.
  final String text;
}

/// Parses a description into text and placeholder segments.
///
/// Text enclosed in square brackets (`[]`) is returned as placeholder parts,
/// while all other content is returned as regular text parts.
List<ParsedPart> parseDescriptionIntoParts(String description) {
  final RegExp bracketRegex = RegExp(r"\[([^\]]*)\]");
  final Iterable<RegExpMatch> matches = bracketRegex.allMatches(description);

  if (matches.isEmpty) {
    return <ParsedPart>[
      ParsedPart(isPlaceholder: false, text: description),
    ];
  }

  final List<ParsedPart> parts = <ParsedPart>[];
  int cursor = 0;

  for (final RegExpMatch m in matches) {
    final int start = m.start;
    final int end = m.end;

    if (start > cursor) {
      final String before = description.substring(cursor, start);
      if (before.isNotEmpty) {
        parts.add(ParsedPart(isPlaceholder: false, text: before));
      }
    }

    final String inner = m.group(1) ?? "";
    parts.add(ParsedPart(isPlaceholder: true, text: inner));

    cursor = end;
  }

  if (cursor < description.length) {
    final String tail = description.substring(cursor);
    if (tail.isNotEmpty) {
      parts.add(ParsedPart(isPlaceholder: false, text: tail));
    }
  }

  return parts;
}
