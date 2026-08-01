import 'local_storage_service_stub.dart'
    if (dart.library.js_interop) 'local_storage_service_web.dart';

abstract class LocalStorageService {
  static final LocalStorageService _instance = createInstance();
  factory LocalStorageService() => _instance;

  void saveRole(String role);
  String? getRole();
  void saveTabIndex(int index);
  int getTabIndex();
  void clearAll();
}
