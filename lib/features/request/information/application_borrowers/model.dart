import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/state.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class ApplicationBorrowersViewModel
    extends SafeCubit<ApplicationBorrowersState> {
  ApplicationBorrowersViewModel()
      : super(ApplicationBorrowersState(loaderStatus: LoadingStatus.loading));

  late RequestRepository repository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Customer> applicationBorrowers = [];
  List<Customer> customers = [];
  List<Customer> selectedCustomers = [];

  int? primaryRim;
  bool isFI = false;

  /// Current page mode (edit/view).
  PageMode pagemode = PageMode.na;
  bool get isReadOnly => Globals.request?.isRequestCreated ?? false;

  // ------------------------------------------------------------
  // FINAL HYBRID MERGED INIT()
  // ------------------------------------------------------------
  Future<void> init(BuildContext context) async {
    logger.i("initialising ApplicationBorrowersViewModel");

    repository = RequestRepository.instance;
    pagemode = AuthRepository.getPageMode(RightConstants.applicationBorrowers);

    // Shared: detect FI request
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    // Both versions load borrowers → merge as shared logic
    customers = Globals.request?.borrowers ?? [];
    selectedCustomers = [];

    // debugPrint(jsonEncode(Globals.request?.borrowers));

    // ------------------------------------------------------------
    // Shared RIM resolution logic
    // ------------------------------------------------------------
    final int? searchedRimNo = Globals.request?.customerRimNo ??
        (customers.isNotEmpty ? customers.first.customerRimNo : null);

    final int? groupOwnerRimNo = customers.map<int?>((c) {
      final dynamic go = c.groups?.groupOwner ?? c.groupOwner;
      if (go == null) return null;
      if (go is int) return go;
      return int.tryParse(go.toString());
    }).firstWhere((id) => id != null, orElse: () => null);

    int? rimNoToPin;
    if (searchedRimNo != null &&
        groupOwnerRimNo != null &&
        searchedRimNo != groupOwnerRimNo) {
      rimNoToPin = searchedRimNo;
    } else if (groupOwnerRimNo != null) {
      rimNoToPin = groupOwnerRimNo;
    } else {
      rimNoToPin = searchedRimNo;
    }

    primaryRim = rimNoToPin;

    // ------------------------------------------------------------
    // READONLY-ONLY SECTION
    // ------------------------------------------------------------
    if (isReadOnly) {
      CustomerType? resolveType(Customer c) {
        if (c.type != null) return c.type;
        return null;
      }

      for (final c in customers) {
        final CustomerType? t = resolveType(c);
        switch (t) {
          case CustomerType.investmentGradeBanks:
            if (c.isCountryFI == false) {
              c
                ..isSelected = true
                ..isSelectedBelowGrade = false
                ..isSelectedCountryFI = false;
            }

          case CustomerType.belowInvestmentGradeBanks:
            if (c.isCountryFI == false) {
              c
                ..isSelectedBelowGrade = true
                ..isSelected = false
                ..isSelectedCountryFI = false;
            }

          case CustomerType.country:
            c.isCountryFI = true;
            c.isSelectedCountryFI = true;
            c.isSelected = false;
            c.isSelectedBelowGrade = false;
          case CustomerType.corporate:
            c.isCountryFI = false;
            c.isSelectedCountryFI = false;
            c.isSelected = true;
            c.isSelectedBelowGrade = false;
          default:
            break;
        }
      }
    }

    // ------------------------------------------------------------
    // EDITABLE MODE ONLY (from model.dart)
    // ------------------------------------------------------------
    else {
      // INSERTED MISSING LOGIC
      if (isFI) {
        final Map<int, String> rimToClassCode = {
          for (final Customer customer
              in (Globals.request?.fiCustomerListCountry ?? [])
                  .whereType<Customer>())
            if ((customer.id ?? "").trim().isNotEmpty &&
                (customer.classCode ?? "").trim().isNotEmpty)
              if (int.tryParse(customer.id!.trim()) != null)
                int.parse(customer.id!.trim()): customer.classCode!.trim(),
        };

        for (final Customer customerIsCountry in customers) {
          final int? rimNo = customerIsCountry.customerRimNo is int
              ? customerIsCountry.customerRimNo!
              : int.tryParse(customerIsCountry.customerRimNo?.toString() ?? "");

          final String? code = rimNo != null ? rimToClassCode[rimNo] : null;
          final bool isCountry = code == ServerConstants.countryClassCode;

          customerIsCountry
            ..isCountryFI = isCountry
            ..isSelectedCountryFI = isCountry;
        }
      }

      // UPDATED LOGIC — NOW INCLUDES COUNTRY RIMS
      selectedCustomers = customers.where((customer) {
        return (customer.isSelected ?? false) ||
            (customer.isSelectedBelowGrade ?? false) ||
            (customer.isSelectedCountryFI ?? false);
      }).toList();
    }

    // ------------------------------------------------------------
    // PINNING (shared)
    // ------------------------------------------------------------
    if (primaryRim != null) {
      final int idx =
          customers.indexWhere((c) => c.customerRimNo == primaryRim);
      if (idx >= 0) {
        final Customer pinned = customers.removeAt(idx);

        if (!isFI &&
            !isReadOnly &&
            pinned.isSelected != true &&
            pinned.isSelectedBelowGrade != true &&
            pinned.isSelectedCountryFI != true) {
          pinned.isSelected = true;
        }

        customers
          ..removeWhere((c) => c.customerRimNo == pinned.customerRimNo)
          ..insert(0, pinned);
      }
    }

    // ------------------------------------------------------------
    // DEDUPE (shared)
    // ------------------------------------------------------------
    final Set<int> seen = {};
    customers = customers.where((c) {
      final r = c.customerRimNo;
      if (r == null || seen.contains(r)) return false;
      seen.add(r);
      return true;
    }).toList();

    // ------------------------------------------------------------
    // SELECTED LIST BUILD (readonly overrides editable)
    // ------------------------------------------------------------
    if (isReadOnly) {
      selectedCustomers = customers.where((c) {
        return (c.isSelected ?? false) ||
            (c.isSelectedBelowGrade ?? false) ||
            (c.isSelectedCountryFI ?? false);
      }).toList();
    } else {
      if (isFI) {
        selectedCustomers = customers.where((customer) {
          return (customer.isSelected ?? false) ||
              (customer.isSelectedBelowGrade ?? false) ||
              (customer.isSelectedCountryFI ?? false);
        }).toList();
      } else {
        selectedCustomers = customers.where((customer) {
          return (customer.isSelected ?? false) ||
              (customer.isSelectedBelowGrade ?? false);
        }).toList();
      }
    }

    debugPrint("FI=$isFI, ReadOnly=$isReadOnly, customers=${customers.length}, "
        "IG=${customers.where((c) => c.isSelected == true).length}, "
        "BIG=${customers.where((c) => c.isSelectedBelowGrade == true).length}, "
        "COUNTRY=${customers.where(
              (c) => c.isSelectedCountryFI == true,
            ).length}");

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // ------------------------------------------------------------
  // SAVE HANDLER (shared)
  // ------------------------------------------------------------
  void onSaveButtonPressed(
    BuildContext context, {
    required bool navigationOrder,
  }) {
    if (!isReadOnly) {
      Globals.request
        ?..customers = customers
        ..borrowers = customers;

      if (!validateBorrowersSelection()) {
        return;
      }

      if (!context.mounted) return;

      router.go(
        navigationOrder ? Routes.requestInformation : Routes.groupBorrowers,
      );
    } else {
      router.go(
        navigationOrder ? Routes.requestInformation : Routes.groupBorrowers,
      );
    }
  }

  bool validateBorrowersSelection() {
    final List<Customer> customers = Globals.request?.customers ?? [];
    if (customers.isEmpty) {
      AlertManager().showFailureToast(
        "requestInformation.applicationBorrowers.validationMessage".tr(),
      );
      return false;
    }

    bool isCustomerSelected(Customer c) {
      if (isFI) {
        return (c.isSelected ?? false) ||
            (c.isSelectedBelowGrade ?? false) ||
            (c.isSelectedCountryFI ?? false);
      }
      return c.isSelected ?? false;
    }

    // At least one selected customer
    // if (!customers.any(isCustomerSelected)) {
    //   AlertManager().showFailureToast(
    //     'requestInformation.applicationBorrowers.validationMessage'.tr(),
    //   );
    //   return false;
    // }

    // Primary RIM must exist AND be selected
    if (primaryRim != null) {
      final bool hasPrimarySelected = customers.any(
        (c) => c.customerRimNo == primaryRim && isCustomerSelected(c),
      );

      if (!hasPrimarySelected) {
        AlertManager().showFailureToast(
          "requestInformation.applicationBorrowers.validationMessagePrimaryRims"
              .tr(),
        );
        return false;
      }
    }

    return true;
  }

  // ------------------------------------------------------------
  // IG / BIG / COUNTRY selection handlers (kept exactly)
  // ------------------------------------------------------------

  void onCustomerRimNameSelected(String rim, bool isSelected) {
    if (!isFI &&
        primaryRim != null &&
        rim == primaryRim.toString() &&
        !isSelected) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    final customer =
        customers.firstWhere((c) => c.customerRimNo.toString() == rim);

    if (customer.isCountryFI == true) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    customer.isSelected = isSelected;
    if (isSelected) customer.isSelectedBelowGrade = false;

    selectedCustomers.removeWhere((c) => c.customerRimNo.toString() == rim);
    if (isSelected) selectedCustomers.add(customer);

    if (!isFI && primaryRim != null) {
      selectedCustomers.sort((a, b) {
        if (a.customerRimNo == primaryRim) return -1;
        if (b.customerRimNo == primaryRim) return 1;
        return 0;
      });
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onBelowGradeSelected(String rim, bool isSelected) {
    final customer =
        customers.firstWhere((c) => c.customerRimNo.toString() == rim);

    if (customer.isCountryFI == true) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    customer.isSelectedBelowGrade = isSelected;
    if (isSelected) customer.isSelected = false;

    selectedCustomers.removeWhere((c) => c.customerRimNo.toString() == rim);
    if (isSelected) selectedCustomers.add(customer);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onCountrySelected(String rim, bool isSelected) {
    final customer =
        customers.firstWhere((c) => c.customerRimNo.toString() == rim);

    if (customer.isCountryFI != true) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    customer
      ..isSelectedCountryFI = isSelected
      ..isSelected = false
      ..isSelectedBelowGrade = false;

    selectedCustomers.removeWhere((c) => c.customerRimNo.toString() == rim);
    if (isSelected) selectedCustomers.add(customer);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
