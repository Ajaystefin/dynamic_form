import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";

/// Text input rendered in the filter row of a Facility Summary table.
///
/// The filter is committed on submit (Enter), matching the other filterable
/// tables in the app. Submitting an empty value clears the filter.
class FilterTableWidget extends StatelessWidget {
  /// Creates a table filter input.
  const FilterTableWidget({
    required this.onSubmitted,
    super.key,
    this.value,
    this.semanticLabel,
  });

  /// Creates a filter input bound to [field] of the table identified by
  /// [scopeKey], reading from and writing back to [viewModel].
  FilterTableWidget.forField({
    required FacilitiesSummaryViewModel viewModel,
    required String scopeKey,
    required FacilityFilterField field,
    super.key,
  })  : value = viewModel.facilityFilterValue(scopeKey, field),
        semanticLabel = field.name,
        onSubmitted = ((String text) =>
            viewModel.onFacilityFilterChanged(scopeKey, field, text));

  /// Current filter text, used to prefill the input.
  final String? value;

  /// Accessibility label describing the filtered column.
  final String? semanticLabel;

  /// Called with the entered text when the user submits the field.
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomTextField(
        initialValue: value,
        semanticLabel: semanticLabel,
        maxLength: 30,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
