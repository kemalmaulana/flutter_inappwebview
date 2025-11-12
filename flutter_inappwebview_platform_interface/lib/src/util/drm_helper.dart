import '../in_app_webview/platform_inappwebview_controller.dart';
import '../types/drm_capability.dart';
import '../types/media_key_system_configuration.dart';

/// Helper class for DRM (Digital Rights Management) operations.
///
/// Provides convenient methods for checking DRM support and working with
/// protected content in web views.
class DRMHelper {
  /// Checks if PlayReady DRM is supported.
  ///
  /// Returns a [DRMCapability] object with support information.
  ///
  /// Example:
  /// ```dart
  /// final playReadySupport = await DRMHelper.checkPlayReadySupport(controller);
  /// if (playReadySupport.isSupported) {
  ///   print('PlayReady is supported!');
  /// }
  /// ```
  static Future<DRMCapability> checkPlayReadySupport(
    PlatformInAppWebViewController controller, {
    MediaKeySystemConfiguration? configuration,
  }) {
    return controller.checkDRMSupport(
      keySystem: DRMKeySystem.playReady,
      configuration: configuration,
    );
  }

  /// Checks if Widevine DRM is supported.
  ///
  /// Returns a [DRMCapability] object with support information.
  ///
  /// Example:
  /// ```dart
  /// final widevineSupport = await DRMHelper.checkWidevineSupport(controller);
  /// if (widevineSupport.isSupported) {
  ///   print('Widevine is supported!');
  /// }
  /// ```
  static Future<DRMCapability> checkWidevineSupport(
    PlatformInAppWebViewController controller, {
    MediaKeySystemConfiguration? configuration,
  }) {
    return controller.checkDRMSupport(
      keySystem: DRMKeySystem.widevine,
      configuration: configuration,
    );
  }

  /// Checks if FairPlay Streaming DRM is supported.
  ///
  /// Returns a [DRMCapability] object with support information.
  ///
  /// Example:
  /// ```dart
  /// final fairPlaySupport = await DRMHelper.checkFairPlaySupport(controller);
  /// if (fairPlaySupport.isSupported) {
  ///   print('FairPlay is supported!');
  /// }
  /// ```
  static Future<DRMCapability> checkFairPlaySupport(
    PlatformInAppWebViewController controller, {
    MediaKeySystemConfiguration? configuration,
  }) {
    return controller.checkDRMSupport(
      keySystem: DRMKeySystem.fairPlay,
      configuration: configuration,
    );
  }

  /// Returns a formatted string summary of all DRM support.
  ///
  /// Checks all common DRM systems and returns a user-friendly string
  /// showing which are supported.
  ///
  /// Example:
  /// ```dart
  /// final summary = await DRMHelper.getDRMSupportSummary(controller);
  /// print(summary);
  /// // Output:
  /// // DRM Support Summary:
  /// // PlayReady: ✅ Supported (SW_SECURE_CRYPTO)
  /// // Widevine: ❌ Not Supported
  /// // FairPlay: ❌ Not Supported
  /// ```
  static Future<String> getDRMSupportSummary(
    PlatformInAppWebViewController controller,
  ) async {
    final capabilities = await controller.checkAllDRMSupport();
    final buffer = StringBuffer('DRM Support Summary:\n');

    for (final capability in capabilities) {
      final emoji = capability.isSupported ? '✅' : '❌';
      final status = capability.isSupported ? 'Supported' : 'Not Supported';
      final name = _getFriendlyName(capability.keySystem);
      final securityLevel = capability.securityLevel != null
          ? ' (${capability.securityLevel})'
          : '';

      buffer.writeln('$name: $emoji $status$securityLevel');
    }

    return buffer.toString().trim();
  }

  /// Creates a default configuration for HD video playback with software DRM.
  ///
  /// This configuration is suitable for most common use cases with PlayReady
  /// or Widevine DRM.
  static MediaKeySystemConfiguration createDefaultConfiguration() {
    return const MediaKeySystemConfiguration(
      initDataTypes: ['cenc', 'keyids'],
      videoCapabilities: [
        MediaKeySystemMediaCapability(
          contentType: 'video/mp4; codecs="avc1.42E01E"',
          robustness: 'SW_SECURE_CRYPTO',
        ),
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
      distinctiveIdentifier: MediaKeysRequirement.optional,
      persistentState: MediaKeysRequirement.optional,
    );
  }

  /// Creates a configuration for hardware-backed DRM (higher security).
  ///
  /// This configuration requires hardware DRM support, which provides
  /// better security but may not be available on all devices.
  ///
  /// Use this for premium/4K content that requires higher security levels.
  static MediaKeySystemConfiguration createHardwareConfiguration() {
    return const MediaKeySystemConfiguration(
      initDataTypes: ['cenc'],
      videoCapabilities: [
        MediaKeySystemMediaCapability(
          contentType: 'video/mp4; codecs="avc1.64001F"',
          robustness: 'HW_SECURE_ALL',
        ),
      ],
      audioCapabilities: [
        MediaKeySystemMediaCapability(
          contentType: 'audio/mp4; codecs="mp4a.40.2"',
          robustness: 'HW_SECURE_ALL',
        ),
      ],
      distinctiveIdentifier: MediaKeysRequirement.required,
      persistentState: MediaKeysRequirement.optional,
    );
  }

  /// Checks if any DRM system is supported.
  ///
  /// Returns true if at least one common DRM system is available.
  ///
  /// Example:
  /// ```dart
  /// if (await DRMHelper.isAnyDRMSupported(controller)) {
  ///   print('Device supports protected content playback');
  /// }
  /// ```
  static Future<bool> isAnyDRMSupported(
    PlatformInAppWebViewController controller,
  ) async {
    final capabilities = await controller.checkAllDRMSupport();
    return capabilities.any((cap) => cap.isSupported);
  }

  /// Returns a map of DRM capabilities by key system.
  ///
  /// Makes it easy to look up support for specific DRM systems.
  ///
  /// Example:
  /// ```dart
  /// final capMap = await DRMHelper.getDRMCapabilityMap(controller);
  /// if (capMap[DRMKeySystem.playReady]?.isSupported == true) {
  ///   print('PlayReady is available');
  /// }
  /// ```
  static Future<Map<String, DRMCapability>> getDRMCapabilityMap(
    PlatformInAppWebViewController controller,
  ) async {
    final capabilities = await controller.checkAllDRMSupport();
    return {for (var cap in capabilities) cap.keySystem: cap};
  }

  static String _getFriendlyName(String keySystem) {
    if (keySystem.contains('playready')) {
      if (keySystem.contains('hardware')) return 'PlayReady Hardware';
      if (keySystem.contains('recommendation')) return 'PlayReady Recommendation';
      return 'PlayReady';
    }
    if (keySystem.contains('widevine')) return 'Widevine';
    if (keySystem.contains('fairplay') || keySystem.contains('fps'))
      return 'FairPlay';
    return keySystem;
  }
}
