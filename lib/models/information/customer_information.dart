import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CustomerInformation {
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
  int? custInfoId;
  String? applicationRefNo;
  int? customerRimNumber;
  String? customerName;
  String? groupName;
  int? groupId;
  String? legalStatus;
  String? tradeLicenseNumber;
  String? tlIssuingAuthority;
  DateTime? tlExpiryDate;
  String? industryDescription;
  String? industrySicCode;
  String? incorporateCountry;
  List<String>? businessCountryList;
  DateTime? establishmentDate;
  DateTime? relationStartDate;
  DateTime? borrowRelationShipDate;
  int? healthCode;
  int? purpose;
  String? cccStatus;
  String? locationAddress;
  String? correspondanceAddress;
  List<CustomerOwnerShipInfo>? customerOwnerShipInfoList;
  List<CustomerException>? customerExceptionList;
  int? createdDate;
  String? createdBy;
  int? updatedDate;
  String? updatedBy;
  String? cbrbClasification;
  List<String>? tradedCountryList;
  String? cbdCBRBClassification;
  bool? borrowRelnDateEditable;

  Reference? countryOfBusiness;

  Reference? countryTradedWith;

  String? existingcode;

  String? primaryBussinessActivity;

  String? accountLevelSicCode;

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

class CustomerOwnerShipInfo {
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
  int? custOwnId;
  String? custOwnershipName;
  int? custOwnershipRim;
  int? rim;
  String? nationality;
  int? shareHoldingPercentage;
  String? resident;
  int? beneficialOwnerhipPercentage;
  String? identificationDetail;
  String? identificationNumber;
  int? createdDate;
  String? createdBy;
  int? updatedDate;
  String? updatedBy;
  String? custOwnershipType;

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

class CustomerException {
  CustomerException({
    this.type,
    this.facilityId,
    this.description,
    this.dueDate,
    this.status,
    this.recommendations,
    this.delete,
  });

  CustomerException.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    facilityId = json["facilityId"];
    description = json["description"];
    dueDate = json["dueDate"];
    status = json["status"];
    recommendations = json["recommendations"];
    delete = json["delete"];
  }
  String? type;
  int? facilityId;
  String? description;
  int? dueDate;
  String? status;
  String? recommendations;
  bool? delete;

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
