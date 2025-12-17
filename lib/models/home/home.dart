class Summary {
  int? pendingWithMe;
  int? pendingWithFP;
  int? pendingWithBusiness;
  int? pendingWithCredit;
  int? pendingWithApprovingAuthority;
  int? pendingWithDocumentation;
  int? pendingWithCreditControl;
  int? pendingWithSegment;
  int? requestEnabledByCA;
  int? requestEnabledByCCProxy;
  int? requestEnabledByBODProxy;
  int? recentApplications;
  int? applicationsOverdue;
  int? applicationsDueForReview;
  int? returnedToRM;
  int? pendingWithTheFPChecker;
  int? pendingWithPool;
  int? pendingWithTeam;
  int? assigningRequestToMaker;
  int? pendingWithCA;
  int? assignRequestToCA;
  int? requestToRecommended;
  int? assignRequestToMe;
  int? returnedRequestDocumentation;
  int? recommentedRequest;
  int? draftFolInitiated;
  int? draftFolGenerated;
  int? finalFolInitiated;
  int? finalFolGenerated;
  int? documentationSubmitted;
  int? documentationCompleted;
  int? folCancelled;
  int? returnedToRO;

  Summary(
      {this.pendingWithMe,
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
      this.returnedToRO});

  factory Summary.fromJson(List<dynamic> jsonList) {
    final Map<String, int> dataMap = {
      for (var item in jsonList) item['key']: item['count']
    };

    return Summary(
        pendingWithMe: dataMap['pendingWithMe'] ?? 0,
        pendingWithFP: dataMap['pendingWithFP'] ?? 0,
        pendingWithBusiness: dataMap['pendingWithBusiness'] ?? 0,
        pendingWithCredit: dataMap['pendingWithCredit'] ?? 0,
        pendingWithApprovingAuthority:
            dataMap['pendingWithApprovingAuthority'] ?? 0,
        pendingWithDocumentation: dataMap['pendingWithDocumentation'] ?? 0,
        pendingWithCreditControl: dataMap['pendingWithCreditControl'] ?? 0,
        pendingWithSegment: dataMap['pendingWithSegment'] ?? 0,
        requestEnabledByCA: dataMap['requestEnabledByCA'] ?? 0,
        requestEnabledByCCProxy: dataMap['requestEnabledByCCProxy'] ?? 0,
        requestEnabledByBODProxy: dataMap['requestEnabledByBODProxy'] ?? 0,
        recentApplications: dataMap['recentApplications'] ?? 0,
        applicationsOverdue: dataMap['applicationsOverdue'] ?? 0,
        applicationsDueForReview: dataMap['applicationsDueForReview'] ?? 0,
        returnedToRM: dataMap['returnedToRM'] ?? 0,
        pendingWithTheFPChecker: dataMap['pendingWithTheFPChecker'] ?? 0,
        pendingWithPool: dataMap['pendingWithPool'] ?? 0,
        pendingWithTeam: dataMap['pendingWithTeam'] ?? 0,
        assigningRequestToMaker: dataMap['assigningRequestToMaker'] ?? 0,
        pendingWithCA: dataMap['pendingWithCA'] ?? 0,
        assignRequestToCA: dataMap['assignRequestToCA'] ?? 0,
        requestToRecommended: dataMap['requestToRecommended'] ?? 0,
        assignRequestToMe: dataMap['assignRequestToMe'] ?? 0,
        returnedRequestDocumentation:
            dataMap['returnedRequestDocumentation'] ?? 0,
        recommentedRequest: dataMap['recommentedRequest'] ?? 0,
        draftFolInitiated: dataMap['draftFolInitiated'] ?? 0,
        draftFolGenerated: dataMap['draftFolGenerated'] ?? 0,
        finalFolInitiated: dataMap['finalFolInitiated'] ?? 0,
        finalFolGenerated: dataMap['finalFolGenerated'] ?? 0,
        documentationSubmitted: dataMap['documentationSubmitted'] ?? 0,
        documentationCompleted: dataMap['documentationCompleted'] ?? 0,
        folCancelled: dataMap['folCancelled'] ?? 0,
        returnedToRO: dataMap["returnedToRO"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pendingWithMe'] = pendingWithMe;
    data['pendingWithFP'] = pendingWithFP;
    data['pendingWithBusiness'] = pendingWithBusiness;
    data['pendingWithCredit'] = pendingWithCredit;
    data['pendingWithApprovingAuthority'] = pendingWithApprovingAuthority;
    data['pendingWithDocumentation'] = pendingWithDocumentation;
    data['pendingWithCreditControl'] = pendingWithCreditControl;
    data['pendingWithSegment'] = pendingWithSegment;
    data['requestEnabledByCA'] = requestEnabledByCA;
    data['requestEnabledByCCProxy'] = requestEnabledByCCProxy;
    data['requestEnabledByBODProxy'] = requestEnabledByBODProxy;
    data['recentApplications'] = recentApplications;
    data['applicationsOverdue'] = applicationsOverdue;
    data['applicationsDueForReview'] = applicationsDueForReview;
    data['returnedToRM'] = returnedToRM;
    data['pendingWithTheFPChecker'] = pendingWithTheFPChecker;
    data['pendingWithPool'] = pendingWithPool;
    data['pendingWithTeam'] = pendingWithTeam;
    data['assigningRequestToMaker'] = assigningRequestToMaker;
    data['pendingWithCA'] = pendingWithCA;
    data['assignRequestToCA'] = assignRequestToCA;
    data['requestToRecommended'] = requestToRecommended;
    data['assignRequestToMe'] = assignRequestToMe;
    data['returnedRequestDocumentation'] = returnedRequestDocumentation;
    data['recommentedRequest'] = recommentedRequest;
    data['draftFolInitiated'] = draftFolInitiated;
    data['draftFolGenerated'] = draftFolGenerated;
    data['finalFolInitiated'] = finalFolInitiated;
    data['finalFolGenerated'] = finalFolGenerated;
    data['documentationSubmitted'] = documentationSubmitted;
    data['documentationCompleted'] = documentationCompleted;
    data['folCancelled'] = folCancelled;
    data['returnedToRO'] = returnedToRO;

    return data;
  }
}
