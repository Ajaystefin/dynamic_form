class AssignToDetail {
  AssignToDetail({
    this.mode,
    this.userAction,
    this.assingToRoles,
    this.returnToUser,
    this.assignLinkName,
  });

  factory AssignToDetail.fromJson(Map<String, dynamic>? json) {
    return AssignToDetail(
      assingToRoles: json?["assignToRoleList"], // ?? "125, 126",
      mode: json?["mode"] ?? 1,
      returnToUser: json?["returnToUser"] ?? false,
      assignLinkName: json?["assignLinkName"],
      userAction: json?["userAction"] ?? 2126,
    );
  }
  int? mode;
  int? userAction;
  String? assingToRoles;
  bool? returnToUser;
  String? assignLinkName;
}

class Summary {
  Summary({
    // existing
    this.pendingWithMe,
    this.pendingWithFP,
    this.pendingWithBusiness,
    this.pendingWithCredit,
    this.pendingWithApprovingAuthority,
    this.pendingWithDocumentation,
    this.pendingWithCreditControl,
    this.pendingWithSegment,
    this.requestEnabledByCA,
    this.requestEnabledByCCProxy,
    this.requestEnabledByBODProxy,
    this.recentApplications,
    this.applicationsOverdue,
    this.applicationsDueForReview,
    this.returnedToRM,
    this.pendingWithTheFPChecker,
    this.pendingWithPool,
    this.pendingWithTeam,
    this.assigningRequestToMaker,
    this.pendingWithCA,
    this.assignRequestToCA,
    this.requestToRecommended,
    this.assignRequestToMe,
    this.returnedRequestDocumentation,
    this.recommentedRequest,
    this.draftFolInitiated,
    this.draftFolGenerated,
    this.finalFolInitiated,
    this.finalFolGenerated,
    this.documentationSubmitted,
    this.documentationCompleted,
    this.folCancelled,
    this.returnedToRO,
    this.returnedToCAM,
    this.returnedToRMB,
    this.returnedToSHB,
    this.returnedToSHLvlB,
    this.returnedToTLB,
    this.returnedToCCUM,
    this.returnedToDC,
    this.returnedToCCOOD,

    // new
    this.returnedToDocumentation,
    this.returnedToPool,
    this.returnedToCA,
    this.returnedToTLD1,
    this.returnedToSHD,
    this.returnedToSHC,
    this.returnedToSHBHyphen,
    this.returnedToSHB1,
    this.returnedToCCP,
    this.returnedToCCPA,
    this.returnedToBDP,
    this.pendingWithRelationShipTeam,
    this.pendingWithBusinessTeam,
  });

