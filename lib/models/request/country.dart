class Country {
  int? id;
  String? code;
  String? description;

  Country({this.code, this.description});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['countryCode'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['countryCode'] = code;
    data['description'] = description;
    return data;
  }
}
