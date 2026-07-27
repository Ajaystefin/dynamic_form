/// Represents assignment details including roles and actions.
class AssignToDetail {
  /// Creates an [AssignToDetail] instance.
  AssignToDetail({
    this.mode,
    this.userAction,
    this.assingToRoles,
    this.returnToUser,
    this.assignLinkName,
  });

  /// Creates an [AssignToDetail] instance from a JSON map.
  factory AssignToDetail.fromJson(Map<String, dynamic>? json) {
    return AssignToDetail(
      assingToRoles: json?["assignToRoleList"], // ?? "125, 126",
      mode: json?["mode"] ?? 1,
      returnToUser: json?["returnToUser"] ?? false,
      assignLinkName: json?["assignLinkName"],
      userAction: json?["userAction"] ?? 2126,
    );
  }

  /// Mode of assignment.
  int? mode;

  /// User action identifier.
  int? userAction;

  /// Assigned roles (comma-separated string).
  String? assingToRoles;

  /// Indicates if return-to-user is enabled.
  bool? returnToUser;

  /// Display name for assignment link.
  String? assignLinkName;
}

/// Represents summary data for different workflow states.
class Summary {
  /// Creates a [Summary] instance.
  Summary({
    // existing
    this.pendingWithMe,
    this.pendingWithFP,
    this.pendingWithBusiness,
    this.pendingWithCredit,
    this.pendingWithApprovingAuthority,
    this.pendingWithDocumentation,
    this.pendingWithCreditControl,
    this.pendingWithCreditControlCCSYS,
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

  /// Creates [Summary] from JSON list.
  factory Summary.fromJson(List<dynamic> jsonList) {
    final defaultMap = <int, AssignToDetail?>{-1: null};
    // Safely build a Map<String, int> from list items
    final dataMap = <String, Map<int, AssignToDetail?>>{
      for (final item in jsonList)
        if (item is Map && item["key"] != null && item["count"] != null)
          item["key"] as String: <int, AssignToDetail?>{
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
      pendingWithCreditControlCCSYS:
          dataMap["pendingWithCreditControl-CCSYS"] ?? defaultMap,
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

  /// Requests pending with current user.
  Map<int, AssignToDetail?>? pendingWithMe;

  /// Requests pending with FP.
  Map<int, AssignToDetail?>? pendingWithFP;

  /// Requests pending with business team.
  Map<int, AssignToDetail?>? pendingWithBusiness;

  /// Requests pending with credit team.
  Map<int, AssignToDetail?>? pendingWithCredit;

  /// Requests pending with approving authority.
  Map<int, AssignToDetail?>? pendingWithApprovingAuthority;

  /// Requests pending with documentation.
  Map<int, AssignToDetail?>? pendingWithDocumentation;

  /// Requests pending with credit control.
  Map<int, AssignToDetail?>? pendingWithCreditControl;

  /// Requests pending with credit control CCSYS.
  Map<int, AssignToDetail?>? pendingWithCreditControlCCSYS;

  /// Requests pending with segment team.
  Map<int, AssignToDetail?>? pendingWithSegment;

  /// Requests enabled by CA.
  Map<int, AssignToDetail?>? requestEnabledByCA;

  /// Requests enabled by CC proxy.
  Map<int, AssignToDetail?>? requestEnabledByCCProxy;

  /// Requests enabled by BOD proxy.
  Map<int, AssignToDetail?>? requestEnabledByBODProxy;

  /// Recently created applications.
  Map<int, AssignToDetail?>? recentApplications;

  /// Applications overdue.
  Map<int, AssignToDetail?>? applicationsOverdue;

  /// Applications due for review.
  Map<int, AssignToDetail?>? applicationsDueForReview;

  /// Requests returned to RM.
  Map<int, AssignToDetail?>? returnedToRM;

  /// Requests pending with FP checker.
  Map<int, AssignToDetail?>? pendingWithTheFPChecker;

  /// Requests pending with pool.
  Map<int, AssignToDetail?>? pendingWithPool;

  /// Requests pending with team.
  Map<int, AssignToDetail?>? pendingWithTeam;

  /// Requests assigned to maker.
  Map<int, AssignToDetail?>? assigningRequestToMaker;

  /// Requests pending with CA.
  Map<int, AssignToDetail?>? pendingWithCA;

  /// Requests assigned to CA.
  Map<int, AssignToDetail?>? assignRequestToCA;

  /// Requests recommended.
  Map<int, AssignToDetail?>? requestToRecommended;

  /// Requests assigned to current user.
  Map<int, AssignToDetail?>? assignRequestToMe;

  /// Requests returned for documentation.
  Map<int, AssignToDetail?>? returnedRequestDocumentation;

  /// Recommended requests.
  Map<int, AssignToDetail?>? recommentedRequest;

  /// Draft FOL initiated.
  Map<int, AssignToDetail?>? draftFolInitiated;

  /// Draft FOL generated.
  Map<int, AssignToDetail?>? draftFolGenerated;

  /// Final FOL initiated.
  Map<int, AssignToDetail?>? finalFolInitiated;

  /// Final FOL generated.
  Map<int, AssignToDetail?>? finalFolGenerated;

  /// Documentation submitted.
  Map<int, AssignToDetail?>? documentationSubmitted;

  /// Documentation completed.
  Map<int, AssignToDetail?>? documentationCompleted;

  /// FOL cancelled.
  Map<int, AssignToDetail?>? folCancelled;

  /// Requests returned to RO.
  Map<int, AssignToDetail?>? returnedToRO;

  /// Requests returned to CAM.
  Map<int, AssignToDetail?>? returnedToCAM;

  /// Requests returned to TLB.
  Map<int, AssignToDetail?>? returnedToTLB;

  /// Requests returned to SHB.
  Map<int, AssignToDetail?>? returnedToSHB;

  /// Requests returned to SH level B.
  Map<int, AssignToDetail?>? returnedToSHLvlB;

  /// Requests returned to RMB.
  Map<int, AssignToDetail?>? returnedToRMB;

  /// Requests returned to CCUM.
  Map<int, AssignToDetail?>? returnedToCCUM;

  /// Requests returned to DC.
  Map<int, AssignToDetail?>? returnedToDC;

  /// Requests returned to CCOOD.
  Map<int, AssignToDetail?>? returnedToCCOOD;

  /// Requests returned to documentation team.
  Map<int, AssignToDetail?>? returnedToDocumentation;

  /// Requests returned to pool.
  Map<int, AssignToDetail?>? returnedToPool;

  /// Requests returned to CA.
  Map<int, AssignToDetail?>? returnedToCA;

  /// Requests returned to TL-D1.
  Map<int, AssignToDetail?>? returnedToTLD1;

  /// Requests returned to SH-D.
  Map<int, AssignToDetail?>? returnedToSHD;

  /// Requests returned to SH-C.
  Map<int, AssignToDetail?>? returnedToSHC;

  /// Requests returned to SH-B (hyphenated key).
  Map<int, AssignToDetail?>? returnedToSHBHyphen;

  /// Requests returned to SH-B1.
  Map<int, AssignToDetail?>? returnedToSHB1;

  /// Requests returned to CCP.
  Map<int, AssignToDetail?>? returnedToCCP;

  /// Requests returned to CCPA.
  Map<int, AssignToDetail?>? returnedToCCPA;

  /// Requests returned to BDP.
  Map<int, AssignToDetail?>? returnedToBDP;

  /// Requests pending with relationship team.
  Map<int, AssignToDetail?>? pendingWithRelationShipTeam;

  /// Requests pending with business team group.
  Map<int, AssignToDetail?>? pendingWithBusinessTeam;

  /// Returns the first map that is non-null, non-empty, and has at least one
  /// key != -1.
  Map<int, AssignToDetail?>? firstValidMap() {
    for (final summaryMap in _allSummaries) {
      if (summaryMap != null &&
          summaryMap.isNotEmpty &&
          summaryMap.keys.any((int k) => k != -1)) {
        return summaryMap;
      }
    }
    return null;
  }

  /// Keep a single ordered list of all your map fields for easy iteration.
  List<Map<int, AssignToDetail?>?> get _allSummaries =>
      <Map<int, AssignToDetail?>?>[
        pendingWithMe,
        pendingWithFP,
        pendingWithBusiness,
        pendingWithCredit,
        pendingWithApprovingAuthority,
        pendingWithDocumentation,
        pendingWithCreditControl,
        pendingWithCreditControlCCSYS,
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

  /// Converts object to JSON.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    // existing
    data["pendingWithMe"] = pendingWithMe;
    data["pendingWithFP"] = pendingWithFP;
    data["pendingWithBusiness"] = pendingWithBusiness;
    data["pendingWithCredit"] = pendingWithCredit;
    data["pendingWithApprovingAuthority"] = pendingWithApprovingAuthority;
    data["pendingWithDocumentation"] = pendingWithDocumentation;
    data["pendingWithCreditControl"] = pendingWithCreditControl;
    data["pendingWithCreditControl-CCSYS"] = pendingWithCreditControlCCSYS;
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
