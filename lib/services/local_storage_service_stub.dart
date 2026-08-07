import 'local_storage_service.dart';

class LocalStorageServiceStub implements LocalStorageService {
  final Map<String, String> _store = {};

  @override
  void saveRole(String role) {
    _store['user_role'] = role;
  }

  @override
  String? getRole() => _store['user_role'];

  @override
  void saveTabIndex(int index) {
    _store['tab_index'] = '$index';
  }

  @override
  int getTabIndex() => int.tryParse(_store['tab_index'] ?? '') ?? 0;

  @override
  void saveDarkMode(bool isDark) {
    _store['dark_mode'] = isDark.toString();
  }

  @override
  bool getDarkMode() {
    return _store['dark_mode'] == 'true';
  }

  @override
  void clearAll() => _store.clear();
}

LocalStorageService createInstance() => LocalStorageServiceStub();
