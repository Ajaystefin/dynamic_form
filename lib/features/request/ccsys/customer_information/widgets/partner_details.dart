import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/percentage_input_formatter.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";

class PartnerDetails extends StatelessWidget {
  const PartnerDetails({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  final CustomerInformationState state;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Partner / Shareholder Details",
      isRequired: viewModel.canEdit,
      showLabel: true,
      child: CustomRawTable(
        key: UniqueKey(),
        columns: getTableColumns(),
        headerFontSize: AppStyle.columnName,
        rows: getTableRows(),
      ),
    );
  }

  List<List<Widget>> getTableRows() {
    return List.generate(viewModel.rows.length, (index) {
      final PartnerShareholder row = viewModel.rows[index];

      return [
        // Partner / Shareholder in English (name)
        CustomTextField(
          key: eidCellKey(index, "Partner / Shareholder in English (name)"),
          controller: viewModel.ctrls[index].name,
          initialValue: null,
          maxLength: 100,
          counterText: "",
          showToolTip: true,
          showTooltipIRL: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[a-zA-Z0-9 ]"), // letters, spaces, numbers
            ),
          ],
          //onChanged: (_) => viewModel.notifyRowChanged(), // <- add
          onSubmitted: (_) => viewModel.notifyRowChanged(), // <- add
        ),

        // Residency (RE/NR) — UI shows label; backend stores RE/NR
        CustomDropdown<Reference>(
          key: eidCellKey(
            index,
            "Residency (RE/NR) — UI shows label; backend stores RE/NR",
          ),
          isEnabled: true,
          items: viewModel.ccsysPartnerShareholderResidence,
          selectedItems: [
            row.partnerShareholderResidence == null
                ? null
                : viewModel.ccsysPartnerShareholderResidence.firstWhere(
                    (r) => r.reference1 == row.partnerShareholderResidence,
                  ),
          ],
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item.name),
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: item?.name, showToolTip: false),
          onSelected: (ref) async => viewModel.setResidency(index, ref.first),
        ),

