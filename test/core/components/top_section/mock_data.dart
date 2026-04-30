import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/request.dart";

class MockTopSectionData {
  static Request createFullRequest() {
    return Request(
      applicationRefNo: "APP-001-2024",
      customerName: "Test Customer Ltd.",
      groupName: "Test Group Holdings",
      requestType: Reference(
        id: 1,
        name: "Credit Risk Assessment",
      ),
      businessSegment: Reference(
        id: 1,
        name: "Corporate Banking",
      ),
    );
  }

  static Request createRequestWithoutGroup() {
    return Request(
      applicationRefNo: "APP-002-2024",
      customerName: "Individual Customer",
      groupName: null,
      requestType: Reference(
        id: 2,
        name: "Loan Application",
      ),
      businessSegment: Reference(
        id: 2,
        name: "Retail Banking",
      ),
    );
  }

  static Request createRequestWithEmptyGroup() {
    return Request(
      applicationRefNo: "APP-003-2024",
      customerName: "Empty Group Customer",
      groupName: "",
      requestType: Reference(
        id: 3,
        name: "Investment Advisory",
      ),
      businessSegment: Reference(
        id: 3,
        name: "Investment Banking",
      ),
    );
  }

  static Request createRequestWithNullValues() {
    return Request(
      applicationRefNo: null,
      customerName: null,
      groupName: null,
      requestType: null,
      businessSegment: null,
    );
  }

  static Request createRequestWithEmptyValues() {
    return Request(
      applicationRefNo: "",
      customerName: "",
      groupName: "",
      requestType: Reference(
        id: 4,
        name: "",
      ),
      businessSegment: Reference(
        id: 4,
        name: "",
      ),
    );
  }
}
