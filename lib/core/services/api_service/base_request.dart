import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/globals.dart';

class BaseRequest {
  static Map<String, dynamic> baseRequest(
    dynamic data,
  ) {
    final Map<String, dynamic> request = {
      "baseRequest": {
        "roleID": Globals.user?.currentRole?.roleId,
        "role": Globals.user?.currentRole?.code,
        "bpmRole": Globals.user?.currentRole?.bpmRole,
        "channelID": "WCAS",
        "sessionID": Globals.sessionID,
        "userID": Globals.user?.id,
        "userName": Globals.user?.name,
        "rqUID": const Uuid().v4()
      }
    //   "baseRequest": {
    //     "roleID": 129,
    //     "role": "RMB",
    //     "bpmRole": "Business Regional Manager-WCAS",
    //     "channelID": "WCAS",
    //     "sessionID": "e5341f6a-1e8b-4beb-9745-8067295d780d",
    //     "userID": "WCASTSP01",
    //     "userName": "wcastsp01",
    //     "rqUID": "0bec213e-9926-415d-8733-c789f991f421"

    // },
    };

    if (data != null) {
      request["requestData"] = data;
    }

    return request;
  }
}
