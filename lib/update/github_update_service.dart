import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _latestReleaseUrl =
    'https://api.github.com/repos/alc-moon7/TicketMaster-Latest/releases/latest';
const _appUpdateChannel = MethodChannel('ticketmaster/app_update');

bool _updateCheckStarted = false;

Future<void> checkForGitHubUpdate(BuildContext context) async {
  if (_updateCheckStarted || !Platform.isAndroid) {
    return;
  }
  _updateCheckStarted = true;

  try {
    final versionData = await _appUpdateChannel
        .invokeMapMethod<String, Object?>('getAppVersion')
        .timeout(const Duration(seconds: 5));
    final currentBuild = versionData?['build'];
    if (currentBuild is! int) {
      return;
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final request = await client.getUrl(Uri.parse(_latestReleaseUrl));
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.github+json',
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'Ticketmaster-Updater');
      request.headers.set('X-GitHub-Api-Version', '2022-11-28');
      final response =
          await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != HttpStatus.ok) {
        return;
      }

      final payload = jsonDecode(await utf8.decodeStream(response));
      if (payload is! Map<String, dynamic>) {
        return;
      }

      final tagName = payload['tag_name'];
      final tagMatch = tagName is String
          ? RegExp(r'^v?(\d+\.\d+\.\d+)\+(\d+)$').firstMatch(tagName.trim())
          : null;
      final latestVersion = tagMatch?.group(1);
      final latestBuild = int.tryParse(tagMatch?.group(2) ?? '');
      final assets = payload['assets'];
      final apkAsset = assets is List
          ? assets
              .whereType<Map>()
              .cast<Map<Object?, Object?>>()
              .where((asset) {
              final name = asset['name'];
              return name is String && name.toLowerCase().endsWith('.apk');
            }).firstOrNull
          : null;
      final apkUrl = apkAsset?['browser_download_url'];
      if (latestBuild == null ||
          latestVersion == null ||
          apkUrl is! String ||
          latestBuild <= currentBuild) {
        return;
      }

      final rawReleaseNotes = payload['body'];
      final releaseNotes = rawReleaseNotes is String
          ? rawReleaseNotes.replaceAll('[force-update]', '').trim()
          : '';
      final forceUpdate = rawReleaseNotes is String &&
          rawReleaseNotes.toLowerCase().contains('[force-update]');

      if (!context.mounted) {
        return;
      }
      await _showUpdateDialog(
        context,
        latestVersion: latestVersion,
        releaseNotes: releaseNotes,
        apkUrl: apkUrl,
        forceUpdate: forceUpdate,
      );
    } finally {
      client.close(force: true);
    }
  } catch (_) {
    // Update checks must never prevent the app from starting.
  }
}

Future<void> _showUpdateDialog(
  BuildContext context, {
  required String latestVersion,
  required String releaseNotes,
  required String apkUrl,
  required bool forceUpdate,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !forceUpdate,
    builder: (dialogContext) {
      return PopScope(
        canPop: !forceUpdate,
        child: AlertDialog(
          title: const Text('Newer version available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version $latestVersion is ready to install.'),
              if (releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  "What's new",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: SingleChildScrollView(child: Text(releaseNotes)),
                ),
              ],
            ],
          ),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('LATER'),
              ),
            FilledButton(
              onPressed: () async {
                await _appUpdateChannel.invokeMethod<void>(
                  'openUpdateUrl',
                  {'url': apkUrl},
                );
              },
              child: const Text('UPDATE'),
            ),
          ],
        ),
      );
    },
  );
}
