import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";

class SecurityPerfection {
  SecurityPerfection({
    this.securityDeferralList,
    this.covenant,
    this.condition,
  });

  SecurityPerfection.fromJson(Map<String, dynamic> json) {
    if (json["securityDeferralList"] != null) {
      securityDeferralList = <SecurityDeferral>[];
      json["securityDeferralList"].forEach((v) {
        securityDeferralList!.add(SecurityDeferral.fromJson(v));
      });
    }
    if (json["covenantDeferralList"] != null) {
      covenant = <SecurityCovenantCondition>[];
      json["covenantDeferralList"].forEach((v) {
        covenant!.add(SecurityCovenantCondition.fromJson(v, isCovenant: true));
      });
    }
    if (json["conditionDeferralList"] != null) {
      condition = <SecurityCovenantCondition>[];
      json["conditionDeferralList"].forEach((v) {
        condition!
            .add(SecurityCovenantCondition.fromJson(v, isCovenant: false));
      });
    }
  }
  List<SecurityDeferral>? securityDeferralList;
  List<SecurityCovenantCondition>? covenant;
  List<SecurityCovenantCondition>? condition;
}
