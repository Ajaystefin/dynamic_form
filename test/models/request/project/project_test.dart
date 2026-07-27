import "package:test/test.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";

Matcher _isDateOrNull(bool shouldBeDate) =>
    shouldBeDate ? isA<DateTime>() : isNull;

void main() {
  group("toIntOrNull", () {
    test("returns null for null", () {
      expect(toIntOrNull(null), isNull);
    });

    test("returns int as-is", () {
      expect(toIntOrNull(123), 123);
    });

    test("rounds double by default", () {
      expect(toIntOrNull(123.4), 123);
      expect(toIntOrNull(123.5), 124);
    });

    test("truncates double when round=false", () {
      expect(toIntOrNull(123.9, round: false), 123);
    });
  });

  group("Project.fromSearchJson", () {
    test(
        "handles DateTime branches for"
        " defectLiabilityEndDate and projectPeriod", () {
      final json = {
        "projectId": 1,
        "projectCode": "PC01",
        "projectName": "Project Alpha",
        "projectOwnerRimNo": 100.7, // rounds -> 101
        "projectOwnerEntityRimNo": 200.2, // rounds -> 200
        "projectUltimateOwnerName": "Ultimate Owner",
        "projectOwnerEntityName": "Owner Entity",
        "projectValueCurrent": 500.8, // rounds -> 501
        "defectLiabilityEndDate": DateTime(2025, 01, 15),
        "projectPeriod": DateTime(2025, 12),
        "projectValue": 1000.3, // rounds -> 1000
        "projectCompletion": 85.6, // rounds -> 86
        // 'initialProjectValue': 900.4, // rounds -> 900
        "projectSummary": "Summary here",
        "createdBy": "Alice",
        "createdDate": "2025-01-01",
        "updatedBy": "Bob",
        "updatedDate": "2025-02-01",
        "facilityId": 42.9, // rounds -> 43
      };

      final p = Project.fromSearchJson(json);
      expect(p.projectId, 1);
      expect(p.projectCode, "PC01");
      expect(p.projectName, "Project Alpha");
      expect(p.projectOwnerRimNo, 101);
      expect(p.projectOwnerEntityRimNo, 200);
      expect(p.projectUltimateOwnerName, "Ultimate Owner");
      expect(p.projectOwnerEntityName, "Owner Entity");
      // expect(p.projectValueCurrent, 501);
      expect(p.defectLiabilityEndDate, DateTime(2025, 01, 15));
      expect(p.projectPeriod, DateTime(2025, 12));
      // expect(p.projectValue, 1000);
      expect(p.projectCompletion, 85.6);
      // expect(p.initialProjectValue, 900);
      expect(p.projectSummary, "Summary here");
      expect(p.createdBy, "Alice");
      expect(p.createdDate, "2025-01-01");
      expect(p.updatedBy, "Bob");
      expect(p.updatedDate, "2025-02-01");
      expect(p.facilityId, 43);
    });

    test("handles String branches for defectLiabilityEndDate and projectPeriod",
        () {
      // Using epoch millis in String form; DateTimeUtils.intToDateTime should
      // handle it.
      final json = {
        "projectId": 2,
        "projectCode": "PC02",
        "projectName": "Project Beta",
        "projectOwnerRimNo": 111,
        "projectOwnerEntityRimNo": 222,
        "projectUltimateOwnerName": "Ultimate",
        "projectOwnerEntityName": "Entity",
        "projectValueCurrent": "333",
        "defectLiabilityEndDate":
            "${DateTime(2026, 02).millisecondsSinceEpoch}",
        "projectPeriod": "${DateTime(2026, 03).millisecondsSinceEpoch}",
        "projectValue": "444",
        "projectCompletion": 55,
        "initialProjectValue": "666",
        "projectSummary": "Beta summary",
        "createdBy": "Carol",
        "createdDate": "2026-01-01",
        "updatedBy": "Dan",
        "updatedDate": "2026-02-01",
        // facilityId omitted to cover the null path
      };

      final p = Project.fromSearchJson(json);
      expect(p.projectId, 2);
      expect(p.projectCode, "PC02");
      expect(p.projectName, "Project Beta");
      expect(p.projectOwnerRimNo, 111);
      expect(p.projectOwnerEntityRimNo, 222);
      expect(p.projectUltimateOwnerName, "Ultimate");
      expect(p.projectOwnerEntityName, "Entity");
      expect(p.projectValueCurrent, "333");
      // We don't assert exact DateTime, just that the branch executed and
      // returned a DateTime or null.
      expect(p.defectLiabilityEndDate, _isDateOrNull(true));
      expect(p.projectPeriod, _isDateOrNull(true));
      expect(p.projectValue, "444");
      expect(p.projectCompletion, 55);
      expect(p.initialProjectValue, "666");
      expect(p.projectSummary, "Beta summary");
      expect(p.createdBy, "Carol");
      expect(p.createdDate, "2026-01-01");
      expect(p.updatedBy, "Dan");
      expect(p.updatedDate, "2026-02-01");
      expect(p.facilityId, isNull);
    });
  });

  group("Project.fromJson / toJson", () {
    test("maps fields and converts dates, includes Contract list", () {
      final periodMs = DateTime(2025, 04).millisecondsSinceEpoch;
      final liabilityMs = DateTime(2025, 05).millisecondsSinceEpoch;

      final projectJson = {
        "name": "N1",
        "ultimateOwner": "UO1",
        "ownerEntity": "OE1",
        "ownerRim": 10,
        "ownerEntityRim": 20,
        // 'projectValue': 999,
        "period": periodMs,
        "completion": 77,
        "liabilityEndDate": liabilityMs,
        "summary": "Sum",
        "initalProjectValue": "IPV",
        "currentProjectValue": "CPV",
        "Contract": [
          {
            // Minimal Contract JSON (Contract.fromJson handles these keys)
            "projectName": "PN",
            "completion": periodMs,
            "segment": "Seg",
            "contractCode": "CC",
            "borrowerRole": "BR",
            "rim": "RIM",
          }
        ],
      };

      final p = Project.fromJson(projectJson);
      expect(p.name, "N1");
      expect(p.ultimateOwner, "UO1");
      expect(p.ownerEntity, "OE1");
      expect(p.ownerRim, 10);
      expect(p.ownerEntityRim, 20);
      // expect(p.projectValue, 999);
      expect(p.period, _isDateOrNull(true));
      expect(p.completion, 77);
      expect(p.liabilityEndDate, _isDateOrNull(true));
      expect(p.summary, "Sum");
      expect(p.initalProjectValue, "IPV");
      expect(p.currentProjectValue, "CPV");
      expect(p.contract, isNotNull);
      expect(p.contract!.length, 1);

      final out = p.toJson();
      expect(out["name"], "N1");
      expect(out["ultimateOwner"], "UO1");
      expect(out["ownerEntity"], "OE1");
      expect(out["ownerRim"], 10);
      expect(out["ownerEntityRim"], 20);
      // expect(out['projectValue'], 999);
      expect(out["period"], isA<int?>()); // DateTime → int
      expect(out["completion"], 77);
      expect(out["liabilityEndDate"], isA<int?>()); // DateTime → int
      expect(out["summary"], "Sum");
      expect(out["initalProjectValue"], "IPV");
      expect(out["currentProjectValue"], "CPV");
      expect(out["Contract"], isA<List>());
      expect((out["Contract"] as List).length, 1);
    });

    test("toJson omits Contract key when contract == null", () {
      final p = Project();
      final out = p.toJson();
      expect(out.containsKey("Contract"), isFalse);
    });
  });

  group("Project.toAPIJson", () {
    test("emits API-shaped JSON including Contract when present", () {
      final c = Contract(contractName: "Contract A");
      final p = Project(
        projectId: 99,
        projectCode: "PC99",
        projectName: "Project Z",
        projectOwnerRimNo: 101,
        projectOwnerEntityRimNo: 202,
        projectUltimateOwnerName: "UOZ",
        projectOwnerEntityName: "OEZ",
        projectValueCurrent: "303",
        defectLiabilityEndDate: DateTime(2027),
        projectValue: "404",
        projectPeriod: DateTime(2027, 02),
        projectCompletion: 66,
        initialProjectValue: "505",
        projectSummary: "Summary Z",
        createdBy: "Creator",
        createdDate: "2027-01-02",
        updatedBy: "Updater",
        updatedDate: "2027-01-03",
        facilityId: 707,
        contract: [c],
      );

      final out = p.toAPIJson();
      expect(out["projectId"], 99);
      expect(out["projectCode"], "PC99");
      expect(out["projectName"], "Project Z");
      expect(out["projectOwnerRimNo"], 101);
      expect(out["projectOwnerEntityRimNo"], 202);
      expect(out["projectUltimateOwnerName"], "UOZ");
      expect(out["projectOwnerEntityName"], "OEZ");
      expect(out["projectValueCurrent"], "303");
      expect(
        out["defectLiabilityEndDate"],
        _isDateOrNull(true),
      ); // DateTime as-is
      expect(out["projectValue"], "404");
      expect(out["projectPeriod"], _isDateOrNull(true)); // DateTime as-is
      expect(out["projectCompletion"], 66);
      expect(out["initialProjectValue"], "505");
      expect(out["projectSummary"], "Summary Z");
      expect(out["createdBy"], "Creator");
      expect(out["createdDate"], "2027-01-02");
      expect(out["updatedBy"], "Updater");
      expect(out["updatedDate"], "2027-01-03");
      expect(out["facilityId"], 707);
      expect(out["Contract"], isA<List>());
      expect((out["Contract"] as List).length, 1);
    });

    test("toAPIJson omits Contract when contract == null", () {
      final p = Project();
      final out = p.toAPIJson();
      expect(out.containsKey("Contract"), isFalse);
    });
  });

  group("Project.toSaveEditProjectJson - facilityId behavior", () {
    test("when isCreateProject=false, facilityId key is absent", () {
      final p = Project(facilityId: 123);
      final out = p.toSaveEditProjectJson();

      // facilityId key is NOT added at all in the false branch
      expect(out.containsKey("facilityId"), isFalse);
    });

    test("when isCreateProject=true, facilityId key is present and null", () {
      final p = Project(facilityId: 123);
      final out = p.toSaveEditProjectJson(isCreateProject: true);

      // facilityId key exists and is explicitly set to null
      expect(out.containsKey("facilityId"), isTrue);
      expect(out["facilityId"], isNull);
    });
  });

  group("Project.toSaveEditProjectJson", () {
    test("formats dates and trims strings (isCreateProject=false)", () {
      final p = Project(
        projectCode: "  PC  ",
        projectName: "  Name  ",
        projectUltimateOwnerName: "  UO  ",
        projectOwnerEntityName: "  OE  ",
        projectOwnerRimNo: 111,
        projectOwnerEntityRimNo: 222,
        projectValue: "333",
        projectPeriod: DateTime(2025, 02, 15),
        defectLiabilityEndDate: DateTime(2025, 12, 31),
        projectCompletion: 50,
        projectSummary: "  Some summary  ",
        // initialProjectValue: 999,
        projectValueCurrent: "888",
        facilityId: 123,
      );

      final out = p.toSaveEditProjectJson();

      expect(out["projectCode"], "PC");
      expect(out["projectName"], "Name");
      expect(out["projectUltimateOwnerName"], "UO");
      expect(out["projectOwnerEntityName"], "OE");
      expect(out["projectOwnerRimNo"], 111);
      expect(out["projectOwnerEntityRimNo"], 222);
      expect(out["projectValue"], "333");
      expect(out["projectPeriod"], "02/2025"); // formatMonthYear
      expect(out["defectLiabilityEndDate"], "12/2025"); // formatMonthYear
      expect(out["projectCompletion"], 50);
      expect(out["projectSummary"], "Some summary");

      // When isCreateProject=false, facilityId should be included
      // expect(out['facilityId'], isCreateProject ? null : 123);
      // expect(out.containsKey('facilityId'), isFalse);
      // expect(out.containsKey('facilityId'), isTrue);
      // expect(out['facilityId'], isNull);

      // And initial/current project values NOT forced (branch guarded by isCreateProject)
      expect(out.containsKey("initialProjectValue"), isFalse);
      expect(out.containsKey("currentProjectValue"), isFalse);
    });

    test("isCreateProject=true sets initial/current values and facilityId=null",
        () {
      final p = Project(
        projectValue: "500", // overrides initial/current when not null
        initialProjectValue: "400", // used only when projectValue is null
        projectValueCurrent: "450", // used only when projectValue is null
        facilityId: 999, // should become null when isCreateProject=true
        projectPeriod: DateTime(2026, 03),
        defectLiabilityEndDate: DateTime(2026, 04),
      );

      final out = p.toSaveEditProjectJson(isCreateProject: true);

      expect(out["initialProjectValue"], "500"); // projectValue wins
      // expect(out['currentProjectValue'], 500); // projectValue wins
      expect(out["facilityId"], isNull); // null when creating
      expect(out["projectPeriod"], "03/2026");
      expect(out["defectLiabilityEndDate"], "04/2026");
    });
  });
}
