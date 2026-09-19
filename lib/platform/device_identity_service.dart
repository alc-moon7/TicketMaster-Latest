import 'package:flutter/services.dart';

class TicketmasterDeviceInfo {
  const TicketmasterDeviceInfo({
    required this.deviceKey,
    required this.deviceLabel,
    required this.storageDirectoryPath,
  });

  final String deviceKey;
  final String deviceLabel;
  final String storageDirectoryPath;
}

class TicketmasterDeviceIdentity {
  TicketmasterDeviceIdentity._();

  static const MethodChannel _channel = MethodChannel(
    'ticketmaster/device_identity',
  );

  static Future<TicketmasterDeviceInfo> current() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getDeviceIdentity',
      );
      final deviceKey = result?['deviceKey'] as String?;
      final deviceLabel = result?['deviceLabel'] as String?;
      final storageDirectoryPath = result?['storageDirectoryPath'] as String?;
      if (deviceKey != null && deviceKey.isNotEmpty) {
        return TicketmasterDeviceInfo(
          deviceKey: deviceKey,
          deviceLabel: (deviceLabel?.trim().isNotEmpty ?? false)
              ? deviceLabel!.trim()
              : 'This device',
          storageDirectoryPath: storageDirectoryPath?.trim() ?? '',
        );
      }
    } on MissingPluginException {
      // Unsupported platforms fall back to a generic label.
    } catch (_) {
      // Ignore transient platform-channel failures and use a safe fallback.
    }

    return const TicketmasterDeviceInfo(
      deviceKey: 'fallback-device',
      deviceLabel: 'This device',
      storageDirectoryPath: '',
    );
  }
}
