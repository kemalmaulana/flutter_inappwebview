import 'package:flutter/foundation.dart';

/// Represents a Media Key System Configuration for DRM support.
/// This maps to the browser's MediaKeySystemConfiguration object.
@immutable
class MediaKeySystemConfiguration {
  /// List of supported initialization data types (e.g., 'cenc', 'keyids', 'webm').
  final List<String>? initDataTypes;

  /// Audio capabilities required for the configuration.
  final List<MediaKeySystemMediaCapability>? audioCapabilities;

  /// Video capabilities required for the configuration.
  final List<MediaKeySystemMediaCapability>? videoCapabilities;

  /// Distinctive identifier requirement.
  final MediaKeysRequirement? distinctiveIdentifier;

  /// Persistent state requirement.
  final MediaKeysRequirement? persistentState;

  /// Session types supported.
  final List<String>? sessionTypes;

  const MediaKeySystemConfiguration({
    this.initDataTypes,
    this.audioCapabilities,
    this.videoCapabilities,
    this.distinctiveIdentifier,
    this.persistentState,
    this.sessionTypes,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (initDataTypes != null) {
      map['initDataTypes'] = initDataTypes;
    }
    if (audioCapabilities != null) {
      map['audioCapabilities'] = audioCapabilities!.map((e) => e.toMap()).toList();
    }
    if (videoCapabilities != null) {
      map['videoCapabilities'] = videoCapabilities!.map((e) => e.toMap()).toList();
    }
    if (distinctiveIdentifier != null) {
      map['distinctiveIdentifier'] = distinctiveIdentifier!.toNativeValue();
    }
    if (persistentState != null) {
      map['persistentState'] = persistentState!.toNativeValue();
    }
    if (sessionTypes != null) {
      map['sessionTypes'] = sessionTypes;
    }
    return map;
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'MediaKeySystemConfiguration{initDataTypes: $initDataTypes, audioCapabilities: $audioCapabilities, videoCapabilities: $videoCapabilities, distinctiveIdentifier: $distinctiveIdentifier, persistentState: $persistentState, sessionTypes: $sessionTypes}';
  }
}

/// Represents media capability for a specific content type.
@immutable
class MediaKeySystemMediaCapability {
  /// The content type (MIME type with codec).
  /// Example: 'video/mp4; codecs="avc1.42E01E"'
  final String contentType;

  /// The robustness level required.
  /// Examples: 'SW_SECURE_CRYPTO', 'SW_SECURE_DECODE', 'HW_SECURE_CRYPTO', 'HW_SECURE_DECODE', 'HW_SECURE_ALL'
  final String? robustness;

  /// Encryption scheme. Example: 'cenc', 'cbcs', 'cbcs-1-9'
  final String? encryptionScheme;

  const MediaKeySystemMediaCapability({
    required this.contentType,
    this.robustness,
    this.encryptionScheme,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'contentType': contentType,
    };
    if (robustness != null) {
      map['robustness'] = robustness;
    }
    if (encryptionScheme != null) {
      map['encryptionScheme'] = encryptionScheme;
    }
    return map;
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'MediaKeySystemMediaCapability{contentType: $contentType, robustness: $robustness, encryptionScheme: $encryptionScheme}';
  }
}

/// Represents the requirement level for distinctive identifier or persistent state.
enum MediaKeysRequirement {
  /// The feature is required.
  required,

  /// The feature is optional.
  optional,

  /// The feature is not allowed.
  notAllowed;

  String toNativeValue() {
    switch (this) {
      case MediaKeysRequirement.required:
        return 'required';
      case MediaKeysRequirement.optional:
        return 'optional';
      case MediaKeysRequirement.notAllowed:
        return 'not-allowed';
    }
  }

  static MediaKeysRequirement? fromNativeValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'required':
        return MediaKeysRequirement.required;
      case 'optional':
        return MediaKeysRequirement.optional;
      case 'not-allowed':
        return MediaKeysRequirement.notAllowed;
      default:
        return null;
    }
  }
}
