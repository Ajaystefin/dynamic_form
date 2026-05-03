import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

//This is a temporary file for QA purpose
class ScreenIndex extends StatefulWidget {
  const ScreenIndex({super.key});

  @override
  State<ScreenIndex> createState() => _ScreenIndexState();
}

class _ScreenIndexState extends State<ScreenIndex> {
  late TextEditingController _appRefNoController;
  late TextEditingController _groupIdController;
  ApplicationType? _selectedApplicationType;
  RequestType? _selectedRequestType;
  BusinessSegment? _selectedBusinessSegment;
  RequestStatus? _selectedRequestStatus;
  bool _isGroupIdEnabled = false;

  @override
  void initState() {
    super.initState();
    _appRefNoController = TextEditingController(
      text: Globals.request?.applicationRefNo ?? "",
    );
    _groupIdController = TextEditingController(
      text: Globals.request?.groupId?.toString() ?? "",
    );
    _initializeDropdownValues();
  }

  void _initializeDropdownValues() {
    // Initialize ApplicationType from Globals.request
    if (Globals.request?.applicationType?.id != null) {
      _selectedApplicationType = ServerConstants.applicationTypeId.entries
          .firstWhere(
            (entry) => entry.value == Globals.request!.applicationType!.id,
            orElse: () => const MapEntry(ApplicationType.newToBank, -1),
          )
          .key;
    }

    // Initialize RequestType from Globals.request
    if (Globals.request?.requestType?.id != null) {
      _selectedRequestType = ServerConstants.requestTypeId.entries
          .firstWhere(
            (entry) => entry.value == Globals.request!.requestType!.id,
            orElse: () => const MapEntry(RequestType.fullCA, -1),
          )
          .key;
    }

    // Initialize BusinessSegment from Globals.request
    if (Globals.request?.businessSegment?.id != null) {
      _selectedBusinessSegment = ServerConstants.businessSegmentId.entries
          .firstWhere(
            (entry) => entry.value == Globals.request!.businessSegment!.id,
            orElse: () => const MapEntry(BusinessSegment.corporate, -1),
          )
          .key;
    }
  }

