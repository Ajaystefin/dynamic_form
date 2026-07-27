import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Widget for displaying a table filter input field.
///
/// Supports filtering table data based on the specified
/// [filterType] and initial filter [text].
class FilterTableWidget extends StatelessWidget {
  /// Creates a table filter widget.
  const FilterTableWidget({
    super.key,
    this.text,
    this.filterType,
  });

  /// Initial filter text displayed in the input field.
  final String? text;

  /// Type of filter associated with the input field.
  final FilterType? filterType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomTextField(
        initialValue: text,
        semanticLabel: filterType?.name,
        maxLength: 30,
        onSubmitted: (String value) {
          // viewModel.onFilter(value: value, filterType: filterType);
        },
      ),
    );
  }
}
