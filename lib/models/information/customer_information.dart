import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Represents customer information including profile, relationship,
/// ownership, exception, and classification details.
class CustomerInformation {
  /// Creates a [CustomerInformation] instance.
  CustomerInformation({
    this.custInfoId,
    this.accountLevelSicCode,
    this.primaryBussinessActivity,
    this.existingcode,
    this.applicationRefNo,
    this.customerRimNumber,
    this.customerName,
    this.groupName,
    this.groupId,
    this.legalStatus,
    this.tradeLicenseNumber,
    this.tlIssuingAuthority,
    this.tlExpiryDate,
    this.industryDescription,
    this.industrySicCode,
    this.incorporateCountry,
    this.businessCountryList,
    this.establishmentDate,
    this.relationStartDate,
    this.borrowRelationShipDate,
    this.healthCode,
    this.purpose,
    this.cccStatus,
    this.locationAddress,
    this.correspondanceAddress,
    this.customerOwnerShipInfoList,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
    this.cbrbClasification,
    this.tradedCountryList,
    this.cbdCBRBClassification,
    this.borrowRelnDateEditable,
  });

  /// Creates a [CustomerInformation] instance from a JSON map.
  CustomerInformation.fromJson(Map<String, dynamic> json) {
    custInfoId = json["custInfoId"];
    applicationRefNo = json["applicationRefNo"];
    customerRimNumber = json["customerRimNumber"];
    customerName = json["customerName"];
    groupName = json["groupName"];
    groupId = json["groupId"];
    legalStatus = json["legalStatus"];
    tradeLicenseNumber = json["tradeLicenseNumber"];
    tlIssuingAuthority = json["tlIssuingAuthority"];
    tlExpiryDate = DateTimeUtils.intToDateTime(json["tlExpiryDate"]);
    industryDescription = json["industryDescription"];
    industrySicCode = json["industrySicCode"];
    incorporateCountry = json["incorporateCountry"];
    businessCountryList = json["businessCountryList"].cast<String>();
    establishmentDate = DateTimeUtils.intToDateTime(json["establishmentDate"]);
    relationStartDate = DateTimeUtils.intToDateTime(json["relatnStartDate"]);
    borrowRelationShipDate =
        DateTimeUtils.intToDateTime(json["borrowRelationShipDate"]);
    healthCode = json["healthCode"];
    purpose = json["purpose"];
    cccStatus = json["cccStatus"];
    locationAddress = json["locationAddress"];
    correspondanceAddress = json["correspondanceAddress"];
    if (json["customerOwnerShipInfoList"] != null) {
      customerOwnerShipInfoList = <CustomerOwnerShipInfo>[];
      json["customerOwnerShipInfoList"].forEach((v) {
        customerOwnerShipInfoList!.add(CustomerOwnerShipInfo.fromJson(v));
      });
    }
    if (json["exceptionList"] != null) {
      customerExceptionList = <CustomerException>[];
      json["exceptionList"].forEach((v) {
        customerExceptionList!.add(CustomerException.fromJson(v));
      });
    }
    createdDate = json["createdDate"];
    createdBy = json["createdBy"];
    updatedDate = json["updatedDate"];
    updatedBy = json["updatedBy"];
    cbrbClasification = json["cbrbClasification"];
    tradedCountryList = json["tradedCountryList"].cast<String>();
    cbdCBRBClassification = json["cbdCBRBClassification"];
    borrowRelnDateEditable = json["borrowRelnDateEditable"];
  }

  /// Unique identifier of the customer information.
  int? custInfoId;

  /// Application reference number.
  String? applicationRefNo;

  /// Customer RIM number.
  int? customerRimNumber;

  /// Customer name.
  String? customerName;

  /// Group name associated with the customer.
  String? groupName;

  /// Group identifier associated with the customer.
  int? groupId;

  /// Legal status of the customer.
  String? legalStatus;

  /// Trade license number of the customer.
  String? tradeLicenseNumber;

  /// Trade license issuing authority.
  String? tlIssuingAuthority;

  /// Trade license expiry date.
  DateTime? tlExpiryDate;

