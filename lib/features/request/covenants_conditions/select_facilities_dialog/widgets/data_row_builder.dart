import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart';

class FacilitiesDataRowBuilder {
  final SelectFacilitiesDialogViewModel viewModel;

  FacilitiesDataRowBuilder(
    this.viewModel,
  );

  List<List<Widget>> buildRows() {
    List<List<Widget>> rowModels = [];
    final filterRow = <Widget>[
      if (viewModel.showCheckboxColumn) const SizedBox(),
      _createFilterField(viewModel.rimFilterCtrl, Filter.rimNo),
      _createFilterField(viewModel.limitNumFilterCtrl, Filter.limitNumber),
      _createFilterField(viewModel.projFilterCtrl, Filter.limitLabel),
      _createFilterField(viewModel.descFilterCtrl, Filter.limitDescription),
      const SizedBox(),
    ];

    rowModels.add(filterRow);
    if (viewModel.checkboxes.length != viewModel.filteredData.length) {
      viewModel.checkboxes = List<bool>.filled(
        viewModel.filteredData.length,
        false,
      );
    }

    final dataRows = List<List<Widget>>.generate(
      viewModel.filteredData.length,
      (int index) {
        final facility = viewModel.filteredData[index];

        return [
          if (viewModel.showCheckboxColumn)
            Center(
              child: Checkbox(
                visualDensity: VisualDensity.compact,
                value: viewModel.getCheckBoxValue(facility),
                onChanged: (bool? newValue) {
                  viewModel.updateCheckboxAtIndex(index, newValue ?? false);
                },
              ),
            ),
          Center(child: Text('${facility.rimNo}')),
          Center(child: Text(facility.limitNumber ?? "")),
          Center(child: Text(facility.limitLabel ?? "")),
          Center(child: Text(facility.limitDescription ?? "")),
          Center(
            child: Text(Utils.numberFormat(facility.proposedLimit),
                style: AppStyle.highlightedText),
          ),
        ];
      },
    );

    List<List<Widget>> finalRow = addFilter(
        rows: dataRows,
        filterRow: filterRow,
        rowsPerPage: viewModel.rowsPerPage);
    return finalRow.isEmpty ? [filterRow] : finalRow;
  }

  Widget _createFilterField(String? text, Filter filter) {
    return SizedBox(
      child: CustomTextField(
        initialValue: text,
        onSubmitted: (String value) {
          viewModel.onFilter(filter, value: value);
        },
      ),
    );
  }
}
