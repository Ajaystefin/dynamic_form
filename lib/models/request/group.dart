class Group {
  String? id;
  String? name;
  int? groupOwner;

  Group({this.id, this.name, this.groupOwner});

  Group.fromJson(Map<String, dynamic> json) {
    id = json['GroupId'];
    name = json['GroupName'];
    groupOwner =int.tryParse( json['GroupOwner']??" ");
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['GroupId'] = id;
    data['GroupName'] = name;
    data['GroupOwner'] = groupOwner;
    return data;
  }
}