        // Type (PR1/SH2/JA3)
        CustomDropdown<Reference>(
          key: eidCellKey(index, "Type (PR1/SH2/JA3)"),
          isEnabled: true,
          items: viewModel.ccsysPartnerShareholderType,
          selectedItems: [
            row.partnerShareholderType == null
                ? null
                : viewModel.ccsysPartnerShareholderType
                    .firstWhere((r) => r.name == row.partnerShareholderType),
          ],
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item.name),
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: item?.name, showToolTip: false),
          onSelected: (ref) async => viewModel.setType(index, ref.first),
        ),

        // Shareholding % (0..100, no decimals)
        CustomTextField(
          key: eidCellKey(index, "Shareholding % (0..100, no decimals)"),
          controller: viewModel.ctrls[index].sharePercent,
          initialValue: null,
          counterText: "",
          //onChanged: (_) => viewModel.notifyRowChanged(), // <- add
          onSubmitted: (_) => viewModel.notifyRowChanged(), // <- add
          maxLength: 3,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            createPercentageFormatter(
              maxValue: 100,
              allowDecimal: false, // <— no decimals
              maxIntegerDigits: 3,
            ),
          ],
        ),

        // Legal status (JP/NP)
        CustomDropdown<Reference>(
          key: eidCellKey(index, "Legal status (JP/NP)"),
          isEnabled: true,
          items: viewModel.ccsysPartnerLegalStatus,
          selectedItems: [
            row.legalStatusOfPartnerShareholder == null
                ? null
                : viewModel.ccsysPartnerLegalStatus.firstWhere(
                    (r) => r.reference1 == row.legalStatusOfPartnerShareholder,
                  ),
          ],
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item.name),
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: item?.name, showToolTip: false),
          onSelected: (ref) async => viewModel.setLegalStatus(index, ref.first),
        ),

        // Net worth (AED) — allow decimals (up to 2)
        CustomTextField(
          key: eidCellKey(index, "Net worth (AED) — allow decimals (up to 2)"),
          controller: viewModel.ctrls[index].netWorth,
          filled: viewModel.isnetworkEditable(index),
          readOnly: viewModel.isnetworkEditable(index),
          inputFormatters: [
            DecimalInputFormatter(regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$")),
          ],
          counterText: "",
          //onChanged: (_) => viewModel.notifyRowChanged(), // <- add
          onSubmitted: (_) => viewModel.notifyRowChanged(), // <- add
        ),

        // --- Emirates ID (enabled if RE & NP)
        _enterSubmitTextCell(
          index: index,
          keyLabel: "Emirates ID (enabled if RE & NP)",
          controller: viewModel.ctrls[index].emiratesId,
          initialValue: row.emiratesIdPartnerShareholder,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
          ],
          counterText: "",
          onSubmit: (value) => viewModel.onChangeEmiratesId(value, index),
          textInputAction: TextInputAction.done,
          // moveFocusNext: true,
        ),

        // --- Emirates ID expiry (enabled when EID provided)
        _dependentDatePickerCell(
          index: index,
          keyLabel: "Emirates ID expiry (enabled when EID provided)",
          listenTo: viewModel.ctrls[index].emiratesId,
          initialDateTime: row.emiratesIdExpiryDatePartnerShareholder,
          isEnabled: () => viewModel.eidExpiryEnabled(index),
          onSubmit2: (d) => viewModel.setEmiratesIdExpiry(index, d),
          dateFormat: "dd/MM/yyyy",
          isManualEdit: true,
        ),

        // --- Passport NUMBER/CC (enabled if NR; required if NR & NP)
        _enterSubmitTextCell(
          index: index,
          keyLabel: "Passport NUMBER/CC (enabled if NR; required if NR & NP)",
          controller: viewModel.ctrls[index].passport,
          initialValue: null,
          counterText: "",
          onSubmit: (value) => viewModel.onChangePassport(value, index),
          textInputAction: TextInputAction.done,
          // moveFocusNext: true,
        ),

        // --- Passport expiry (enabled if passport provided)
        _dependentDatePickerCell(
          index: index,
          keyLabel: "Passport expiry (enabled if passport provided)",
          listenTo: viewModel.ctrls[index].passport,
          initialDateTime: row.passportNumberExpiryDatePartnerShareholder,
          isEnabled: () => viewModel.passportExpiryEnabled(index),
          onSubmit2: (d) => viewModel.setPassportExpiry(index, d),
          onSaved: (d) => viewModel.setPassportExpiry(index, d),
          validator: viewModel.checkAuditedFsDate,
          dateFormat: "dd/MM/yyyy",
          isManualEdit: true,
        ),

        // Nationality (optional unless NP; always enabled)
        CustomDropdown<Reference>(
          key: eidCellKey(
            index,
            "Nationality (optional unless NP; always enabled)",
          ),
          isEnabled: true, // FIX
          isSearchable: true,
          items: viewModel.ccsysCountryList,
          selectedItems: [
            row.nationalityPartnerShareholder == null
                ? null
                : viewModel.ccsysCountryList.firstWhere(
                    (r) => r.name == row.nationalityPartnerShareholder,
                  ),
          ],
          filterFn: (Reference item, String filter) {
            return (item.name ?? item.toString())
                .toLowerCase()
                .contains(filter.toLowerCase());
          },
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item.name),
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: item?.name, showToolTip: false),
          onSelected: (ref) async => viewModel.setNationality(index, ref.first),
        ),

        // Trade License (required if JP)
        CustomTextField(
          key: eidCellKey(index, "Trade License (required if JP)"),
          controller: viewModel.ctrls[index].tradeLicense,
          initialValue: null,
          readOnly: !viewModel.tradeLicenseEnabled(index), // FIX
          counterText: "",
          //onChanged: (_) => viewModel.notifyRowChanged(), // <- add
          onSubmitted: (String value) =>
              viewModel.onChangeTLNumber(value, index), // <- add
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[a-zA-Z0-9 ]"), // letters, numbers, spaces
            ),
          ],
          onSaved: (value) {
            viewModel.rows[index].tradeLicenseNumberPartnerShareholder = value;
          },
        ),

        // Place of issue (required if TL filled)
        CustomDropdown<Reference>(
          key: eidCellKey(index, "Place of issue (required if TL filled)"),
          isEnabled: viewModel.tradeLicensePlaceEnabled(index),
          items: viewModel.ccsysCountryList,
          isSearchable: true,
          selectedItems: [
            row.placeIssueTradeLicenseNumberPartnerShareholder == null
                ? null
                : viewModel.ccsysCountryList.firstWhere(
                    (r) =>
                        r.name ==
                        row.placeIssueTradeLicenseNumberPartnerShareholder,
                  ),
          ],
          filterFn: (Reference item, String filter) {
            return (item.name ?? item.toString())
                .toLowerCase()
                .contains(filter.toLowerCase());
          },
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item.name),
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: item?.name, showToolTip: false),
          onSelected: (ref) async =>
              viewModel.setTradeLicensePlace(index, ref.first),
        ),

        // P_S LEI (Y/N) — show only if JP
        buildLeiRadio(index, row),

        // LEI number (required if JP & Y)
        CustomTextField(
          key: eidCellKey(index, "LEI number (required if JP & Y)"),
          controller: viewModel.ctrls[index].leiNumber,
          initialValue: null,
          readOnly: !viewModel.leiNumberEnabled(index), // FIX
          maxLength: 20,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp("[a-zA-Z0-9 ]"), // letters, numbers, spaces
            ),
          ],
          counterText: "",
          //onChanged: (_) => viewModel.notifyRowChanged(), // <- add
          onSubmitted: (String value) =>
              viewModel.onChangeLEINumber(value, index), // <- add
        ),

        // Gender (mandatory)
        CustomDropdown<Reference>(
          key: eidCellKey(index, "Gender (mandatory)"),
          isEnabled: true,
          items: viewModel.ccsysGender,
          selectedItems: [
            row.gender == null
                ? null
                : viewModel.ccsysGender.firstWhere((r) => r.name == row.gender),
          ],
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item.name),
          dropdownBuilder: (context, item) =>
              dropdownBuilderWidget(text: item?.name, showToolTip: false),
          onSelected: (ref) async => viewModel.setGender(index, ref.first),
        ),

        // Delete
        Center(
          child: IconButton(
            onPressed:
                (!viewModel.canEdit) ? null : () => viewModel.removeRow(index),
            icon: const Icon(Icons.delete),
          ),
        ),
      ];
    });
  }

  List<TableColumn> getTableColumns() {
    // Pick an index to evaluate (e.g., 0) or compute anyRequired =
    // rows.any(...)
    final anyNP = viewModel.rows.any(
      (r) =>
          (r.legalStatusOfPartnerShareholder ?? "") ==
          ServerConstants.legalStatusNP,
    );
    final anyJP = viewModel.rows.any(
      (r) =>
          (r.legalStatusOfPartnerShareholder ?? "") ==
          ServerConstants.legalStatusJP,
    );

    return [
      TableColumn(
        label: addAsteriskIf(
          true,
          "ccsys.customerInformation.partnerDetails.nameEnglish".tr(),
        ),
      ),
      TableColumn(
        label: addAsteriskIf(
          true,
          "ccsys.customerInformation.partnerDetails.residence".tr(),
        ),
        forcedWidth: 120.w,
      ),
      TableColumn(
        label: addAsteriskIf(
          true,
          "ccsys.customerInformation.partnerDetails.type".tr(),
        ),
        forcedWidth: 120.w,
      ),
      TableColumn(
        label: addAsteriskIf(
          true,
          "ccsys.customerInformation.partnerDetails.holdingPercentage".tr(),
        ),
      ),

      TableColumn(
        label: addAsteriskIf(
          true,
          "ccsys.customerInformation.partnerDetails.legalStatus".tr(),
        ),
        forcedWidth: 120.w,
      ),

      TableColumn(
        label: addAsteriskIf(
          true,
          "ccsys.customerInformation.partnerDetails.networthAed".tr(),
        ),
      ),
      // Conditional ones (show asterisk only when rule demands)
      TableColumn(
        label: addAsteriskIf(
          anyNP,
          "ccsys.customerInformation.partnerDetails.emiratesId".tr(),
        ),
        forcedWidth: 120.w,
      ),
      TableColumn(
        label: addAsteriskIf(
          anyNP,
          "ccsys.customerInformation.partnerDetails.emiratesIdExpiryDate".tr(),
        ),
      ),

      TableColumn(
        label: addAsteriskIf(
          viewModel.rows.any(
            (r) =>
                (r.partnerShareholderResidence == ServerConstants.residenceNR &&
                    r.legalStatusOfPartnerShareholder ==
                        ServerConstants.legalStatusNP),
          ),
          "ccsys.customerInformation.partnerDetails.passportNumberCountryCode"
              .tr(),
        ),
      ),
      TableColumn(
        label: addAsteriskIf(
          viewModel.rows.any(
            (r) =>
                ((r.passportNumberPartnerShareholder ?? "").trim().isNotEmpty),
          ),
          "ccsys.customerInformation.partnerDetails.passportExpiryDate".tr(),
        ),
      ),

      TableColumn(
        label: addAsteriskIf(
          anyNP,
          "ccsys.customerInformation.partnerDetails.nationality".tr(),
        ),
        forcedWidth: 120.w,
      ),

      TableColumn(
        label: addAsteriskIf(
          anyJP,
          "ccsys.customerInformation.partnerDetails.tlNumber".tr(),
        ),
        forcedWidth: 120.w,
      ),
      TableColumn(
        label: addAsteriskIf(
          viewModel.rows.any(
            (r) => ((r.tradeLicenseNumberPartnerShareholder ?? "")
                .trim()
                .isNotEmpty),
          ),
          "ccsys.customerInformation.partnerDetails.placeOfIssueOfTlNumber"
              .tr(),
        ),
      ),

      TableColumn(
        label: addAsteriskIf(
          anyJP,
          "ccsys.customerInformation.partnerDetails.leIdentifier".tr(),
        ),
      ),
      TableColumn(
        label: addAsteriskIf(
          viewModel.rows.any(
            (r) =>
                r.legalStatusOfPartnerShareholder ==
                    ServerConstants
                        .legalStatusJP && // state.legalEntityIdentifier
                (r.psLei ??= ServerConstants.psLeiNo) ==
                    ServerConstants.psLeiYes,
          ),
          "ccsys.customerInformation.partnerDetails.leiNumber".tr(),
        ),
        forcedWidth: 120.w,
      ),

      TableColumn(
        label: addAsteriskIf(
          true,
          "ccsys.customerInformation.partnerDetails.gender".tr(),
        ),
        forcedWidth: 100.w,
      ),
      TableColumn(
        label: Text("ccsys.customerInformation.partnerDetails.action".tr()),
      ),
    ];
  }

  // --- LEI radio builder (Y/N only; JP-visible; null-safe) ---
  Widget buildLeiRadio(int index, PartnerShareholder row) {
    // Prefer Y/N only (spec excludes NA when JP).
    // If you only have yesNoNaItems, filter to Y/N; else provide yesNoItems.
    final List<Reference> options = viewModel.getFilteredOptions(
      viewModel.yesNoNaItems,
    ); // assuming this filters to ['Y','N']

    // Map row.psLei ('Y'/'N') to server IDs; allow null if not set.
    final int selectedId = row.psLei == ServerConstants.psLeiYes
        ? ServerConstants.yesRefId
        : row.psLei == ServerConstants.psLeiNo
            ? ServerConstants.noRefId
            : ServerConstants.noRefId;

    final Reference? selectedRef = _findById(options, selectedId);
    //bool isEnable = (viewModel.leiVisible(index) == true) ? true : false;
    return CustomRadioButton<Reference>(
      isEnabled: true,
      scrollDirection: Axis.horizontal,
      options: options,
      itemBuilder: (context, item, isSelected, isEnabled) =>
          Text(item.name ?? ""),
      selectedValue: selectedRef ?? Reference(), // can be null
      onChanged: (ref) async => viewModel.setLeiOpt(index, ref),
    );
  }

  // Null-safe helper to get Reference by id
  Reference? _findById(List<Reference> items, int? id) {
    if (id == null) return null;
    for (final r in items) {
      if (r.id == id) return r;
    }
    return null;
  }

  // Example for EID field cell:
  Key eidCellKey(int i, String name) => ValueKey("${viewModel.rows[i]}-$name");

  Widget addAsteriskIf(bool required, String text) {
    if (viewModel.canEdit) {
      if (!required) return Text(text);
      return Text.rich(
        TextSpan(
          text: text,
          children: const [
            TextSpan(text: " *", style: TextStyle(color: AppColors.failure)),
          ],
        ),
        softWrap: true,
      );
    } else {
      return Text(text);
    }
  }

  /// Common builder for a cell with `Focus` + `CustomTextField`
  /// - Submits on Enter (desktop/web-safe) and calls `viewModel.notifyRowChanged()`
  /// - Also wires through onSubmitted (mobile IME 'done')
  Widget _enterSubmitTextCell({
    required int index,
    required String keyLabel,
    required TextEditingController controller,
    required void Function(String value) onSubmit,
    List<TextInputFormatter>? inputFormatters,
    String? initialValue,
    String? counterText,
    TextInputAction textInputAction = TextInputAction.done,
    bool moveFocusNext = false,
  }) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          final value = controller.text;
          onSubmit(value);
          viewModel.notifyRowChanged(); // force table to re-evaluate

          if (moveFocusNext) {
            FocusScope.of(node.context!).nextFocus();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: CustomTextField(
        key: eidCellKey(index, keyLabel),
        controller: controller,
        initialValue: initialValue,
        inputFormatters: inputFormatters,
        counterText: counterText,
        textInputAction: textInputAction,
        onSubmitted: (value) {
          onSubmit(value);
          viewModel.notifyRowChanged(); // safety if platform uses onSubmitted
        },
      ),
    );
  }

  /// Common builder for a date picker cell that depends on a text controller
  /// - Rebuilds instantly when the driving controller's text changes
  /// - `isEnabled` is evaluated each time (e.g., when text becomes non-empty)
  Widget _dependentDatePickerCell({
    required int index,
    required String keyLabel,
    required TextEditingController listenTo,
    required DateTime? initialDateTime,
    required bool Function() isEnabled,
    required Future<void> Function(DateTime? d) onSubmit2,
    String dateFormat = "dd/MM/yyyy",
    bool isManualEdit = true,
    FormFieldValidator<String>? validator,
    Future<void> Function(DateTime? d)? onSaved,
    List<DateTime> blockedDates = const [],
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: listenTo,
      builder: (context, _, __) {
        return CustomDatePicker(
          key: eidCellKey(index, keyLabel),
          initialDateTime: initialDateTime,
          blockedDates: blockedDates,
          dateFormat: dateFormat,
          isMaualEdit: isManualEdit,
          isEnabled: isEnabled(),
          onSubmit2: (d) async => onSubmit2(d),
          onSaved: onSaved,
          validator: validator,
        );
      },
    );
  }
}