  @override
  void dispose() {
    _appRefNoController.dispose();
    _groupIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body(context));
  }

  void _onSubmit() {
    if (Globals.request != null) {
      // Update App Ref No.
      Globals.request!.applicationRefNo = _appRefNoController.text;

      // Update Application Type
      if (_selectedApplicationType != null) {
        final appTypeId =
            ServerConstants.applicationTypeId[_selectedApplicationType];
        Globals.request!.applicationType = Reference(
          id: appTypeId,
          name: _getApplicationTypeName(_selectedApplicationType!),
        );
      }

      // Update Request Type
      if (_selectedRequestType != null) {
        final requestTypeId =
            ServerConstants.requestTypeId[_selectedRequestType];
        Globals.request!.requestType = Reference(
          id: requestTypeId,
          name: _getRequestTypeName(_selectedRequestType!),
        );
      }

      // Update Business Segment
      if (_selectedBusinessSegment != null) {
        final businessSegmentId =
            ServerConstants.businessSegmentId[_selectedBusinessSegment];
        Globals.request!.businessSegment = Reference(
          id: businessSegmentId,
          name: _getBusinessSegmentName(_selectedBusinessSegment!),
        );
      }

      // Update Request Status
      if (_selectedRequestStatus != null) {
        final requestStatusID =
            ServerConstants.requestStatusId[_selectedRequestStatus];
        Globals.request!.requestStatus = Reference(
          id: requestStatusID,
          name: _getRequestStatusName(_selectedRequestStatus!),
        );
      }

      // Update Group ID if checkbox is enabled
      if (_isGroupIdEnabled && _groupIdController.text.isNotEmpty) {
        Globals.request!.groupId = int.tryParse(_groupIdController.text);
      }

      // Show comprehensive success message
      final List<String> updates = ["App Ref No.: ${_appRefNoController.text}"];
      if (_selectedApplicationType != null) {
        updates.add(
          "Application Type: "
          "${_getApplicationTypeName(_selectedApplicationType!)}",
        );
      }
      if (_selectedRequestType != null) {
        updates
            .add("Request Type: ${_getRequestTypeName(_selectedRequestType!)}");
      }
      if (_selectedBusinessSegment != null) {
        updates.add(
          "Business Segment: "
          "${_getBusinessSegmentName(_selectedBusinessSegment!)}",
        );
      }
      if (_selectedRequestStatus != null) {
        updates.add(
          "Request Status: ${_getRequestStatusName(_selectedRequestStatus!)}",
        );
      }
      if (_isGroupIdEnabled && _groupIdController.text.isNotEmpty) {
        updates.add("Group ID: ${_groupIdController.text}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated:\n${updates.join('\n')}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Ref No. input and Submit button
            Row(
              children: [
                SizedBox(
                  width: 400.w,
                  child: CustomTextField(
                    controller: _appRefNoController,
                    labelText: "App Ref No.",
                    hintText: "Enter application reference number",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Group ID checkbox and textbox
            Row(
              children: [
                CustomCheckbox(
                  width: 200,
                  value: _isGroupIdEnabled,
                  onChange: (bool? value) {
                    setState(() {
                      _isGroupIdEnabled = value ?? false;
                    });
                  },
                  child: const Text("Enable Group ID"),
                ),
                if (_isGroupIdEnabled) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: CustomTextField(
                          controller: _groupIdController,
                          labelText: "Group ID",
                          hintText: "Enter group ID",
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),
            // Dropdowns row
            Row(
              children: [
                // Application Type Dropdown
                SizedBox(
                  width: 180,
                  child: CustomDropdown<ApplicationType>(
                    // hintText: "Application Type",
                    items: ApplicationType.values,
                    selectedItems: _selectedApplicationType != null
                        ? [_selectedApplicationType]
                        : null,
                    dropdownBuilder: (context, selectedItem) {
                      return Text(
                        selectedItem != null
                            ? _getApplicationTypeName(selectedItem)
                            : "Application Type",
                      );
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text(_getApplicationTypeName(item)),
                        selected: isSelected,
                      );
                    },
                    onSelected: (selectedValues) {
                      setState(() {
                        _selectedApplicationType = selectedValues.isNotEmpty
                            ? selectedValues.first
                            : null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Request Type Dropdown
                SizedBox(
                  width: 180,
                  child: CustomDropdown<RequestType>(
                    // hintText: "Request Type",
                    items: RequestType.values,
                    selectedItems: _selectedRequestType != null
                        ? [_selectedRequestType]
                        : null,
                    dropdownBuilder: (context, selectedItem) {
                      return Text(
                        selectedItem != null
                            ? _getRequestTypeName(selectedItem)
                            : "Request Type",
                      );
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text(_getRequestTypeName(item)),
                        selected: isSelected,
                      );
                    },
                    onSelected: (selectedValues) {
                      setState(() {
                        _selectedRequestType = selectedValues.isNotEmpty
                            ? selectedValues.first
                            : null;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                // Business Segment Dropdown
                SizedBox(
                  width: 180.w,
                  child: CustomDropdown<BusinessSegment>(
                    hintText: "Business Segment",
                    items: BusinessSegment.values,
                    selectedItems: _selectedBusinessSegment != null
                        ? [_selectedBusinessSegment]
                        : null,
                    dropdownBuilder: (context, selectedItem) {
                      return Text(
                        selectedItem != null
                            ? _getBusinessSegmentName(selectedItem)
                            : "Business Segment",
                      );
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text(_getBusinessSegmentName(item)),
                        selected: isSelected,
                      );
                    },
                    onSelected: (selectedValues) {
                      setState(() {
                        _selectedBusinessSegment = selectedValues.isNotEmpty
                            ? selectedValues.first
                            : null;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                // Request Status Dropdown
                SizedBox(
                  width: 180.w,
                  child: CustomDropdown<RequestStatus>(
                    hintText: "Request Status",
                    items: RequestStatus.values,
                    selectedItems: _selectedRequestStatus != null
                        ? [_selectedRequestStatus]
                        : null,
                    dropdownBuilder: (context, selectedItem) {
                      return Text(
                        selectedItem != null
                            ? _getRequestStatusName(selectedItem)
                            : "Request Status",
                      );
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return ListTile(
                        title: Text(_getRequestStatusName(item)),
                        selected: isSelected,
                      );
                    },
                    onSelected: (selectedValues) {
                      setState(() {
                        _selectedRequestStatus = selectedValues.isNotEmpty
                            ? selectedValues.first
                            : null;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                CustomButton(
                  label: "Apply",
                  onPressed: _onSubmit,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400.w,
              child: CustomRawTable(
                rowHeight: 40.w,
                columns: _getColumns(),
                rows: _getRows(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to convert enums to display names
  String _getApplicationTypeName(ApplicationType type) {
    switch (type) {
      case ApplicationType.newToBank:
        return "New to Bank";
      case ApplicationType.annualReview:
        return "Annual Review";
      case ApplicationType.interimAmendment:
        return "Interim Amendment";
      case ApplicationType.reconsideration:
        return "Reconsideration";
      case ApplicationType.markForward:
        return "Mark Forward";
      case ApplicationType.riskRatingChange:
        return "Risk Rating Change";
      case ApplicationType.documentationDeferral:
        return "Documentation Deferral";
      case ApplicationType.cancellation:
        return "Cancellation";
      case ApplicationType.oneOffLimit:
        return "One-Off Limit";
      case ApplicationType.isolatedExcessType:
        return "Isolated Excess Type";
      case ApplicationType.isolatedProjectAllocation:
        return "Isolated Project Allocation";
      case ApplicationType.isolatedOther:
        return "Isolated Other";
      case ApplicationType.isolatedAllocation:
        return "Isolated Allocation";
    }
  }

  String _getRequestTypeName(RequestType type) {
    switch (type) {
      case RequestType.fullCA:
        return "Full CA";
      case RequestType.isolated:
        return "Isolated";
    }
  }

  String _getBusinessSegmentName(BusinessSegment segment) {
    switch (segment) {
      case BusinessSegment.corporate:
        return "Corporate";
      case BusinessSegment.financialInstitution:
        return "Financial Institution";
      case BusinessSegment.financialInstitutionCF:
        return "Financial Institution CF";
      case BusinessSegment.business:
        return "Business";
      case BusinessSegment.baf:
        return "BAF";
      case BusinessSegment.personal:
        return "Personal";
      case BusinessSegment.na:
        return "N/A";
    }
  }

  String _getRequestStatusName(RequestStatus status) {
    switch (status) {
      case RequestStatus.initiated:
        return "Initiated";

      case RequestStatus.pendingForApproval:
        return "Pending For Approval";
      case RequestStatus.approved:
        return "Approved";
      case RequestStatus.declined:
        return "Declined";
      case RequestStatus.requestWithdrawnCancelled:
        return "Request Withdrawn/Cancelled";
      case RequestStatus.pendingFolIssuance:
        return "Pending FOL Issuance";
      case RequestStatus.terminated:
        return "Terminated";
      case RequestStatus.completed:
        return "Completed";
      default:
        return "";
    }
  }

  List<TableColumn> _getColumns() {
    return [
      const TableColumn(
        label: Text("Screen Name"),
      ),
      const TableColumn(
        label: Text("Action"),
      ),
    ];
  }

  List<List<Widget>> _getRows(BuildContext context) {
    final routeMap = _getRouteMap();

    return routeMap.entries.map((entry) {
      return [
        Text(entry.key),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: CustomButton(
              label: "View",
              onPressed: () => context.go(entry.value),
            ),
          ),
        ),
      ];
    }).toList();
  }

  Map<String, String> _getRouteMap() {
    return {
      "RM Certification": Routes.rmCertification,
      "Documentation Certification": Routes.documentationCertification,
      "Limit Input Certification": Routes.limitInputCertification,
      "Admin Role Right": Routes.adminRoleRight,
      "File Access": Routes.fileAccess,
      "Reference Management": Routes.manageReference,
      "User List": Routes.userList,
      "ESG Certification": Routes.esgCertification,
      "Remarks Tabs": Routes.remarksCommonTabs,
      "Fee Structure": Routes.feeStructure,
      "Customer Information": Routes.customerInformation,
      "SIC Code Review": Routes.sicCodeReview,
      "Conditions Summary": Routes.conditionsSummary,
      "Covenants Summary": Routes.covenantsSummary,
      "Home": Routes.home,
      "Advanced Search": Routes.advancedSearch,
      "Closed Request": Routes.closedRequest,
      "Create Request": Routes.requestCreate,
      "Application Borrowers": Routes.applicationBorrowers,
      "Group Borrowers": Routes.groupBorrowers,
      "Request Information": Routes.requestInformation,
      "Present Request": Routes.presentRequest,
      "Security Perfection": Routes.securityPerfection,
      "Terminate Withdraw": Routes.terminateWithdraw,
      "Facilities with CBD": Routes.facilitiesWithCbd,
      "Facilities with Other Banks": Routes.facilitiesWithOtherBanks,
      "Risk Rating": Routes.riskRating,
      "Security Summary View": Routes.securitySummaryView,
      "Create Security": Routes.createSecurity,
      "Facility Security Linkage": Routes.facilitySecurityLinkage,
      "Create Facility": Routes.createFacility,
      "Facility Summary View": Routes.facilitySummaryView,
      "Account Stats": Routes.accountStats,
      "Business Volume": Routes.businessVolume,
      "Account Conduct": Routes.accountConduct,
      "Strategies and Comments": Routes.strategiesAndComments,
      "Income Summary": Routes.incomeSummary,
      "Relationship Profitability Detailed":
          Routes.relationshipProfitabilityDetailed,
      "Relationship Utilization": Routes.relationshipUtilization,
      "Relationship Profitability Summary":
          Routes.relationshipProfitabilitySummary,
      "Share of Wallet View": Routes.shareOfWalletView,
      "Comments": Routes.comments,
      "Group Summary": Routes.groupSummary,
      "Digital E-Filing": Routes.digitalEFiling,
      "File Attachment": Routes.fileAttachment,
      "Search Project": Routes.searchProject,
      "Edit View Project": Routes.editViewProject,
      "Create Project": Routes.createProject,
      "CCSYS - Create Request": Routes.ccsysCreateRequest,
      "CCSYS - Request Information": Routes.ccsysRequestInformation,
      "CCSYS - Customer Information": Routes.ccsysCustomerInformation,
      "CCSYS - Approval": Routes.ccsysApproval,
    };
  }
}
