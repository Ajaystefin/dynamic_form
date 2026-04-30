import "dart:convert";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";

class CustomerInformationDraftHandler
    extends DraftHandler<CustomerInformationViewModel> {
  @override
  Map<String, dynamic> buildDraftData(CustomerInformationViewModel vm) {
    vm.formKey.currentState?.save();

    vm.customerInformation.groupImmediateParent =
        _normalize(vm.controllerGroupImmediate.text);

    vm.customerInformation.groupUltimateParent =
        _normalize(vm.controllerGroupUltimate.text);

    vm.customerInformation.leiNumber = _normalize(vm.leiController.text);

    vm.customerInformation.capital = _normalize(vm.capitalController.text);

    vm.customerInformation.turnover = _normalize(vm.turnoverController.text);

    vm.customerInformation.auditor = _normalize(vm.auditorController.text);

    vm.customerInformation.numberOfEmployee =
        int.tryParse(vm.numberOfEmployeeController.text);

    vm.customerInformation.borrowerSubsidiary =
        vm.selectedBorroweSubsidiary?.id == ServerConstants.yesRefId;

    vm.customerInformation.legalEntityIdentifier =
        vm.selectedLegalEntityIdentifier?.id == ServerConstants.yesRefId;

    /// SAVE AS ID-NAME (CRITICAL FIX)
    vm.customerInformation.emiLic = vm.selectedEmirateLicense != null
        ? "${vm.selectedEmirateLicense!.id}-${vm.selectedEmirateLicense!.name}"
        : null;

    final emiEst = vm.selectedEmirateEstablishment;
    vm.customerInformation.emiEst = emiEst != null
        ? "${emiEst.id}-${emiEst.name}"
        : null;

    vm.customerInformation.ccsysCustomerPartnerShareholderList = vm.rows;

    final rowCtrls = vm.ctrls.map((c) {
      return {
        "name": c.name.text,
        "sharePercent": c.sharePercent.text,
        "netWorth": c.netWorth.text,
        "emiratesId": c.emiratesId.text,
        "passport": c.passport.text,
        "tradeLicense": c.tradeLicense.text,
        "leiNumber": c.leiNumber.text,
      };
    }).toList();

    final customerJson =
        _jsonSafe(vm.customerInformation.toJsonGetCCSYSCustomerInfo());

    return {
      "formKey": vm.draftFormKey,
      "moduleKey": vm.draftModuleKey,
      "customerInformation": customerJson,
      "selectedBorroweSubsidiaryId": vm.selectedBorroweSubsidiary?.id,
      "selectedLegalEntityIdentifierId": vm.selectedLegalEntityIdentifier?.id,
      "leiText": vm.leiController.text,
      "groupImmediateText": vm.controllerGroupImmediate.text,
      "groupUltimateText": vm.controllerGroupUltimate.text,
      "capital": vm.capitalController.text,
      "turnoverText": vm.turnoverController.text,
      "auditorText": vm.auditorController.text,
      "numberOfEmployeeText": vm.numberOfEmployeeController.text,
      "ccsysCustomerInformationId": vm.ccsysCustomerInformationId,
      "rows": _serializeRows(vm.rows),
      "rowControllers": rowCtrls,
    };
  }

  List<dynamic> _serializeRows(List<PartnerShareholder>? rows) {
    if (rows == null) return [];

    return rows.map((e) => _jsonSafe(e.toJson())).toList();
  }

  @override
  void applyDraft(CustomerInformationViewModel vm, Map<String, dynamic> data) {
    try {
      final raw = data["customerInformation"];
      Map<String, dynamic>? jsonMap;

      if (raw is String && raw.trim().isNotEmpty) {
        jsonMap = _mapStringDynamic(jsonDecode(raw));
      } else if (raw is Map) {
        jsonMap = _mapStringDynamic(raw);
      }

      if (jsonMap != null) {
        vm.customerInformation =
            CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo(jsonMap);
      }
      vm.rows = _restoreRows(
        data["rows"],
        vm.customerInformation.ccsysCustomerPartnerShareholderList,
      );

      /// ===============================
      /// RECREATE CONTROLLERS FOR GRID
      /// ===============================

      vm.ctrls.clear();

      final rowCtrlData = data["rowControllers"];

      for (int i = 0; i < vm.rows.length; i++) {
        final m = vm.rows[i];
        final ctrl = PartnerShareholderControllers();

        final saved = (rowCtrlData is List && rowCtrlData.length > i)
            ? rowCtrlData[i]
            : {};

        ctrl.name.text =
            saved["name"]?.toString() ?? (m.partnerShareholderInEnglish ?? "");

        ctrl.sharePercent.text = saved["sharePercent"]?.toString() ??
            (m.shareholdingPartnershipPercentage?.toString() ?? "");

        ctrl.netWorth.text = saved["netWorth"]?.toString() ??
            (m.networthPartnerShareholderAed ?? "");

        ctrl.emiratesId.text = saved["emiratesId"]?.toString() ??
            (m.emiratesIdPartnerShareholder ?? "");

        ctrl.passport.text = saved["passport"]?.toString() ??
            (m.passportNumberPartnerShareholder ?? "");

        ctrl.tradeLicense.text = saved["tradeLicense"]?.toString() ??
            (m.tradeLicenseNumberPartnerShareholder ?? "");

        ctrl.leiNumber.text = saved["leiNumber"]?.toString() ??
            (m.leiNumberPartnerShareholder ?? "");

        ///  THIS IS THE MOST IMPORTANT LINE
        ctrl.attach(m);

        vm.ctrls.add(ctrl);
      }
      vm.leiController.text = data["leiText"]?.toString() ??
          (vm.customerInformation.leiNumber ?? "");

      vm.controllerGroupImmediate.text =
          data["groupImmediateText"]?.toString() ??
              (vm.customerInformation.groupImmediateParent ?? "");

      vm.controllerGroupUltimate.text = data["groupUltimateText"]?.toString() ??
          (vm.customerInformation.groupUltimateParent ?? "");

      vm.capitalController.text =
          data["capital"]?.toString() ?? (vm.customerInformation.capital ?? "");

      vm.turnoverController.text = data["turnoverText"]?.toString() ??
          (vm.customerInformation.turnover ?? "");

      vm.auditorController.text = data["auditorText"]?.toString() ??
          (vm.customerInformation.auditor ?? "");

      vm.numberOfEmployeeController.text =
          data["numberOfEmployeeText"]?.toString() ??
              vm.customerInformation.numberOfEmployee?.toString() ??
              "";

      final borrowerId = _int(data["selectedBorroweSubsidiaryId"]);
      final leiId = _int(data["selectedLegalEntityIdentifierId"]);

      vm.selectedBorroweSubsidiary =
          _mapToUiInstance(vm.yesNoNaItems, borrowerId);

      vm.selectedLegalEntityIdentifier =
          _mapToUiInstance(vm.yesNoNaItems, leiId);

      final leiYes =
          vm.selectedLegalEntityIdentifier?.id == ServerConstants.yesRefId;

      vm.customerInformation.legalEntityIdentifier = leiYes;

      vm.emit(
        vm.state.copyWith(
          legalEntityIdentifier: leiYes,
        ),
      );

      /// ===============================
      /// EMIRATE FIX
      /// ===============================

      if (!leiYes) {
        vm.selectedEmirateLicense = vm.defaultField;

        vm.selectedEmirateEstablishment = vm.defaultField;

        vm.customerInformation.emiLic = vm.defaultField.name;

        vm.customerInformation.emiEst = vm.defaultField.name;
      } else {
        vm.selectedEmirateLicense = _mapEmirateFromCode(
          vm.ccsysEmirateList,
          vm.customerInformation.emiLic,
        );

        vm.selectedEmirateEstablishment = _mapEmirateFromCode(
          vm.ccsysEmirateList,
          vm.customerInformation.emiEst,
        );

        if (vm.selectedEmirateLicense != null) {
          vm.customerInformation.emiLic = vm.selectedEmirateLicense!.name;
        }

        if (vm.selectedEmirateEstablishment != null) {
          vm.customerInformation.emiEst = vm.selectedEmirateEstablishment!.name;
        }
      }

      logger.i("Draft restored successfully");
    } catch (e, st) {
      logger.e("Draft restore failed: $e");
      logger.e(st.toString());
    }

    vm.emit(
      vm.state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  Reference? _mapEmirateFromCode(List<Reference> list, String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final idPart = value.split("-").first;
    final id = int.tryParse(idPart);

    if (id == null) return null;

    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Reference? _mapToUiInstance(List<Reference> list, int? id) {
    if (id == null) return null;

    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String? _normalize(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  dynamic _jsonSafe(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) {
      return v.toIso8601String();
    }
    if (v is List) {
      return v.map(_jsonSafe).toList();
    }
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), _jsonSafe(val)));
    }
    return v;
  }

  Map<String, dynamic> _mapStringDynamic(Map map) {
    return map.map((k, v) => MapEntry(k.toString(), v));
  }

  List<PartnerShareholder> _restoreRows(
    dynamic raw,
    List<PartnerShareholder>? fallback,
  ) {
    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        return decoded
            .map(
              (e) => e is Map
                  ? PartnerShareholder.fromJson(_mapStringDynamic(e))
                  : null,
            )
            .whereType<PartnerShareholder>()
            .toList();
      }
    }

    if (raw is List) {
      return raw
          .map(
            (e) => e is Map
                ? PartnerShareholder.fromJson(_mapStringDynamic(e))
                : null,
          )
          .whereType<PartnerShareholder>()
          .toList();
    }

    return fallback ?? [];
  }
}
