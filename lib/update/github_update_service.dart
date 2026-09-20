import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _latestReleaseUrl =
    'https://api.github.com/repos/alc-moon7/TicketMaster-Latest/releases/latest';
const _appUpdateChannel = MethodChannel('ticketmaster/app_update');
final appUpdateNavigatorKey = GlobalKey<NavigatorState>();
Timer? _offlineUpdateRetryTimer;
bool _retryInProgress = false;

void _retryUpdateCheckWhenOnline() {
  _offlineUpdateRetryTimer ??= Timer.periodic(
    const Duration(seconds: 15),
    (_) {
      final context = appUpdateNavigatorKey.currentContext;
      if (context == null || _retryInProgress) return;
      _retryInProgress = true;
      unawaited(checkForGitHubUpdate(context).whenComplete(() {
        _retryInProgress = false;
      }));
    },
  );
}

void _stopOfflineUpdateRetry() {
  _offlineUpdateRetryTimer?.cancel();
  _offlineUpdateRetryTimer = null;
}

Future<void> checkForGitHubUpdate(BuildContext context) async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final versionData = await _appUpdateChannel
        .invokeMapMethod<String, Object?>('getAppVersion')
        .timeout(const Duration(seconds: 5));
    final currentBuild = versionData?['build'];
    if (currentBuild is! int) {
      throw const FormatException('Could not read the installed build.');
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
        throw HttpException('GitHub returned HTTP ${response.statusCode}.');
      }

      final payload = jsonDecode(await utf8.decodeStream(response));
      if (payload is! Map<String, dynamic>) {
        throw const FormatException('Invalid release response.');
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
      if (latestBuild == null || latestVersion == null || apkUrl is! String) {
        throw const FormatException('The latest release has no valid APK.');
      }
      if (latestBuild <= currentBuild) {
        _stopOfflineUpdateRetry();
        return;
      }

      final rawReleaseNotes = payload['body'];
      final releaseNotes = rawReleaseNotes is String
          ? rawReleaseNotes.replaceAll('[force-update]', '').trim()
          : '';
      if (!context.mounted) {
        return;
      }
      _stopOfflineUpdateRetry();
      await _showUpdateDialog(
        context,
        latestVersion: latestVersion,
        releaseNotes: releaseNotes,
        apkUrl: apkUrl,
      );
    } finally {
      client.close(force: true);
    }
  } on SocketException {
    _retryUpdateCheckWhenOnline();
  } on TimeoutException {
    _retryUpdateCheckWhenOnline();
  } on HandshakeException {
    _retryUpdateCheckWhenOnline();
  } catch (_) {
    if (!context.mounted) return;
    await _showUpdateCheckRetryDialog(context);
    if (context.mounted) {
      await checkForGitHubUpdate(context);
    }
  }
}

Future<void> _showUpdateCheckRetryDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Update check unavailable'),
        content: const Text(
          'Connect to the internet and retry to check for updates.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('RETRY'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showUpdateDialog(
  BuildContext context, {
  required String latestVersion,
  required String releaseNotes,
  required String apkUrl,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _GitHubUpdateDialog(
      latestVersion: latestVersion,
      releaseNotes: releaseNotes,
      apkUrl: apkUrl,
    ),
  );
}

class _GitHubUpdateDialog extends StatefulWidget {
  const _GitHubUpdateDialog({
    required this.latestVersion,
    required this.releaseNotes,
    required this.apkUrl,
  });

  final String latestVersion;
  final String releaseNotes;
  final String apkUrl;

  @override
  State<_GitHubUpdateDialog> createState() => _GitHubUpdateDialogState();
}

class _GitHubUpdateDialogState extends State<_GitHubUpdateDialog> {
  bool _isWorking = false;
  double? _progress;
  String? _status;

  Future<void> _downloadAndInstall() async {
    if (_isWorking) {
      return;
    }
    setState(() {
      _isWorking = true;
      _progress = null;
      _status = 'Preparing update…';
    });

    File? partialFile;
    HttpClient? client;
    try {
      final canInstall = await _appUpdateChannel.invokeMethod<bool>(
        'prepareApkInstall',
      );
      if (canInstall != true) {
        if (mounted) {
          setState(() {
            _isWorking = false;
            _status = 'Allow installs from this app, then tap UPDATE again.';
          });
        }
        return;
      }

      final destinationPath = await _appUpdateChannel.invokeMethod<String>(
        'getUpdateFilePath',
      );
      final downloadUri = Uri.tryParse(widget.apkUrl);
      if (destinationPath == null ||
          downloadUri == null ||
          downloadUri.scheme != 'https') {
        throw const FormatException('The release APK link is invalid.');
      }

      final destinationFile = File(destinationPath);
      partialFile = File('$destinationPath.part');
      if (await partialFile.exists()) {
        await partialFile.delete();
      }

      client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
      final request = await client.getUrl(downloadUri);
      request.headers.set(HttpHeaders.userAgentHeader, 'Ticketmaster-Updater');
      final response =
          await request.close().timeout(const Duration(seconds: 20));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'GitHub returned HTTP ${response.statusCode}.',
          uri: downloadUri,
        );
      }

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      var lastPercent = -1;
      final output = partialFile.openWrite();
      try {
        await for (final chunk in response) {
          output.add(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            final percent = (receivedBytes * 100 / totalBytes).floor();
            if (percent != lastPercent && mounted) {
              lastPercent = percent;
              setState(() {
                _progress = receivedBytes / totalBytes;
                _status = 'Downloading… $percent%';
              });
            }
          } else if (mounted && _progress != null) {
            setState(() {
              _progress = null;
              _status = 'Downloading update…';
            });
          }
        }
      } finally {
        await output.flush();
        await output.close();
      }

      if (receivedBytes == 0) {
        throw const FileSystemException('The downloaded APK is empty.');
      }
      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }
      await partialFile.rename(destinationPath);
      partialFile = null;

      if (mounted) {
        setState(() {
          _progress = 1;
          _status = 'Download complete. Opening installer…';
        });
      }
      await _appUpdateChannel.invokeMethod<void>(
        'installDownloadedApk',
        {'path': destinationPath},
      );
      if (mounted) {
        setState(() {
          _isWorking = false;
          _status = 'Complete the installation, then reopen the app.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isWorking = false;
          _progress = null;
          _status = 'Update failed. Check your connection and try again.';
        });
      }
      try {
        if (partialFile != null && await partialFile.exists()) {
          await partialFile.delete();
        }
      } catch (_) {
        // A stale partial file is overwritten by the next attempt.
      }
    } finally {
      client?.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Newer version available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${widget.latestVersion} is ready to install.'),
            if (widget.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                "What's new",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(child: Text(widget.releaseNotes)),
              ),
            ],
            if (_status != null) ...[
              const SizedBox(height: 18),
              if (_isWorking)
                LinearProgressIndicator(value: _progress)
              else
                const Icon(Icons.info_outline, size: 20),
              const SizedBox(height: 8),
              Text(_status!),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: _isWorking ? null : _downloadAndInstall,
            child: Text(_isWorking ? 'DOWNLOADING' : 'UPDATE'),
          ),
        ],
      ),
    );
  }
}
