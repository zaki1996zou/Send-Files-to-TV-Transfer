import 'package:flutter/material.dart';

/// Describes what the app can actually do for each method on iOS.
enum TransferCapability {
  /// Native AirPlay player + iOS share sheet.
  nativeAirPlay,

  /// Network cast via dart_cast (mDNS/SSDP + local HTTP file server).
  networkCast,

  /// iOS share sheet plus setup instructions (no direct TV API).
  shareAndGuide,

  /// Miracast is unavailable on iOS; offers AirPlay alternative only.
  iosAlternativeOnly,
}

class SharingMethod {
  const SharingMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.shortDescription,
    required this.duration,
    required this.difficulty,
    required this.fileTypes,
    required this.icon,
    required this.overview,
    required this.requirements,
    required this.steps,
    required this.capability,
    required this.capabilityNote,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final String shortDescription;
  final String duration;
  final String difficulty;
  final List<String> fileTypes;
  final IconData icon;
  final String overview;
  final List<String> requirements;
  final List<String> steps;
  final TransferCapability capability;
  final String capabilityNote;
}
