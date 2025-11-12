import 'package:flutter/foundation.dart';

/// Represents DRM (Digital Rights Management) system capability information.
@immutable
class DRMCapability {
  /// The DRM system identifier or name.
  /// Examples: 'com.microsoft.playready', 'com.widevine.alpha', 'PlayReady', 'Widevine'
  final String keySystem;

  /// Whether this DRM system is supported.
  final bool isSupported;

  /// The security level or robustness level available.
  /// Examples: 'L1', 'L3', 'SW_SECURE_CRYPTO', 'HW_SECURE_ALL'
  final String? securityLevel;

  /// Additional information about the DRM system support.
  final String? description;

  /// Error message if checking failed.
  final String? error;

  const DRMCapability({
    required this.keySystem,
    required this.isSupported,
    this.securityLevel,
    this.description,
    this.error,
  });

  factory DRMCapability.fromMap(Map<String, dynamic> map) {
    return DRMCapability(
      keySystem: map['keySystem'] as String,
      isSupported: map['isSupported'] as bool,
      securityLevel: map['securityLevel'] as String?,
      description: map['description'] as String?,
      error: map['error'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'keySystem': keySystem,
      'isSupported': isSupported,
      if (securityLevel != null) 'securityLevel': securityLevel,
      if (description != null) 'description': description,
      if (error != null) 'error': error,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'DRMCapability{keySystem: $keySystem, isSupported: $isSupported, securityLevel: $securityLevel, description: $description, error: $error}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DRMCapability &&
          runtimeType == other.runtimeType &&
          keySystem == other.keySystem &&
          isSupported == other.isSupported &&
          securityLevel == other.securityLevel &&
          description == other.description &&
          error == other.error;

  @override
  int get hashCode =>
      keySystem.hashCode ^
      isSupported.hashCode ^
      (securityLevel?.hashCode ?? 0) ^
      (description?.hashCode ?? 0) ^
      (error?.hashCode ?? 0);
}

/// Common DRM key system identifiers.
class DRMKeySystem {
  /// Microsoft PlayReady DRM system.
  static const String playReady = 'com.microsoft.playready';

  /// Microsoft PlayReady Recommendation profile.
  static const String playReadyRecommendation = 'com.microsoft.playready.recommendation';

  /// Microsoft PlayReady Hardware-based DRM.
  static const String playReadyHardware = 'com.microsoft.playready.hardware';

  /// Google Widevine DRM system.
  static const String widevine = 'com.widevine.alpha';

  /// Apple FairPlay Streaming DRM system.
  static const String fairPlay = 'com.apple.fps';

  /// Apple FairPlay Streaming (alternative identifier).
  static const String fairPlayStreaming = 'com.apple.fps.1_0';

  /// List of all common DRM key systems.
  static const List<String> all = [
    playReady,
    playReadyRecommendation,
    playReadyHardware,
    widevine,
    fairPlay,
    fairPlayStreaming,
  ];

  /// List of PlayReady variants.
  static const List<String> playReadyVariants = [
    playReady,
    playReadyRecommendation,
    playReadyHardware,
  ];
}
