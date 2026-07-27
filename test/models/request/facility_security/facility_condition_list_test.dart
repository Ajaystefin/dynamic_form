import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/facility_condition_list.dart";

void main() {
  group("FacilityCondition", () {
    test("fromJson parses full payload including dates and booleans", () {
      final json = {
        "referenceDataListId": 12064,
        "name": "Project Standby Limit",
        "description": "NA",
        "reference1": "All",
        "reference2": "Main limit, Sub limit",
        "reference3": "Allocations under Project Standby Limits will be"
            " allowed subject to conditions",
        "reference4": null,
        "reference5": null,
        "isActive": true,
        "createdBy": "SYSTEM",
        "createdDate": "2025-09-22T20:00:00.000+00:00",
        "updatedBy": "SYSTEM",
        "updatedDate": "2025-09-22T20:00:00.000+00:00",
      };

      final model = FacilityCondition.fromJson(json);

      expect(model.referenceDataListId, 12064);
      expect(model.name, "Project Standby Limit");
      expect(model.description, "NA");
      expect(model.reference1, "All");
      expect(model.reference2, "Main limit, Sub limit");
      expect(
        model.reference3,
        startsWith("Allocations under Project Standby Limits"),
      );
      expect(model.reference4, isNull);
      expect(model.reference5, isNull);
      expect(model.isActive, isTrue);
      expect(model.createdBy, "SYSTEM");
      expect(model.updatedBy, "SYSTEM");

      // Dates should parse
      expect(model.createdDate, isA<DateTime>());
      expect(model.updatedDate, isA<DateTime>());
    });

    test("fromJson handles null and empty date strings", () {
      final json = {
        "referenceDataListId": 1,
        "createdDate": null, // null branch
        "updatedDate": "", // empty branch
      };

      final model = FacilityCondition.fromJson(json);

      expect(model.createdDate, isNull);
      expect(model.updatedDate, isNull);
    });

    test("toJson serializes all fields and formats DateTime as ISO-8601", () {
      final dt = DateTime.utc(2025, 9, 22, 20);
      final model = FacilityCondition(
        referenceDataListId: 7,
        name: "X",
        description: "Y",
        reference1: "R1",
        reference2: "R2",
        reference3: "R3",
        reference4: "R4",
        reference5: "R5",
        isActive: true,
        createdBy: "SYSTEM",
        createdDate: dt,
        updatedBy: "SYSTEM",
        updatedDate: dt,
      );

      final map = model.toJson();

      expect(map["referenceDataListId"], 7);
      expect(map["name"], "X");
      expect(map["description"], "Y");
      expect(map["reference1"], "R1");
      expect(map["reference2"], "R2");
      expect(map["reference3"], "R3");
      expect(map["reference4"], "R4");
      expect(map["reference5"], "R5");
      expect(map["isActive"], true);
      expect(map["createdBy"], "SYSTEM");
      expect(map["updatedBy"], "SYSTEM");

      // ISO-8601 output (we compare against the source DateTime's ISO string)
      expect(map["createdDate"], dt.toIso8601String());
      expect(map["updatedDate"], dt.toIso8601String());
    });

    test("toJson preserves nulls and includes keys", () {
      const model = FacilityCondition();

      final map = model.toJson();

      expect(map.containsKey("reference3"), isTrue);
      expect(map["reference3"], isNull);
      expect(map.containsKey("createdDate"), isTrue);
      expect(map["createdDate"], isNull);
      expect(map.containsKey("updatedDate"), isTrue);
      expect(map["updatedDate"], isNull);
    });
  });

  group("FacilityConditionsFilter", () {
    test("toJson returns exact key-value mapping", () {
      const filter = FacilityConditionsFilter(
        condition: "CONTRACTING-STANDARD_CONDITIONS",
        limitGroup: "Project Standby Limit",
        limitDesc: "NA",
        limitCode: "All",
        limitType: "Main limit",
      );

      final map = filter.toJson();

      expect(
        map,
        {
          "condition": "CONTRACTING-STANDARD_CONDITIONS",
          "limitGroup": "Project Standby Limit",
          "limitDesc": "NA",
          "limitCode": "All",
          "limitType": "Main limit",
        },
      );
    });
  });
}
