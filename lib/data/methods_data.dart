import 'package:flutter/material.dart';
import '../models/sharing_method.dart';

const List<SharingMethod> sharingMethods = [
  SharingMethod(
    id: 'airplay',
    name: 'AirPlay',
    type: 'Wireless',
    description: 'Stream videos via native AirPlay or share files with iOS',
    shortDescription: 'Native AirPlay video + iOS sharing',
    duration: '5 min',
    difficulty: 'Easy',
    fileTypes: ['MP4', 'MOV', 'MKV'],
    icon: Icons.airplay,
    capability: TransferCapability.nativeAirPlay,
    capabilityNote:
        'Videos play in the native iOS player with the system AirPlay picker. '
        'Photos, audio, and documents use the iOS share sheet. '
        'Availability depends on your TV and network.',
    overview:
        'On iPhone, AirPlay uses Apple\'s native playback and sharing APIs. '
        'Select a video to open the built-in player, then choose your Apple TV '
        'or AirPlay-compatible TV from the system AirPlay button. '
        'For other file types, the app opens the iOS share sheet so you can '
        'send files to compatible apps and devices.',
    requirements: [
      'iPhone or iPad on the same WiFi as your TV',
      'Apple TV or AirPlay 2-compatible smart TV',
      'Compatible media files (MP4, MOV recommended for video)',
      'Latest iOS and TV software updates',
    ],
    steps: [
      'Connect your iPhone and TV to the same WiFi network.',
      'In this app, select a file and tap the AirPlay transfer option.',
      'For videos: use the AirPlay button in the player to choose your TV.',
      'For photos/documents: use the iOS share sheet to open on a compatible device.',
      'If your TV shows a code, enter it when iOS prompts you.',
      'Use your iPhone or TV remote to control playback.',
    ],
  ),
  SharingMethod(
    id: 'chromecast',
    name: 'Chromecast',
    type: 'Wireless',
    description: 'Cast local videos to Chromecast devices on your network',
    shortDescription: 'Discover & cast local video files',
    duration: '6 min',
    difficulty: 'Medium',
    fileTypes: ['MP4', 'AVI', 'MKV'],
    icon: Icons.cast,
    capability: TransferCapability.networkCast,
    capabilityNote:
        'Uses network discovery and a local HTTP server to stream your selected '
        'video to a Chromecast on the same WiFi. MP4 works best. '
        'Not the official Google Cast SDK — compatibility varies by device.',
    overview:
        'The app scans your local network for Chromecast devices, connects to '
        'the one you choose, and streams your selected video file through a '
        'temporary HTTP server on your iPhone. Playback can be controlled '
        'from the in-app remote. MP4 is the most reliable format.',
    requirements: [
      'Chromecast or Chromecast built-in TV',
      'iPhone and Chromecast on the same WiFi network',
      'Local network permission granted on iPhone',
      'Video file in a supported format (MP4 recommended)',
    ],
    steps: [
      'Connect your iPhone and Chromecast to the same WiFi network.',
      'Select a video file in this app.',
      'Tap send — the app will scan for Chromecast devices.',
      'Choose your Chromecast from the discovered list.',
      'Wait for the video to load on your TV.',
      'Use the in-app remote for play, pause, seek, and stop.',
    ],
  ),
  SharingMethod(
    id: 'dlna',
    name: 'DLNA',
    type: 'Wireless',
    description: 'Stream local videos to DLNA/UPnP TVs on your network',
    shortDescription: 'Discover & stream to DLNA TVs',
    duration: '8 min',
    difficulty: 'Medium',
    fileTypes: ['MP4', 'AVI', 'MKV'],
    icon: Icons.devices,
    capability: TransferCapability.networkCast,
    capabilityNote:
        'Uses SSDP/UPnP discovery and a local HTTP server to send your video '
        'to DLNA-compatible TVs. Compatibility depends on your TV model and '
        'supported codecs.',
    overview:
        'The app discovers DLNA renderers on your local network, connects using '
        'UPnP AVTransport controls, and serves your selected video through a '
        'local HTTP proxy on your iPhone. Playback controls are available in-app.',
    requirements: [
      'DLNA-compatible smart TV or media player',
      'iPhone and TV on the same WiFi network',
      'Local network permission granted on iPhone',
      'Video file in a supported format (MP4, MKV)',
    ],
    steps: [
      'Connect your iPhone and TV to the same WiFi network.',
      'Enable DLNA/media renderer on your TV if required.',
      'Select a video file in this app.',
      'Tap send — the app scans for DLNA devices.',
      'Choose your TV from the discovered list.',
      'Use the in-app remote to control playback.',
    ],
  ),
  SharingMethod(
    id: 'miracast',
    name: 'Miracast',
    type: 'Guide',
    description: 'Not supported on iPhone — use AirPlay instead',
    shortDescription: 'iOS alternative: AirPlay guide',
    duration: '3 min',
    difficulty: 'Easy',
    fileTypes: ['MP4', 'MOV'],
    icon: Icons.screen_share,
    capability: TransferCapability.iosAlternativeOnly,
    capabilityNote:
        'Miracast is not natively supported on iOS. This section explains the '
        'limitation and directs you to AirPlay or system sharing options.',
    overview:
        'Miracast screen mirroring is not available on iPhone. If your TV '
        'supports AirPlay, use the AirPlay method in this app instead. '
        'You can also share files via the iOS share sheet to compatible apps.',
    requirements: [
      'AirPlay-compatible TV (recommended alternative)',
      'iPhone and TV on the same WiFi network',
      'For non-AirPlay TVs: use HDMI adapter or a compatible third-party app',
    ],
    steps: [
      'Miracast does not work directly from iPhone.',
      'If your TV supports AirPlay, go to the AirPlay method in this app.',
      'Select your file and use the native AirPlay picker to stream to TV.',
      'Alternatively, use the iOS share sheet to open files in compatible apps.',
      'For wired display, see the HDMI setup guide in this app.',
    ],
  ),
  SharingMethod(
    id: 'hdmi',
    name: 'HDMI',
    type: 'Wired',
    description: 'Share files and follow wired HDMI setup steps',
    shortDescription: 'Share file + HDMI setup guide',
    duration: '3 min',
    difficulty: 'Easy',
    fileTypes: ['MP4', 'MOV', 'AVI'],
    icon: Icons.cable,
    capability: TransferCapability.shareAndGuide,
    capabilityNote:
        'iOS cannot detect HDMI connections programmatically. '
        'The app shares your file and provides setup steps for a Lightning/USB-C to HDMI adapter.',
    overview:
        'Connect your iPhone to your TV with a certified Lightning or USB-C to '
        'HDMI adapter. Use this app to prepare and share your file, then open '
        'it on your iPhone while the display is mirrored to your TV.',
    requirements: [
      'Apple-certified Lightning/USB-C to HDMI adapter',
      'HDMI cable and TV with an available HDMI port',
      'Media file in a TV-supported format',
    ],
    steps: [
      'Connect the HDMI adapter to your iPhone and TV.',
      'Switch your TV to the correct HDMI input.',
      'In this app, select your file and tap share.',
      'Open the file in Photos, Files, or a compatible video app.',
      'Your iPhone screen (and playback) will appear on the TV.',
    ],
  ),
  SharingMethod(
    id: 'usb',
    name: 'USB',
    type: 'Wired',
    description: 'Share files for USB transfer to your TV',
    shortDescription: 'Share file + USB setup guide',
    duration: '4 min',
    difficulty: 'Easy',
    fileTypes: ['MP4', 'AVI', 'MKV'],
    icon: Icons.usb,
    capability: TransferCapability.shareAndGuide,
    capabilityNote:
        'iOS cannot write directly to a TV USB port. '
        'Use the share sheet to save files to Files, then copy to a USB drive.',
    overview:
        'Many smart TVs play media from a USB drive. Use this app to share or '
        'save your file, copy it to a USB drive via a computer or Files app, '
        'then insert the drive into your TV.',
    requirements: [
      'USB drive formatted as FAT32 or exFAT',
      'Smart TV with USB media playback',
      'File in a format your TV supports',
    ],
    steps: [
      'Select your file in this app and tap share.',
      'Save to Files or share to a computer.',
      'Copy the file to a USB drive.',
      'Safely eject and insert the USB drive into your TV.',
      'Open the TV media browser and play the file.',
    ],
  ),
  SharingMethod(
    id: 'bluetooth',
    name: 'Bluetooth',
    type: 'Wireless',
    description: 'Share audio files via iOS to Bluetooth devices',
    shortDescription: 'Share audio via iOS share sheet',
    duration: '5 min',
    difficulty: 'Easy',
    fileTypes: ['MP3', 'AAC', 'WAV'],
    icon: Icons.bluetooth,
    capability: TransferCapability.shareAndGuide,
    capabilityNote:
        'The app shares audio files through the iOS share sheet. '
        'Pair your Bluetooth speaker or TV in iOS Settings separately.',
    overview:
        'Share audio files from this app using the iOS share sheet. '
        'Open the file in a music app and route audio to your paired '
        'Bluetooth speaker or compatible TV.',
    requirements: [
      'Bluetooth audio device or compatible TV',
      'Audio file in MP3, AAC, or WAV format',
      'Bluetooth enabled and device paired in iOS Settings',
    ],
    steps: [
      'Pair your Bluetooth device in iPhone Settings > Bluetooth.',
      'Select an audio file in this app.',
      'Tap share and open in a music or audio app.',
      'Play the audio and select your Bluetooth device as output.',
    ],
  ),
  SharingMethod(
    id: 'wifi_direct',
    name: 'WiFi Direct',
    type: 'Guide',
    description: 'Not supported on iOS — use network sharing options',
    shortDescription: 'Share file + alternative guide',
    duration: '5 min',
    difficulty: 'Easy',
    fileTypes: ['MP4', 'PDF', 'JPG'],
    icon: Icons.wifi_tethering,
    capability: TransferCapability.shareAndGuide,
    capabilityNote:
        'WiFi Direct file transfer is not available on iOS. '
        'Use AirPlay, Chromecast, DLNA, or the iOS share sheet instead.',
    overview:
        'iPhone does not expose WiFi Direct file transfer to apps. '
        'Use wireless casting methods in this app or share files through '
        'the iOS share sheet to cloud storage or compatible TV apps.',
    requirements: [
      'Same WiFi network for casting methods',
      'Compatible TV apps or cloud storage for file sharing',
    ],
    steps: [
      'WiFi Direct is not supported on iPhone.',
      'For wireless transfer, try AirPlay, Chromecast, or DLNA in this app.',
      'Select your file and use the iOS share sheet for other destinations.',
      'Upload to cloud storage and open on your TV if supported.',
    ],
  ),
];

SharingMethod? findMethodById(String id) {
  for (final method in sharingMethods) {
    if (method.id == id) return method;
  }
  return null;
}

SharingMethod? findMethodByName(String name) {
  for (final method in sharingMethods) {
    if (method.name.toLowerCase() == name.toLowerCase()) return method;
  }
  return null;
}
