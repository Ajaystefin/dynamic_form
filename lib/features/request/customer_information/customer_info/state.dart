import 'package:wcas_frontend/core/utils/utils.dart';

class CustomerInfoState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? userNameChangeLoader = LoadingStatus.loaded;
  bool? isPolicyDeviation;
  String? industrySicCode;
  String? industrySicCodeDesc;

  CustomerInfoState(
      {required this.loaderStatus,
      this.userNameChangeLoader,
      this.isPolicyDeviation = false,
      this.industrySicCode = '',
      this.industrySicCodeDesc = ''});

  CustomerInfoState copyWith(
      {LoadingStatus? loaderStatus,
      LoadingStatus? userNameChangeLoader,
      bool? isPolicyDeviation,
      String? industrySicCode,
      String? industrySicCodeDesc}) {
    return CustomerInfoState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        userNameChangeLoader: userNameChangeLoader ?? this.userNameChangeLoader,
        isPolicyDeviation: isPolicyDeviation ?? this.isPolicyDeviation,
        industrySicCode: industrySicCode ?? this.industrySicCode,
        industrySicCodeDesc: industrySicCodeDesc ?? this.industrySicCodeDesc);
  }
}