  factory Summary.fromJson(List<dynamic> jsonList) {
    final Map<int, AssignToDetail?> defaultMap = {-1: null};
    // Safely build a Map<String, int> from list items
    final Map<String, Map<int, AssignToDetail?>> dataMap = {
      for (final item in jsonList)
        if (item is Map && item["key"] != null && item["count"] != null)
          item["key"] as String: {
            (item["count"] as num).toInt():
                AssignToDetail.fromJson(item["assignToDetail"]),
            // item['assignToRoleList']
          },
    };

    return Summary(
      pendingWithRelationShipTeam:
          dataMap["pendingWithRelationShipTeam"] ?? defaultMap,
      pendingWithBusinessTeam: dataMap["pendingWithBusinessTeam"] ?? defaultMap,
      pendingWithMe: dataMap["pendingWithMe"] ?? defaultMap,
      pendingWithFP: dataMap["pendingWithFP"] ?? defaultMap,
      pendingWithBusiness: dataMap["pendingWithBusiness"] ?? defaultMap,
      pendingWithCredit: dataMap["pendingWithCredit"] ?? defaultMap,
      pendingWithApprovingAuthority:
          dataMap["pendingWithApprovingAuthority"] ?? defaultMap,
      pendingWithDocumentation:
          dataMap["pendingWithDocumentation"] ?? defaultMap,
      pendingWithCreditControl:
          dataMap["pendingWithCreditControl"] ?? defaultMap,
      pendingWithSegment: dataMap["pendingWithSegment"] ?? defaultMap,
      requestEnabledByCA: dataMap["requestEnabledByCA"] ?? defaultMap,
      requestEnabledByCCProxy: dataMap["requestEnabledByCCProxy"] ?? defaultMap,
      requestEnabledByBODProxy:
          dataMap["requestEnabledByBODProxy"] ?? defaultMap,
      recentApplications: dataMap["recentApplications"] ?? defaultMap,
      applicationsOverdue: dataMap["applicationsOverdue"] ?? defaultMap,
      applicationsDueForReview:
          dataMap["applicationsDueForReview"] ?? defaultMap,
      returnedToRM: dataMap["returnedToRM"] ?? defaultMap,
      pendingWithTheFPChecker: dataMap["pendingWithTheFPChecker"] ?? defaultMap,
      pendingWithPool: dataMap["pendingWithPool"] ?? defaultMap,
      pendingWithTeam: dataMap["pendingWithTeam"] ?? defaultMap,
      assigningRequestToMaker: dataMap["assigningRequestToMaker"] ?? defaultMap,
      pendingWithCA: dataMap["pendingWithCA"] ?? defaultMap,
      assignRequestToCA: dataMap["assignRequestToCA"] ?? defaultMap,
      requestToRecommended: dataMap["requestToRecommended"] ??
          dataMap["requestToRecommend"] ??
          defaultMap,
      assignRequestToMe: dataMap["assignRequestToMe"] ?? defaultMap,
      returnedRequestDocumentation:
          dataMap["returnedRequestDocumentation"] ?? defaultMap,
      recommentedRequest: dataMap["recommentedRequest"] ?? defaultMap,
      draftFolInitiated: dataMap["draftFolInitiated"] ?? defaultMap,
      draftFolGenerated: dataMap["draftFolGenerated"] ?? defaultMap,
      finalFolInitiated: dataMap["finalFolInitiated"] ?? defaultMap,
      finalFolGenerated: dataMap["finalFolGenerated"] ?? defaultMap,
      documentationSubmitted: dataMap["documentationSubmitted"] ?? defaultMap,
      documentationCompleted: dataMap["documentationCompleted"] ?? defaultMap,
      folCancelled: dataMap["folCancelled"] ?? defaultMap,
      returnedToRO: dataMap["returnedToRO"] ?? defaultMap,
      returnedToCAM: dataMap["returnedToCAM"] ?? defaultMap,
      returnedToRMB: dataMap["returnedToRMB"] ?? defaultMap,
      returnedToSHB: dataMap["returnedToSHB"] ?? defaultMap,
      returnedToSHLvlB: dataMap["returnedToSH-B"] ?? defaultMap,
      returnedToTLB: dataMap["returnedToTLB"] ?? defaultMap,
      returnedToCCUM: dataMap["returnedToCCUM"] ?? defaultMap,
      returnedToDC: dataMap["returnedToDC"] ?? defaultMap,
      returnedToCCOOD: dataMap["returnedToCCOOD"] ?? defaultMap,

      // new mappings (hyphenated keys preserved on the JSON side)
      returnedToDocumentation: dataMap["returnedToDocumentation"] ?? defaultMap,
      returnedToPool: dataMap["returnedToPool"] ?? defaultMap,
      returnedToCA: dataMap["returnedToCA"] ?? defaultMap,
      returnedToTLD1: dataMap["returnedToTL-D1"] ?? defaultMap,
      returnedToSHD: dataMap["returnedToSH-D"] ?? defaultMap,
      returnedToSHC: dataMap["returnedToSH-C"] ?? defaultMap,
      returnedToSHBHyphen: dataMap["returnedToSH-B"] ?? defaultMap,
      returnedToSHB1: dataMap["returnedToSH-B1"] ?? defaultMap,
      returnedToCCP: dataMap["returnedToCCP"] ?? defaultMap,
      returnedToCCPA: dataMap["returnedToCCPA"] ?? defaultMap,
      returnedToBDP: dataMap["returnedToBDP"] ?? defaultMap,
    );
  }
  Map<int, AssignToDetail?>? pendingWithMe;
  Map<int, AssignToDetail?>? pendingWithFP;
  Map<int, AssignToDetail?>? pendingWithBusiness;
  Map<int, AssignToDetail?>? pendingWithCredit;
  Map<int, AssignToDetail?>? pendingWithApprovingAuthority;
  Map<int, AssignToDetail?>? pendingWithDocumentation;
  Map<int, AssignToDetail?>? pendingWithCreditControl;
  Map<int, AssignToDetail?>? pendingWithSegment;
  Map<int, AssignToDetail?>? requestEnabledByCA;
  Map<int, AssignToDetail?>? requestEnabledByCCProxy;
  Map<int, AssignToDetail?>? requestEnabledByBODProxy;
  Map<int, AssignToDetail?>? recentApplications;
  Map<int, AssignToDetail?>? applicationsOverdue;
  Map<int, AssignToDetail?>? applicationsDueForReview;
  Map<int, AssignToDetail?>? returnedToRM;
  Map<int, AssignToDetail?>? pendingWithTheFPChecker;
  Map<int, AssignToDetail?>? pendingWithPool;
  Map<int, AssignToDetail?>? pendingWithTeam;
  Map<int, AssignToDetail?>? assigningRequestToMaker;
  Map<int, AssignToDetail?>? pendingWithCA;
  Map<int, AssignToDetail?>? assignRequestToCA;
  Map<int, AssignToDetail?>? requestToRecommended;
  Map<int, AssignToDetail?>? assignRequestToMe;
  Map<int, AssignToDetail?>? returnedRequestDocumentation;
  Map<int, AssignToDetail?>? recommentedRequest;
  Map<int, AssignToDetail?>? draftFolInitiated;
  Map<int, AssignToDetail?>? draftFolGenerated;
  Map<int, AssignToDetail?>? finalFolInitiated;
  Map<int, AssignToDetail?>? finalFolGenerated;
  Map<int, AssignToDetail?>? documentationSubmitted;
  Map<int, AssignToDetail?>? documentationCompleted;
  Map<int, AssignToDetail?>? folCancelled;
  Map<int, AssignToDetail?>? returnedToRO;
  Map<int, AssignToDetail?>? returnedToCAM;
  Map<int, AssignToDetail?>? returnedToTLB;
  Map<int, AssignToDetail?>? returnedToSHB;
  Map<int, AssignToDetail?>? returnedToSHLvlB;
  Map<int, AssignToDetail?>? returnedToRMB;
  Map<int, AssignToDetail?>? returnedToCCUM;
  Map<int, AssignToDetail?>? returnedToDC;
  Map<int, AssignToDetail?>? returnedToCCOOD;
  Map<int, AssignToDetail?>? returnedToDocumentation;
  Map<int, AssignToDetail?>? returnedToPool;
  Map<int, AssignToDetail?>? returnedToCA;
  Map<int, AssignToDetail?>? returnedToTLD1;
  Map<int, AssignToDetail?>? returnedToSHD;
  Map<int, AssignToDetail?>? returnedToSHC;
  Map<int, AssignToDetail?>? returnedToSHBHyphen;
  Map<int, AssignToDetail?>? returnedToSHB1;
  Map<int, AssignToDetail?>? returnedToCCP;
  Map<int, AssignToDetail?>? returnedToCCPA;
  Map<int, AssignToDetail?>? returnedToBDP;
  Map<int, AssignToDetail?>? pendingWithRelationShipTeam;
  Map<int, AssignToDetail?>? pendingWithBusinessTeam;