  /// Industry description of the customer.
  String? industryDescription;

  /// Industry SIC code of the customer.
  String? industrySicCode;

  /// Country of incorporation.
  String? incorporateCountry;

  /// List of business countries.
  List<String>? businessCountryList;

  /// Establishment date of the customer.
  DateTime? establishmentDate;

  /// Relationship start date.
  DateTime? relationStartDate;

  /// Borrowing relationship date.
  DateTime? borrowRelationShipDate;

  /// Health code of the customer.
  int? healthCode;

  /// Purpose value associated with the customer.
  int? purpose;

  /// CCC status of the customer.
  String? cccStatus;

  /// Location address of the customer.
  String? locationAddress;

  /// Correspondence address of the customer.
  String? correspondanceAddress;

  /// Customer ownership information list.
  List<CustomerOwnerShipInfo>? customerOwnerShipInfoList;

  /// Customer exception list.
  List<CustomerException>? customerExceptionList;

  /// Created date value.
  int? createdDate;

  /// User who created the customer information.
  String? createdBy;

  /// Updated date value.
  int? updatedDate;

  /// User who updated the customer information.
  String? updatedBy;

  /// CBRB classification value.
  String? cbrbClasification;

  /// List of traded countries.
  List<String>? tradedCountryList;

  /// CBD CBRB classification value.
  String? cbdCBRBClassification;

  /// Indicates whether borrowing relationship date is editable.
  bool? borrowRelnDateEditable;

  /// Country of business reference.
  Reference? countryOfBusiness;

  /// Country traded with reference.
  Reference? countryTradedWith;

  /// Existing code value.
  String? existingcode;

  /// Primary business activity value.
  String? primaryBussinessActivity;

  /// Account level SIC code.
  String? accountLevelSicCode;

  /// Converts this [CustomerInformation] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["custInfoId"] = custInfoId;
    data["applicationRefNo"] = applicationRefNo;
    data["customerRimNumber"] = customerRimNumber;
    data["customerName"] = customerName;
    data["groupName"] = groupName;
    data["groupId"] = groupId;
    data["legalStatus"] = legalStatus;
    data["tradeLicenseNumber"] = tradeLicenseNumber;
    data["tlIssuingAuthority"] = tlIssuingAuthority;
    data["tlExpiryDate"] = DateTimeUtils.datetimeToInt(tlExpiryDate);
    data["industryDescription"] = industryDescription;
    data["industrySicCode"] = industrySicCode;
    data["incorporateCountry"] = incorporateCountry;
    data["businessCountryList"] = businessCountryList;
    data["establishmentDate"] = establishmentDate;
    data["relatnStartDate"] = DateTimeUtils.datetimeToInt(relationStartDate);
    data["borrowRelationShipDate"] =
        DateTimeUtils.datetimeToInt(borrowRelationShipDate);
    data["healthCode"] = healthCode;
    data["purpose"] = purpose;
    data["cccStatus"] = cccStatus;
    data["locationAddress"] = locationAddress;
    data["correspondanceAddress"] = correspondanceAddress;
    if (customerOwnerShipInfoList != null) {
      data["customerOwnerShipInfoList"] =
          customerOwnerShipInfoList!.map((v) => v.toJson()).toList();
    }
    if (customerExceptionList != null) {
      data["exceptionList"] =
          customerExceptionList!.map((v) => v.toJson()).toList();
    }
    data["createdDate"] = createdDate;
    data["createdBy"] = createdBy;
    data["updatedDate"] = updatedDate;
    data["updatedBy"] = updatedBy;
    data["cbrbClasification"] = cbrbClasification;
    data["tradedCountryList"] = tradedCountryList;
    data["cbdCBRBClassification"] = cbdCBRBClassification;
    data["borrowRelnDateEditable"] = borrowRelnDateEditable;
    return data;
  }
}

