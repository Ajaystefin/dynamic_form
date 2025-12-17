import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_data.dart';

class FacilitiesOtherBanks {
  List<Facility>? facilitiesList;
  Customer? customer;

  FacilitiesOtherBanks({this.facilitiesList, this.customer});

  FacilitiesOtherBanks.fromJson(Map<String, dynamic> json) {
    if (json['facilitiesList'] != null) {
      facilitiesList = <Facility>[];
      json['facilitiesList'].forEach((v) {
        facilitiesList!.add(Facility.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (facilitiesList != null) {
      data['facilitiesList'] = facilitiesList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
