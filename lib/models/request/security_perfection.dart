import 'package:wcas_frontend/models/request/security_covenant_condition.dart';
import 'package:wcas_frontend/models/request/security_deferral.dart';

class SecurityPerfection {
  List<SecurityDeferral>? securityDeferralList;
  List<SecurityCovenantCondition>? covenant;
  List<SecurityCovenantCondition>? condition;

  SecurityPerfection(
      {this.securityDeferralList, this.covenant, this.condition});

  SecurityPerfection.fromJson(Map<String, dynamic> json) {
    if (json['securityDeferralList'] != null) {
      securityDeferralList = <SecurityDeferral>[];
      json['securityDeferralList'].forEach((v) {
        securityDeferralList!.add(SecurityDeferral.fromJson(v));
      });
    }
    if (json['covenant'] != null) {
      covenant = <SecurityCovenantCondition>[];
      json['covenant'].forEach((v) {
        covenant!.add(SecurityCovenantCondition.fromJson(v));
      });
    }
    if (json['condition'] != null) {
      condition = <SecurityCovenantCondition>[];
      json['condition'].forEach((v) {
        condition!.add(SecurityCovenantCondition.fromJson(v));
      });
    }
  }
}