/// Represents customer ownership information.
class CustomerOwnerShipInfo {
  /// Creates a [CustomerOwnerShipInfo] instance.
  CustomerOwnerShipInfo({
    this.custOwnId,
    this.custOwnershipName,
    this.custOwnershipRim,
    this.rim,
    this.nationality,
    this.shareHoldingPercentage,
    this.resident,
    this.beneficialOwnerhipPercentage,
    this.identificationDetail,
    this.identificationNumber,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
  });

  /// Creates a [CustomerOwnerShipInfo] instance from a JSON map.
  CustomerOwnerShipInfo.fromJson(Map<String, dynamic> json) {
    custOwnId = json["custOwnId"];
    custOwnershipName = json["custOwnershipName"];
    custOwnershipRim = json["custOwnershipRim"];
    rim = json["rim"];
    nationality = json["nationality"];
    shareHoldingPercentage = json["shareHoldingPercentage"];
    resident = json["resident"];
    beneficialOwnerhipPercentage = json["beneficialOwnerhipPercentage"];
    identificationDetail = json["identificationDetail"];
    identificationNumber = json["identificationNumber"];
    createdDate = json["createdDate"];
    createdBy = json["createdBy"];
    updatedDate = json["updatedDate"];
    updatedBy = json["updatedBy"];
    custOwnershipType = json["custOwnershipType"];
  }

  /// Unique identifier of the customer ownership record.
  int? custOwnId;

  /// Customer ownership name.
  String? custOwnershipName;

  /// Customer ownership RIM number.
  int? custOwnershipRim;

  /// RIM number.
  int? rim;

  /// Nationality of the owner.
  String? nationality;

  /// Share holding percentage.
  int? shareHoldingPercentage;

  /// Resident value.
  String? resident;

  /// Beneficial ownership percentage.
  int? beneficialOwnerhipPercentage;

  /// Identification detail.
  String? identificationDetail;

  /// Identification number.
  String? identificationNumber;

  /// Created date value.
  int? createdDate;

  /// User who created the ownership record.
  String? createdBy;

  /// Updated date value.
  int? updatedDate;

  /// User who updated the ownership record.
  String? updatedBy;

  /// Customer ownership type.
  String? custOwnershipType;

  /// Converts this [CustomerOwnerShipInfo] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["custOwnId"] = custOwnId;
    data["custOwnershipName"] = custOwnershipName;
    data["custOwnershipRim"] = custOwnershipRim;
    data["rim"] = rim;
    data["nationality"] = nationality;
    data["shareHoldingPercentage"] = shareHoldingPercentage;
    data["resident"] = resident;
    data["beneficialOwnerhipPercentage"] = beneficialOwnerhipPercentage;
    data["identificationDetail"] = identificationDetail;
    data["identificationNumber"] = identificationNumber;
    data["createdDate"] = createdDate;
    data["createdBy"] = createdBy;
    data["updatedDate"] = updatedDate;
    data["updatedBy"] = updatedBy;
    data["custOwnershipType"] = custOwnershipType;
    return data;
  }
}

/// Represents a customer exception.
class CustomerException {
  /// Creates a [CustomerException] instance.
  CustomerException({
    this.type,
    this.facilityId,
    this.description,
    this.dueDate,
    this.status,
    this.recommendations,
    this.delete,
  });

  /// Creates a [CustomerException] instance from a JSON map.
  CustomerException.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    facilityId = json["facilityId"];
    description = json["description"];
    dueDate = json["dueDate"];
    status = json["status"];
    recommendations = json["recommendations"];
    delete = json["delete"];
  }

  /// Type of the customer exception.
  String? type;

  /// Facility identifier associated with the exception.
  int? facilityId;

  /// Description of the exception.
  String? description;

  /// Due date value of the exception.
  int? dueDate;

  /// Status of the exception.
  String? status;

  /// Recommendations related to the exception.
  String? recommendations;

  /// Indicates whether the exception is marked for deletion.
  bool? delete;

  /// Converts this [CustomerException] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["type"] = type;
    data["facilityId"] = facilityId;
    data["description"] = description;
    data["dueDate"] = dueDate;
    data["status"] = status;
    data["recommendations"] = recommendations;
    data["delete"] = delete;
    return data;
  }
}
