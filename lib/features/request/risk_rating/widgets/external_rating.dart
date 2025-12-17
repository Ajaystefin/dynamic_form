import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/risk_rating/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/risk_rating/external_rating.dart';

class ExternalRatingTable extends StatelessWidget {
  final RiskRatingViewModel viewModel;
  const ExternalRatingTable(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSectionHeader(title: "riskRating.externalRating".tr()),
        const Gap(),
        CustomRawTable(
            key: UniqueKey(),
            rowsPerPage: viewModel.tableRow,
            showPagination: true,
            initialPage: viewModel.initialExternalRatingPage,
            onPageChange: (page) {
              viewModel.initialExternalRatingPage = page;
            },
            columns: _columns(),
            rows: _rows()),
        // if (!viewModel.isProposedbyCreditEditables())
        if (!viewModel.isViewOnly)
          AddItemButton(
            onTap: () async => await viewModel.addExternalTableRow(),
            isLeftSided: true,
            child: Text("riskRating.addExternalRating".tr()),
          ),
      ],
    );
  }

  List<TableColumn> _columns() {
    return [
      TableColumn(forcedWidth: 100, label: Text("riskRating.customerRim".tr())),
      TableColumn(label: Text("riskRating.customerName".tr())),
      TableColumn(forcedWidth: 100, label: Text("riskRating.s&p".tr())),
      TableColumn(forcedWidth: 100, label: Text("riskRating.moody's".tr())),
      TableColumn(forcedWidth: 100, label: Text("riskRating.fitch".tr())),
      if ((viewModel.riskRating.externalRatings ?? [])
          .any((item) => item.isDeleted == true))
        TableColumn(forcedWidth: 10.w, label: const SizedBox()),
    ];
  }

  List<List<Widget>> _rows() {
    final List<ExternalRating> externalRatings =
        viewModel.riskRating.externalRatings ?? [];
    return List.generate(externalRatings.length, (i) {
      final ExternalRating externalRating = externalRatings[i];

      for (Reference rating in externalRating.ratings ?? []) {
        viewModel.sAndP.any((e) {
          if (e.id == rating.typeId) {
            externalRating.sAndP = e;
          }
          return false;
        });
        viewModel.moodys.any((e) {
          if (e.id == rating.typeId) {
            externalRating.moodys = e;
          }
          return false;
        });
        viewModel.fitch.any((e) {
          if (e.id == rating.typeId) {
            externalRating.fitch = e;
          }
          return false;
        });
      }
      return [
        _buildWidget(
            toolTip: "${externalRating.customerRimNo ?? ""}",
            child: externalRating.customerRimNo == -1
                ? CustomTextField(
                    semanticLabel: "riskRating.customerRim".tr(),
                    maxLength: 15,
                    controller: viewModel.rimNoController.text.isNotEmpty
                        ? null
                        : viewModel.rimNoController,
                    onSubmitted: (value) async {
                      await viewModel.searchExternalRatingRim(value, i);
                    })
                : Text("${externalRating.customerRimNo ?? "--"}")),
        _buildWidget(
            toolTip: externalRating.customerName ?? "--",
            child: Text(externalRating.customerName ?? "--")),
        _buildWidget(
            toolTip: externalRating.sAndP?.name ?? "",
            child: CustomDropdown<Reference>(
              key: UniqueKey(),
              semanticLabel: "riskRating.s&p".tr(),
              items: viewModel.sAndP,
              selectedItems: [externalRating.sAndP],
              onSelected: (selectedValue) {
                externalRating.sAndP = selectedValue[0];
              },
              dropdownBuilder: (context, data) {
                return dropdownBuilderWidget(text: data?.name);
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(item.name ?? "",
                    isListTile: true, isSelected: isSelected);
              },
            )),
        _buildWidget(
            toolTip: externalRating.moodys?.name ?? "",
            child: CustomDropdown<Reference>(
                semanticLabel: "riskRating.moody's".tr(),
                selectedItems: [externalRating.moodys],
                dropdownBuilder: (context, data) {
                  return dropdownBuilderWidget(text: data?.name);
                },
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return dropdownItemBuildWidget(item.name ?? "",
                      isListTile: true, isSelected: isSelected);
                },
                onSelected: (selectedValue) {
                  externalRating.moodys = selectedValue[0];
                },
                items: viewModel.moodys)),
        _buildWidget(
            toolTip: externalRating.fitch?.name ?? "",
            child: CustomDropdown<Reference>(
                key: UniqueKey(),
                semanticLabel: "riskRating.fitch".tr(),
                selectedItems: [externalRating.fitch],
                dropdownBuilder: (context, data) {
                  return dropdownBuilderWidget(text: data?.name);
                },
                onSelected: (selectedValue) {
                  externalRating.fitch = selectedValue[0];
                },
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return dropdownItemBuildWidget(item.name ?? "",
                      isListTile: true, isSelected: isSelected);
                },
                items: viewModel.fitch)),
        if ((viewModel.riskRating.externalRatings ?? [])
            .any((item) => item.isDeleted == true))
          _buildWidget(
              child: externalRating.isDeleted == true
                  ? IconButton(
                      onPressed: () => viewModel.removeExternalTableRow(i),
                      icon: const Icon(Icons.delete))
                  : const SizedBox())
      ];
    });
  }

  Widget _buildWidget({required Widget child, String toolTip = ''}) {
    return Center(
      key: UniqueKey(),
      child: viewModel.isViewOnly ? Text(toolTip) : child,
    );
  }
}
