# DRM Support in Flutter InAppWebView

This document explains how to use the DRM (Digital Rights Management) detection and support features in the flutter_inappwebview library.

## Overview

The library now includes built-in support for detecting and working with DRM systems:
- **PlayReady** (Windows, Xbox)
- **Widevine** (Android, Chrome)
- **FairPlay** (iOS, macOS)

## Quick Start

### 1. Basic DRM Detection

```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DRMDetectionExample extends StatefulWidget {
  @override
  _DRMDetectionExampleState createState() => _DRMDetectionExampleState();
}

class _DRMDetectionExampleState extends State<DRMDetectionExample> {
  InAppWebViewController? _controller;
  String _drmStatus = 'Checking...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DRM Detection')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(_drmStatus, style: TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
              ),
              initialUrlRequest: URLRequest(
                url: WebUri('https://www.example.com'),
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onLoadStop: (controller, url) async {
                await _checkDRMSupport();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkDRMSupport() async {
    if (_controller == null) return;

    // Get summary of all DRM support
    final summary = await DRMHelper.getDRMSupportSummary(_controller!);
    setState(() {
      _drmStatus = summary;
    });
  }
}
```

### 2. Check Specific DRM System

```dart
// Check PlayReady support (Windows)
final playReadySupport = await DRMHelper.checkPlayReadySupport(controller);
if (playReadySupport.isSupported) {
  print('PlayReady is supported!');
  print('Security Level: ${playReadySupport.securityLevel}');
}

// Check Widevine support (Android/Chrome)
final widevineSupport = await DRMHelper.checkWidevineSupport(controller);
if (widevineSupport.isSupported) {
  print('Widevine is supported!');
}

// Check FairPlay support (iOS/macOS)
final fairPlaySupport = await DRMHelper.checkFairPlaySupport(controller);
if (fairPlaySupport.isSupported) {
  print('FairPlay is supported!');
}
```

### 3. Advanced Configuration

```dart
// Check with custom configuration for HD content
final config = MediaKeySystemConfiguration(
  initDataTypes: ['cenc'],
  videoCapabilities: [
    MediaKeySystemMediaCapability(
      contentType: 'video/mp4; codecs="avc1.64001F"',
      robustness: 'SW_SECURE_CRYPTO',
    ),
  ],
  audioCapabilities: [
    MediaKeySystemMediaCapability(
      contentType: 'audio/mp4; codecs="mp4a.40.2"',
      robustness: 'SW_SECURE_CRYPTO',
    ),
  ],
);

final drmCapability = await controller.checkDRMSupport(
  keySystem: DRMKeySystem.playReady,
  configuration: config,
);
```

### 4. Check All DRM Systems

```dart
// Get a map of all DRM capabilities
final capMap = await DRMHelper.getDRMCapabilityMap(controller);

// Check specific system
if (capMap[DRMKeySystem.playReady]?.isSupported == true) {
  print('PlayReady available!');
}

// Check if any DRM is supported
if (await DRMHelper.isAnyDRMSupported(controller)) {
  print('Device can play protected content');
}
```

### 5. Playing PlayReady Protected Content (Windows Example)

```dart
class PlayReadyVideoPlayer extends StatefulWidget {
  @override
  _PlayReadyVideoPlayerState createState() => _PlayReadyVideoPlayerState();
}

class _PlayReadyVideoPlayerState extends State<PlayReadyVideoPlayer> {
  InAppWebViewController? _controller;
  String _status = 'Initializing...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PlayReady Video')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(_status, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
              initialData: InAppWebViewInitialData(
                data: '''
                  <!DOCTYPE html>
                  <html>
                  <head>
                    <meta name="viewport" content="width=device-width">
                    <style>
                      body { margin: 0; background: #000; }
                      video { width: 100%; height: 100vh; }
                    </style>
                  </head>
                  <body>
                    <video id="video" controls></video>
                  </body>
                  </html>
                ''',
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onLoadStop: (controller, url) async {
                await _initializePlayReady();
              },
              onConsoleMessage: (controller, message) {
                print('Console: ${message.message}');
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializePlayReady() async {
    if (_controller == null) return;

    setState(() => _status = 'Checking PlayReady support...');

    // Check PlayReady support
    final playReady = await DRMHelper.checkPlayReadySupport(_controller!);

    if (!playReady.isSupported) {
      setState(() => _status = 'PlayReady not supported ❌');
      return;
    }

    setState(() => _status = 'Initializing DRM...');

    // Initialize PlayReady DRM
    await _controller!.evaluateJavascript(source: '''
      (async function() {
        try {
          const video = document.getElementById('video');
          video.src = 'YOUR_PLAYREADY_PROTECTED_VIDEO_URL';

          // Request PlayReady key system
          const keySystemAccess = await navigator.requestMediaKeySystemAccess(
            'com.microsoft.playready',
            [{
              initDataTypes: ['cenc'],
              videoCapabilities: [{
                contentType: 'video/mp4; codecs="avc1.42E01E"',
                robustness: 'SW_SECURE_CRYPTO'
              }],
              audioCapabilities: [{
                contentType: 'audio/mp4; codecs="mp4a.40.2"',
                robustness: 'SW_SECURE_CRYPTO'
              }]
            }]
          );

          const mediaKeys = await keySystemAccess.createMediaKeys();
          await video.setMediaKeys(mediaKeys);

          // Handle encrypted event
          video.addEventListener('encrypted', async (event) => {
            const session = mediaKeys.createSession();

            session.addEventListener('message', async (messageEvent) => {
              // Send license request to your license server
              const response = await fetch('YOUR_LICENSE_SERVER_URL', {
                method: 'POST',
                headers: { 'Content-Type': 'application/octet-stream' },
                body: messageEvent.message
              });

              const license = await response.arrayBuffer();
              await session.update(license);
              console.log('DRM initialized successfully');
            });

            await session.generateRequest(event.initDataType, event.initData);
          });

          console.log('PlayReady setup complete');
        } catch (error) {
          console.error('DRM error:', error);
        }
      })();
    ''');

    setState(() => _status = 'PlayReady Ready ✅');
  }
}
```

