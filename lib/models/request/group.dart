/// Represents a group with an identifier, name, and owner.
class Group {
  /// Creates a [Group] instance with optional fields.
  const Group({this.id, this.name, this.groupOwner});

  /// Creates a [Group] instance from a JSON map.
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["GroupId"],
      name: json["GroupName"],
      groupOwner: int.tryParse(json["GroupOwner"]?.toString() ?? ""),
    );
  }

  /// Unique identifier of the group.
  final String? id;

  /// Name of the group.
  final String? name;

  /// Identifier of the group owner.
  final int? groupOwner;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["GroupId"] = id;
    data["GroupName"] = name;
    data["GroupOwner"] = groupOwner;
    return data;
  }
}
