import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions/model.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

class SublimitStdConditionsTable extends StatelessWidget {
  const SublimitStdConditionsTable({
    required this.viewModel,
    super.key,
  });
  final SubLimitConditionsViewModel viewModel;

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
          initialPage: viewModel.initialPageStandard,
          onPageChange: (int pageNo) {
            viewModel.initialPageStandard = pageNo;
          },
          rowsPerPage: 5,
          key: UniqueKey(),
          columns: columns,
          rowHeight: 80,
          rows: List<List<Widget>>.generate(
            viewModel.standardConditions.length,
            (int index) {
              final Condition item = viewModel.standardConditions[index];

              final bool isWaivedOff =
                  viewModel.standardConditions[index].isWaivedOff ?? false;

              final TextStyle descriptionStyle = TextStyle(
                color: isWaivedOff ? AppColors.tableCellColorGroupedRow : null,
              );

              final String description = item.description ?? "";
              final bool canAmend =
                  viewModel.standardConditions[index].isAmended ?? false;
              String stripBrackets(String s) =>
                  s.replaceAll("[", "").replaceAll("]", "");
              final Widget descriptionCell = canAmend
                  ? MultiEditableText(
                      text: description,
                      style: descriptionStyle,
                      enabled: !isWaivedOff,
                      onSubmittedFullText: (String newFullText) {
                        viewModel.standardConditions[index].description =
                            newFullText;
                      },
                    )
                  : Text(
                      stripBrackets(description),
                      style: descriptionStyle,
                      maxLines: 10,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    );

              return <Widget>[
                descriptionCell,
                Center(
                  child: CustomCheckbox(
                    isEnabled: !(viewModel.standardConditions[index].isWaivedOff ?? false),
                    value: viewModel.standardConditions[index].isSelected,
                    onChange: ({bool? value}) {
                      viewModel.changeStandardConditionSelect(
                        index,
                        value: value ?? false,
                      );
                    },
                  ),
                ),
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
                            isEnabled: !(viewModel.standardConditions[index].isWaivedOff ?? false),
                            value: viewModel.standardConditions[index].isAmended,
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
                            value: viewModel.standardConditions[index].isWaivedOff,
                            onChange: ({bool? value}) {
                              viewModel.changeWaivedOffStandardConditionSelect(
                                index,
                                value: value ?? false,
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
        if (viewModel.standardConditions.isEmpty)
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

class MultiEditableText extends StatefulWidget {
  const MultiEditableText({
    required this.text,
    required this.onSubmittedFullText,
    super.key,
    this.style,
    this.enabled = true,
  });
  final String text;
  final TextStyle? style;
  final bool enabled;
  final ValueChanged<String> onSubmittedFullText;

  @override
  State<MultiEditableText> createState() => _MultiEditableTextState();
}

class _MultiEditableTextState extends State<MultiEditableText> {
  List<ParsedPart> _parts = <ParsedPart>[];
  List<TextEditingController> _controllers = <TextEditingController>[];
  int _placeholderCount = 0;

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

    for (final TextEditingController c in _controllers) {
      c.dispose();
    }

    _controllers = List<TextEditingController>.generate(
      _placeholderCount,
      (int _) => TextEditingController(text: ""),
    );

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
    widget.onSubmittedFullText(_fullController.text);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = widget.style ?? const TextStyle();
    final bool hasAnyPlaceholders =
        _parts.any((ParsedPart p) => p.isPlaceholder);

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
                    hintText: part.text.isEmpty ? "..." : part.text,
                  ),
                  inputFormatters: <TextInputFormatter>[
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

class ParsedPart {
  const ParsedPart({
    required this.isPlaceholder,
    required this.text,
  });
  final bool isPlaceholder;
  final String text;
}

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
