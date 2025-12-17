import 'package:wcas_frontend/core/services/api_service/api_manager.dart';

class CcsysRepository {
  static final _singleton = CcsysRepository();
  static CcsysRepository get instance => _singleton;

  // ignore: unused_field
  final APIManager _apiManager;

  // Constructor for dependency injection (used in tests)
  CcsysRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager.instance;
}
