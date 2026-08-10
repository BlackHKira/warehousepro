import 'dart:html' as html;
import 'local_storage_service.dart';

class LocalStorageServiceWeb implements LocalStorageService {
  @override
  void saveRole(String role) {
    html.window.localStorage['user_role'] = role;
  }

  @override
  String? getRole() {
    return html.window.localStorage['user_role'];
  }

  @override
  void saveTabIndex(int index) {
    html.window.localStorage['tab_index'] = '$index';
  }

  @override
  int getTabIndex() {
    return int.tryParse(html.window.localStorage['tab_index'] ?? '') ?? 0;
  }

  @override
  void saveDarkMode(bool isDark) {
    html.window.localStorage['dark_mode'] = isDark.toString();
  }

  @override
  bool getDarkMode() {
    return html.window.localStorage['dark_mode'] == 'true';
  }

  @override
  void clearAll() {
    html.window.localStorage.remove('user_role');
    html.window.localStorage.remove('tab_index');
  }
}

LocalStorageService createInstance() => LocalStorageServiceWeb();
