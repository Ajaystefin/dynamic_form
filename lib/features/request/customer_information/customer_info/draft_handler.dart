import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

class CustomerInfoDraftHandler extends DraftHandler<CustomerInfoViewModel> {
  String resolveDraftKey(CustomerInfoViewModel vm) {
    final rim = vm.selectedCustomer?.customerRimNo;
    return rim != null ? "${vm.draftFormKey}_$rim" : vm.draftFormKey;
  }

  @override
  Map<String, dynamic> buildDraftData(CustomerInfoViewModel vm) {
    if (vm.formKey.currentState != null && vm.formKey.currentState!.mounted) {
      vm.formKey.currentState?.save();
    }
    return {
      "customerInfo": {
        ...?vm.customerInformation?.toSaveJson(),

        //OVERRIDE long fields with UI string values
        "tlExpiryDate": vm.customerInformation?.tlExpiryDate,
        "relatnStartDate": vm.customerInformation?.relatnStartDate,
        "establishmentDate": vm.customerInformation?.establishmentDate,
        "borrowRelationShipDate":
            vm.customerInformation?.borrowRelationShipDate,
      },
      "customerOwnershipInfo":
          vm.customerOwnerShipInfo?.map((e) => e.toJson()).toList(),
      "borrowerExcption": vm.customerException?.map((e) {
        final Map<String, dynamic> json = e.toJson();
        json["dueDate"] = e.dueDate; //string
        json.remove("dueDateLong"); //ensure long not stored
        return json;
      }).toList(),
    };
  }

  @override
  void applyDraft(
    CustomerInfoViewModel vm,
    Map<String, dynamic> data,
  ) {
    final int? selectedRim = vm.selectedCustomer?.customerRimNo;
    final int? selectedCustInfoId = vm.customerInformation?.custInfoId;

    // --------------------------------------------------
    // CustomerInfo — match by rimNo
    // --------------------------------------------------
    final dynamic customerJson = data["customerInfo"];
    if (customerJson != null) {
      final int? draftRim = customerJson["rimNo"];

      if (draftRim == selectedRim) {
        //Apply CustomerInfo
        vm.customerInformation ??= Customer();
        vm.customerInformation = Customer.fromJson(customerJson);

        // Ensure long fields are recalculated later
        vm.customerInformation!.tlExpiryDateLong = null;
        vm.customerInformation!.relatnStartDateLong = null;
        vm.customerInformation!.establishmentDateLong = null;
        vm.customerInformation!.borrowRelationShipDateLong = null;

        //Ownership (draft fully replaces list)
        if (data["customerOwnershipInfo"] != null) {
          vm.customerOwnerShipInfo = (data["customerOwnershipInfo"] as List)
              .map((e) => CustomerOwnerShipInfo.fromJson(e))
              .toList();
        }

        // Exceptions
        if (data["borrowerExcption"] != null) {
          vm.customerException = (data["borrowerExcption"] as List)
              .map((e) => CustomerException.fromJson(e))
              .toList();

          // Clear long values to force recalculation
          for (final ex in vm.customerException!) {
            ex.dueDateLong = null;
          }
        }
      }
    }

    // --------------------------------------------------
    // Debug logs (keep for verification)
    // --------------------------------------------------
    logger.i("Selected RIM: $selectedRim");
    logger.i("Selected custInfoId: $selectedCustInfoId");
    logger.i("Ownership rows: ${vm.customerOwnerShipInfo?.length}");
    logger.i("Exception rows: ${vm.customerException?.length}");
  }
}
