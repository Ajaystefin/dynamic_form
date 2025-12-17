import 'package:wcas_frontend/core/utils/utils.dart';

class SearchProjectState {
  final LoadingStatus loaderStatus;
  bool? showCustomerTypeField = false;
  bool? showDataTable = false;

  SearchProjectState({
    this.loaderStatus = LoadingStatus.loaded,
    this.showCustomerTypeField = false,
    this.showDataTable = false,
  });

  SearchProjectState copyWith(
      {LoadingStatus? loaderStatus,
      bool? showCustomerTypeField,
      bool? showDataTable}) {
    return SearchProjectState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        showCustomerTypeField:
            showCustomerTypeField ?? this.showCustomerTypeField,
        showDataTable: showDataTable ?? this.showDataTable);
  }
}