  /// Returns the first map that is non-null, non-empty, and has at least one
  /// key != -1.
  Map<int, AssignToDetail?>? firstValidMap() {
    for (final Map<int, AssignToDetail?>? summaryMap in _allSummaries) {
      if (summaryMap != null &&
          summaryMap.isNotEmpty &&
          summaryMap.keys.any((k) => k != -1)) {
        return summaryMap;
      }
    }
    return null;
  }

  /// Keep a single ordered list of all your map fields for easy iteration.
  List<Map<int, AssignToDetail?>?> get _allSummaries => [
        pendingWithMe,
        pendingWithFP,
        pendingWithBusiness,
        pendingWithCredit,
        pendingWithApprovingAuthority,
        pendingWithDocumentation,
        pendingWithCreditControl,
        pendingWithSegment,
        requestEnabledByCA,
        requestEnabledByCCProxy,
        requestEnabledByBODProxy,
        recentApplications,
        applicationsOverdue,
        applicationsDueForReview,
        returnedToRM,
        pendingWithTheFPChecker,
        pendingWithPool,
        pendingWithTeam,
        assigningRequestToMaker,
        pendingWithCA,
        assignRequestToCA,
        requestToRecommended,
        assignRequestToMe,
        returnedRequestDocumentation,
        recommentedRequest,
        draftFolInitiated,
        draftFolGenerated,
        finalFolInitiated,
        finalFolGenerated,
        documentationSubmitted,
        documentationCompleted,
        folCancelled,
        returnedToRO,
        returnedToCAM,
        returnedToTLB,
        returnedToSHB,
        returnedToSHLvlB,
        returnedToRMB,
        returnedToCCUM,
        returnedToDC,
        returnedToCCOOD,
        returnedToDocumentation,
        returnedToPool,
        returnedToCA,
        returnedToTLD1,
        returnedToSHD,
        returnedToSHC,
        returnedToSHBHyphen,
        returnedToSHB1,
        returnedToCCP,
        returnedToCCPA,
        returnedToBDP,
        pendingWithRelationShipTeam,
        pendingWithBusinessTeam,
      ];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // existing
    data["pendingWithMe"] = pendingWithMe;
    data["pendingWithFP"] = pendingWithFP;
    data["pendingWithBusiness"] = pendingWithBusiness;
    data["pendingWithCredit"] = pendingWithCredit;
    data["pendingWithApprovingAuthority"] = pendingWithApprovingAuthority;
    data["pendingWithDocumentation"] = pendingWithDocumentation;
    data["pendingWithCreditControl"] = pendingWithCreditControl;
    data["pendingWithSegment"] = pendingWithSegment;
    data["requestEnabledByCA"] = requestEnabledByCA;
    data["requestEnabledByCCProxy"] = requestEnabledByCCProxy;
    data["requestEnabledByBODProxy"] = requestEnabledByBODProxy;
    data["recentApplications"] = recentApplications;
    data["applicationsOverdue"] = applicationsOverdue;
    data["applicationsDueForReview"] = applicationsDueForReview;
    data["returnedToRM"] = returnedToRM;
    data["pendingWithTheFPChecker"] = pendingWithTheFPChecker;
    data["pendingWithPool"] = pendingWithPool;
    data["pendingWithTeam"] = pendingWithTeam;
    data["assigningRequestToMaker"] = assigningRequestToMaker;
    data["pendingWithCA"] = pendingWithCA;
    data["assignRequestToCA"] = assignRequestToCA;
    data["requestToRecommended"] = requestToRecommended;
    data["assignRequestToMe"] = assignRequestToMe;
    data["returnedRequestDocumentation"] = returnedRequestDocumentation;
    data["recommentedRequest"] = recommentedRequest;
    data["draftFolInitiated"] = draftFolInitiated;
    data["draftFolGenerated"] = draftFolGenerated;
    data["finalFolInitiated"] = finalFolInitiated;
    data["finalFolGenerated"] = finalFolGenerated;
    data["documentationSubmitted"] = documentationSubmitted;
    data["documentationCompleted"] = documentationCompleted;
    data["folCancelled"] = folCancelled;
    data["returnedToRO"] = returnedToRO;
    data["returnedToCAM"] = returnedToCAM;
    data["returnedToRMB"] = returnedToRMB;
    data["returnedToSHB"] = returnedToSHB;
    data["returnedToSH-B"] = returnedToSHLvlB;
    data["returnedToTLB"] = returnedToTLB;
    data["returnedToCCUM"] = returnedToCCUM;
    data["returnedToDC"] = returnedToDC;
    data["returnedToCCOOD"] = returnedToCCOOD;

    // new (emit backend keys verbatim, including hyphens where they exist)
    data["returnedToDocumentation"] = returnedToDocumentation;
    data["returnedToPool"] = returnedToPool;
    data["returnedToCA"] = returnedToCA;
    data["returnedToTL-D1"] = returnedToTLD1;
    data["returnedToSH-D"] = returnedToSHD;
    data["returnedToSH-C"] = returnedToSHC;
    data["returnedToSH-B"] = returnedToSHBHyphen;
    data["returnedToSH-B1"] = returnedToSHB1;
    data["returnedToCCP"] = returnedToCCP;
    data["returnedToCCPA"] = returnedToCCPA;
    data["returnedToBDP"] = returnedToBDP;

    return data;
  }
}
