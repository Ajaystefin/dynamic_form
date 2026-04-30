import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/utils.dart";

class FilterTableWidget extends StatelessWidget {
  const FilterTableWidget({super.key, this.text, this.filterType});
  final String? text;

  final FilterType? filterType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomTextField(
        initialValue: text,
        semanticLabel: filterType?.name,
        maxLength: 30,
        counterText: "",
        onSubmitted: (String value) {
          // viewModel.onFilter(value: value, filterType: filterType);
        },
      ),
    );
  }
}
