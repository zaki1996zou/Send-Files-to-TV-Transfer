import 'dart:async';

import 'package:dart_cast/dart_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/ads_actions.dart';
import '../../theme/app_colors.dart';

class CastRemoteScreen extends StatefulWidget {
  const CastRemoteScreen({
    super.key,
    required this.session,
    required this.device,
    required this.media,
  });

  final CastSession session;
  final CastDevice device;
  final CastMedia media;

  @override
  State<CastRemoteScreen> createState() => _CastRemoteScreenState();
}

class _CastRemoteScreenState extends State<CastRemoteScreen> {
  bool _loading = true;
  String? _error;
  StreamSubscription<SessionState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _startCasting();
    _stateSub = widget.session.stateStream.listen((state) {
      if (state == SessionState.disconnected && mounted) {
        _popWithResult();
      }
    });
  }

  Future<void> _startCasting() async {
    try {
      await widget.session.loadMedia(widget.media);
      if (mounted) {
        setState(() => _loading = false);
        _castResult = true;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
          _castResult = false;
        });
      }
    }
  }

  bool? _castResult;

  @override
  void dispose() {
    _stateSub?.cancel();
    widget.session.stop().catchError((_) {});
    super.dispose();
  }

  void _popWithResult() {
    AdsActions.showInterstitialThen(() {
      if (mounted) Navigator.pop(context, _castResult ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithResult();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: _popWithResult,
        ),
        title: Text(
          widget.device.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.gradientCyan),
                  SizedBox(height: 16),
                  Text('Sending to TV...', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : _error != null
              ? _buildError()
              : _buildControls(),
    ),
    );
  }

  Widget _buildError() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'Transfer failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _popWithResult,
            child: const Text('Go Back'),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  widget.device.protocol == CastProtocol.chromecast
                      ? Icons.cast_connected
                      : widget.device.protocol == CastProtocol.dlna
                          ? Icons.devices
                          : Icons.airplay,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.media.title ?? 'Media',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Playing on ${widget.device.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StreamBuilder<SessionState>(
            stream: widget.session.stateStream,
            builder: (context, snapshot) {
              final state = snapshot.data ?? SessionState.idle;
              return Text(
                _stateLabel(state),
                style: const TextStyle(color: AppColors.accentTeal, fontSize: 14),
              );
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<Duration>(
            stream: widget.session.positionStream,
            initialData: Duration.zero,
            builder: (context, posSnap) {
              return StreamBuilder<Duration>(
                stream: widget.session.durationStream,
                initialData: Duration.zero,
                builder: (context, durSnap) {
                  final position = posSnap.data ?? Duration.zero;
                  final duration = durSnap.data ?? Duration.zero;
                  final max = duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1.0;
                  final value = position.inMilliseconds.toDouble().clamp(0.0, max);

                  return Column(
                    children: [
                      Slider(
                        value: value,
                        max: max,
                        activeColor: AppColors.gradientCyan,
                        onChanged: duration.inMilliseconds > 0
                            ? (v) => widget.session.seek(
                                  Duration(milliseconds: v.round()),
                                )
                            : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text(_formatDuration(duration),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.replay_10,
                onTap: () async {
                  final pos = await widget.session.positionStream.first;
                  await widget.session.seek(pos - const Duration(seconds: 10));
                },
              ),
              const SizedBox(width: 16),
              StreamBuilder<SessionState>(
                stream: widget.session.stateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data == SessionState.playing;
                  return _ControlButton(
                    icon: playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 64,
                    onTap: () => playing ? widget.session.pause() : widget.session.play(),
                  );
                },
              ),
              const SizedBox(width: 16),
              _ControlButton(
                icon: Icons.forward_10,
                onTap: () async {
                  final pos = await widget.session.positionStream.first;
                  await widget.session.seek(pos + const Duration(seconds: 10));
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await widget.session.stop();
                await widget.session.disconnect();
                _popWithResult();
              },
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
              label: const Text('Stop & Disconnect', style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  String _stateLabel(SessionState state) {
    switch (state) {
      case SessionState.playing:
        return 'Playing';
      case SessionState.paused:
        return 'Paused';
      case SessionState.buffering:
        return 'Buffering...';
      case SessionState.loading:
        return 'Loading...';
      case SessionState.connecting:
        return 'Connecting...';
      case SessionState.connected:
        return 'Connected';
      case SessionState.disconnected:
        return 'Disconnected';
      case SessionState.idle:
        return 'Ready';
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: size),
    );
  }
}