## Platform-Specific Notes

### Windows (WebView2)
- ✅ **PlayReady**: Natively supported
- ❌ **Widevine**: NOT available in WebView2
- ✅ **Security Level**: L3 (Software-based) available by default
- ❓ **L1 (Hardware)**: May be available in some configurations

### Android
- ✅ **Widevine**: Primary DRM system
- ❌ **PlayReady**: Generally not available
- ✅ **L1 & L3**: Depends on device hardware

### iOS/macOS
- ✅ **FairPlay Streaming**: Native support
- ❌ **Widevine/PlayReady**: Not available

## Requirements

### For All Platforms
1. **HTTPS Required**: DRM APIs only work with HTTPS URLs (not HTTP)
2. **JavaScript Enabled**: Must have `javaScriptEnabled: true`
3. **Valid License Server**: Need proper DRM license server from content provider

### For Windows
1. **WebView2 Evergreen Runtime**: Must use Evergreen (not Fixed runtime)
2. **Up-to-date WebView2**: Keep WebView2 runtime current

## Common Issues

### DRM Not Working?

1. **Check HTTPS**: Ensure URL uses HTTPS protocol
2. **Check JavaScript**: Verify JavaScript is enabled
3. **Check Platform**: Verify the DRM system is supported on your platform
4. **Check Runtime**: On Windows, ensure using Evergreen runtime

### How to Debug

```dart
// Enable console logging
InAppWebView(
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    isInspectable: true, // Enable DevTools
  ),
  onConsoleMessage: (controller, consoleMessage) {
    print('[Console] ${consoleMessage.messageLevel.name}: ${consoleMessage.message}');
  },
)
```

## API Reference

### DRMCapability

```dart
class DRMCapability {
  final String keySystem;         // DRM system identifier
  final bool isSupported;          // Whether supported
  final String? securityLevel;     // Security level (e.g., 'SW_SECURE_CRYPTO', 'L1', 'L3')
  final String? description;       // Additional info
  final String? error;             // Error message if check failed
}
```

### DRMKeySystem Constants

```dart
DRMKeySystem.playReady           // 'com.microsoft.playready'
DRMKeySystem.widevine            // 'com.widevine.alpha'
DRMKeySystem.fairPlay            // 'com.apple.fps'
DRMKeySystem.all                 // List of all common systems
```

### MediaKeySystemConfiguration

```dart
class MediaKeySystemConfiguration {
  final List<String>? initDataTypes;                           // e.g., ['cenc', 'keyids']
  final List<MediaKeySystemMediaCapability>? videoCapabilities;
  final List<MediaKeySystemMediaCapability>? audioCapabilities;
  final MediaKeysRequirement? distinctiveIdentifier;
  final MediaKeysRequirement? persistentState;
}
```

### DRMHelper Methods

```dart
// Check specific DRM systems
static Future<DRMCapability> checkPlayReadySupport(controller)
static Future<DRMCapability> checkWidevineSupport(controller)
static Future<DRMCapability> checkFairPlaySupport(controller)

// Get summary
static Future<String> getDRMSupportSummary(controller)

// Check any DRM
static Future<bool> isAnyDRMSupported(controller)

// Get capability map
static Future<Map<String, DRMCapability>> getDRMCapabilityMap(controller)

// Create configurations
static MediaKeySystemConfiguration createDefaultConfiguration()
static MediaKeySystemConfiguration createHardwareConfiguration()
```

## Resources

- [W3C Encrypted Media Extensions (EME) Specification](https://www.w3.org/TR/encrypted-media/)
- [Microsoft PlayReady Documentation](https://docs.microsoft.com/en-us/playready/)
- [Google Widevine Documentation](https://www.widevine.com/solutions/widevine-drm)
- [Apple FairPlay Streaming](https://developer.apple.com/streaming/fps/)

## License

This feature is part of flutter_inappwebview and follows the same license terms.
