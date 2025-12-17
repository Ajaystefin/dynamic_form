import 'package:wcas_frontend/core/utils/utils.dart';

class DigitalEfilingState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus searchLoaderStatus = LoadingStatus.loaded;
  final String? groupName;
  final String? groupRim;
  final String? customerName;
  final String? customerRim;
  bool showSelectDialog;

  DigitalEfilingState(
      {required this.loaderStatus,
      required this.searchLoaderStatus,
      this.groupName,
      this.groupRim,
      this.customerName,
      this.customerRim,
      this.showSelectDialog = false});

  DigitalEfilingState copyWith(
      {LoadingStatus? loaderStatus,
      LoadingStatus? searchLoaderStatus,
      String? groupName,
      String? groupRim,
      String? customerName,
      String? customerRim,
      bool? showSelectDialog}) {
    return DigitalEfilingState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        searchLoaderStatus: searchLoaderStatus ?? this.searchLoaderStatus,
        groupName: groupName ?? this.groupName,
        groupRim: groupRim ?? this.groupRim,
        customerName: customerName ?? this.customerName,
        customerRim: customerRim ?? this.customerRim,
        showSelectDialog: showSelectDialog ?? false);
  }
}
