import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

class ContractingStandardConditionsTable extends StatelessWidget {
  const ContractingStandardConditionsTable({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final List<TableColumn> columns = <TableColumn>[
      TableColumn(
        forcedWidth: 520.w,
        label:
            Text("facilities.createFacility.contractingStandardCondition".tr()),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CustomRawTable(
          showPagination: true,
          rowsPerPage: 5,
          key: UniqueKey(),
          columns: columns,
          autoFitWidth: true,
          rowHeight: 80,
          rows: List<List<Widget>>.generate(
              viewModel.contractingStandardCondition.length, (int index) {
            final Condition item =
                viewModel.contractingStandardCondition[index];

            final bool isWaivedOff =
                viewModel.contractingStandardCondition[index].isWaivedOff ??
                    false;
            final TextStyle descriptionStyle = TextStyle(
              color: isWaivedOff ? AppColors.tableCellColorGroupedRow : null,
            );

            final String description = item.description ?? "";

            // Detect if there is at least one dots run
            final RegExp dotsRegex = RegExp(r"\.{3,}");
            final bool hasDots = dotsRegex.hasMatch(description);

            // Build description cell with multi editable placeholders when
            // needed
            Widget descriptionCell;
            if (hasDots &&
                (viewModel.contractingStandardCondition[index].isAmended ??
                    false)) {
              descriptionCell = MultiEditableDotsText(
                text: description,
                style: descriptionStyle,
                enabled: !isWaivedOff,
                onSubmittedFullText: (String newFullText) {
                  viewModel.contractingStandardCondition[index].description =
                      newFullText;
                },
              );
            } else {
              descriptionCell = Text(
                description,
                style: descriptionStyle,
                textAlign: TextAlign.left,
              );
            }

            return <Widget>[
              // FIRST COLUMN: description (with multiple editable placeholders
              // if "..." exist)
              descriptionCell,

              // SECOND COLUMN: Select checkbox (disabled if waived-off)
              Center(
                child: CustomCheckbox(
                  isEnabled: !(viewModel
                          .contractingStandardCondition[index].isWaivedOff ??
                      false),
                  value:
                      viewModel.contractingStandardCondition[index].isSelected,
                  onChange: (bool? value) {
                    final bool next = value ?? false;
                    viewModel.changeContractingStandardConditionSelect(
                      index,
                      next,
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
                                  .contractingStandardCondition[index]
                                  .isWaivedOff ??
                              false),
                          value: viewModel
                              .contractingStandardCondition[index].isAmended,
                          onChange: (bool? value) {
                            final bool next = value ?? false;
                            viewModel
                                .changeAmendContractingStandardConditionSelect(
                              index,
                              next,
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
                          value: viewModel
                              .contractingStandardCondition[index].isWaivedOff,
                          onChange: (bool? value) {
                            final bool next = value ?? false;
                            // Waived-off standard condition selection
                            viewModel
                                .selectWaivedOffContractingStandardCondition(
                              index,
                              next,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          }),
        ),
        if (viewModel.contractingStandardCondition.isEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: AppStyle.spacingColum),
            child: Center(
              child: Text(
                "facilities.createFacility."
                        "contractingStandardConditionEmptyMessage"
                    .tr(),
              ),
            ),
          ),
      ],
    );
  }
}

class MultiEditableDotsText extends StatefulWidget {
  const MultiEditableDotsText({
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
  State<MultiEditableDotsText> createState() => _MultiEditableDotsTextState();
}

class _MultiEditableDotsTextState extends State<MultiEditableDotsText> {
  late List<ParsedPart> _parts;
  late List<TextEditingController> _controllers; // one per placeholder
  late int _placeholderCount;

  @override
  void initState() {
    super.initState();
    _parts = parseDescriptionIntoParts(widget.text);
    _placeholderCount = _parts.where((ParsedPart p) => p.isPlaceholder).length;
    _controllers = List<TextEditingController>.generate(
      _placeholderCount,
      (int _) => TextEditingController(text: ""),
    );
  }

  @override
  void didUpdateWidget(covariant MultiEditableDotsText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _parts = parseDescriptionIntoParts(widget.text);

      // Rebuild controllers if placeholder count changed
      final int newCount =
          _parts.where((ParsedPart p) => p.isPlaceholder).length;
      if (newCount != _controllers.length) {
        // Dispose old controllers
        for (final TextEditingController c in _controllers) {
          c.dispose();
        }
        _controllers = List<TextEditingController>.generate(
          newCount,
          (int _) => TextEditingController(text: ""),
        );
      }
      _placeholderCount = newCount;
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitComposed() {
    final StringBuffer buffer = StringBuffer();
    int controllerIndex = 0;

    for (final ParsedPart part in _parts) {
      if (!part.isPlaceholder) {
        buffer.write(part.text);
      } else {
        String replacement = "";
        if (controllerIndex < _controllers.length) {
          replacement = _controllers[controllerIndex].text.trim();
        }
        buffer.write(replacement);
        controllerIndex += 1;
      }
    }

    final String composed = buffer.toString();
    widget.onSubmittedFullText(composed);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = widget.style ?? const TextStyle();

    // If there are no placeholders at all, just render plain text.
    final bool hasAnyDots = _parts.any((ParsedPart p) => p.isPlaceholder);
    if (!hasAnyDots) {
      return Text(
        widget.text,
        style: baseStyle,
        textAlign: TextAlign.left,
      );
    }

    // Build spans with a WidgetSpan for each placeholder (TextField)
    final List<InlineSpan> spans = <InlineSpan>[];
    int placeholderSeen = 0;

    for (final ParsedPart part in _parts) {
      if (!part.isPlaceholder) {
        spans.add(TextSpan(text: part.text, style: baseStyle));
      } else {
        // A placeholder: render a compact input
        final TextEditingController controller =
            (placeholderSeen < _controllers.length)
                ? _controllers[placeholderSeen]
                : TextEditingController(text: "");

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 40,
                maxWidth: 160,
              ),
              child: SizedBox(
                height: 28,
                child: TextField(
                  controller: controller,
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  style: baseStyle,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    border: OutlineInputBorder(),
                    hintText: "...",
                  ),
                  // keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9.,-]")),
                  ],
                  onSubmitted: (String _) => _submitComposed(),
                  onChanged: (String _) => _submitComposed(),
                ),
              ),
            ),
          ),
        );

        placeholderSeen += 1;
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
  final RegExp regex = RegExp(r"\.{3,}");
  final Iterable<RegExpMatch> matches = regex.allMatches(description);

  final List<ParsedPart> parts = <ParsedPart>[];
  int cursor = 0;

  for (final RegExpMatch match in matches) {
    final int start = match.start;
    final int end = match.end;

    // Add text before this placeholder
    if (start > cursor) {
      final String beforeText = description.substring(cursor, start);
      if (beforeText.isNotEmpty) {
        parts.add(ParsedPart(isPlaceholder: false, text: beforeText));
      }
    }

    // Add the placeholder itself
    final String placeholder = description.substring(start, end);
    parts.add(ParsedPart(isPlaceholder: true, text: placeholder));

    // Move cursor forward
    cursor = end;
  }

  // Add trailing text after the last placeholder
  if (cursor < description.length) {
    final String tail = description.substring(cursor);
    if (tail.isNotEmpty) {
      parts.add(ParsedPart(isPlaceholder: false, text: tail));
    }
  }

  // If no matches, we still want a single text part
  if (parts.isEmpty) {
    parts.add(ParsedPart(isPlaceholder: false, text: description));
  }

  return parts;
}
