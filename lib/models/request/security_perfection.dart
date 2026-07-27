import "package:wcas_frontend/models/request/security_covenant_condition.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";

/// Represents security perfection details, including security
/// deferrals, covenant deferrals, and condition deferrals.
class SecurityPerfection {
  /// Creates a [SecurityPerfection] instance.
  SecurityPerfection({
    this.securityDeferralList,
    this.covenant,
    this.condition,
  });

  /// Creates a [SecurityPerfection] instance from a JSON map.
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
        covenant!.add(SecurityCovenantCondition.fromJson(v));
      });
    }
    if (json["conditionDeferralList"] != null) {
      condition = <SecurityCovenantCondition>[];
      json["conditionDeferralList"].forEach((v) {
        condition!.add(SecurityCovenantCondition.fromJson(v));
      });
    }
  }

  /// List of security deferral records.
  List<SecurityDeferral>? securityDeferralList;

  /// List of covenant deferral records.
  List<SecurityCovenantCondition>? covenant;

  /// List of condition deferral records.
  List<SecurityCovenantCondition>? condition;
}
