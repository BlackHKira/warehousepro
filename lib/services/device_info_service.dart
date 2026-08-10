import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await DeviceInfoPlugin().webBrowserInfo;
        return {
          'platform': 'Web',
          'browser': webInfo.userAgent ?? 'Unknown',
          'os': webInfo.platform ?? 'Unknown',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'osVersion': 'Android ${androidInfo.version.release}',
          'sdkInt': '${androidInfo.version.sdkInt}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.name,
          'osVersion': 'iOS ${iosInfo.systemVersion}',
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await DeviceInfoPlugin().windowsInfo;
        return {
          'platform': 'Windows',
          'model': windowsInfo.productName,
          'osVersion': 'Windows ${windowsInfo.displayVersion}',
        };
      } else if (Platform.isMacOS) {
        final macInfo = await DeviceInfoPlugin().macOsInfo;
        return {
          'platform': 'macOS',
          'model': macInfo.model,
          'osVersion': 'macOS ${macInfo.osRelease}',
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await DeviceInfoPlugin().linuxInfo;
        return {
          'platform': 'Linux',
          'model': linuxInfo.prettyName,
          'osVersion': linuxInfo.version ?? 'Unknown',
        };
      }
    } catch (_) {}
    return {'platform': 'Unknown', 'model': 'Unknown', 'osVersion': 'Unknown'};
  }
}
