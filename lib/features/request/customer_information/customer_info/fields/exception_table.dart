import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Exception details table for the customer information screen.
class ExceptionTable extends StatefulWidget {
  /// Creates an exception details table.
  const ExceptionTable({required this.row, required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  /// Exception rows to display.
  final List<CustomerException>? row;

  @override
  State<ExceptionTable> createState() => _ExceptionTableState();
}

class _ExceptionTableState extends State<ExceptionTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.customerInformation.exceptionDetails".tr(),
      child: CustomRawTable(
        key: ValueKey(widget.row?.length),
        columns: getTableColumns(),
        headerFontSize: AppStyle.columnName,
        rows: List.generate(widget.row?.length ?? 0, (index) {
          final owner = widget.viewModel.customerException?[index];
          final initialDate = widget.viewModel.getDueDate(owner?.dueDate);

          return [
            /// Type
            CustomTextField(
              // USE CONTROLLER
              controller:
                  (index < widget.viewModel.exceptionTypeController.length)
                      ? widget.viewModel.exceptionTypeController[index]
                      : null,
              // KEEP EXISTING LINE, BUT MUST BE NULL WHEN CONTROLLER IS USED
              initialValue:
                  (index < widget.viewModel.exceptionTypeController.length)
                      ? null
                      : (owner?.type ?? ""),
              maxLength: 15,
              readOnly: !widget.viewModel.canEdit,
              filled: !widget.viewModel.canEdit,
              // OPTIONAL: keep model in sync as user types
              onChanged: (value) {
                widget.viewModel.customerException?[index].type = value;
              },
              onSubmitted: (value) {
                widget.viewModel.customerException?[index].type = value;
              },
              onSaved: (value) {
                widget.viewModel.customerException?[index].type = value;
              },
            ),

            /// Facility ID
            CustomTextField(
              controller:
                  (index < widget.viewModel.exceptionFacilityController.length)
                      ? widget.viewModel.exceptionFacilityController[index]
                      : null,
              initialValue:
                  (index < widget.viewModel.exceptionFacilityController.length)
                      ? null
                      : (owner?.facilityId ?? ""),
              maxLength: 50,
              readOnly: !widget.viewModel.canEdit,
              filled: !widget.viewModel.canEdit,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9]")),
              ],
              onChanged: (value) {
                widget.viewModel.customerException?[index].facilityId = value;
              },
              onSubmitted: (value) {
                widget.viewModel.customerException?[index].facilityId = value;
              },
              onSaved: (value) {
                widget.viewModel.customerException?[index].facilityId =
                    value.toString();
              },
            ),

            /// Description
            CustomTextField(
              controller:
                  (index < widget.viewModel.exceptionDescController.length)
                      ? widget.viewModel.exceptionDescController[index]
                      : null,
              readOnly: !widget.viewModel.canEdit,
              filled: !widget.viewModel.canEdit,
              initialValue:
                  (index < widget.viewModel.exceptionDescController.length)
                      ? null
                      : (owner?.description ?? ""),
              maxLength: 50,
              onChanged: (value) {
                widget.viewModel.customerException?[index].description = value;
              },
              onSubmitted: (value) {
                widget.viewModel.customerException?[index].description = value;
              },
              onSaved: (value) {
                widget.viewModel.customerException?[index].description = value;
              },
            ),

            /// Due Date
            CustomDatePicker(
              isEnabled: widget.viewModel.canEdit,
              initialDateTime: initialDate,
              blockedDates: const [],
              dateFormat: "dd/MM/yyyy",
              onSubmit2: (date) {
                widget.viewModel.customerException?[index].dueDate =
                    DateTimeUtils.formatDateForSubmission(date);
              },
            ),

            /// Status
            CustomDropdown<String>(
              isEnabled: widget.viewModel.canEdit,
              semanticLabel: "Status Dropdown",
              items: [
                "customerInformation.customerInformation.exceptionMet".tr(),
                "customerInformation.customerInformation.exceptionOverdue".tr(),
              ],
              itemBuilder: (context, item, {isDisabled, isSelected}) {
                return dropdownItemBuildWidget(
                  item,
                  isListTile: false,
                  isSelected: isSelected ?? false,
                );
              },
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  widget.viewModel.customerException?[index].status =
                      selectedValue.first;
                }
              },
              dropdownBuilder: (context, item) =>
                  dropdownBuilderWidget(text: item, showToolTip: true),
              selectedItems: owner?.status != null ? [owner!.status] : null,
            ),

            /// Recommendations
            CustomTextField(
              controller:
                  (index < widget.viewModel.exceptionRecommController.length)
                      ? widget.viewModel.exceptionRecommController[index]
                      : null,
              initialValue:
                  (index < widget.viewModel.exceptionRecommController.length)
                      ? null
                      : (owner?.recommendations ?? ""),
              readOnly: !widget.viewModel.canEdit,
              filled: !widget.viewModel.canEdit,
              maxLength: 50,
              onChanged: (value) {
                widget.viewModel.customerException?[index].recommendations =
                    value;
              },
              onSubmitted: (value) {
                widget.viewModel.customerException?[index].recommendations =
                    value;
              },
              onSaved: (value) {
                widget.viewModel.customerException?[index].recommendations =
                    value;
              },
            ),

            /// Delete button
            Center(
              child: IconButton(
                onPressed: (widget.viewModel.canEdit)
                    ? () async {
                        await widget.viewModel.removeExcptionTableRow(index);
                      }
                    : null,
                icon: const Icon(Icons.delete),
              ),
            ),
          ];
        }),
      ),
    );
  }

  /// Returns table columns for the exception details table.
  List<TableColumn> getTableColumns() {
    return [
      TableColumn(
        forcedWidth: 130.w,
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.type".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.facilityId".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 150.w,
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.description".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 140.w,
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.dueDate".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.status".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.recommendations".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.delete".tr(),
        ),
      ),
    ];
  }
}
