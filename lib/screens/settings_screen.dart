import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';
import 'legal_document_screen.dart';
import 'transfer_guide_screen.dart';
import 'troubleshooting_screen.dart';

const _privacyPolicyUrl = 'https://sites.google.com/view/send-files-to-tv-transfer/home';
const _supportUrl = 'https://sites.google.com/view/send-files-to-tv-transfer1/home';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    _settingsService.loadSettings();
  }

  void _showSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  Future<void> _openUrl(String url, {String? fallbackMessage}) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackMessage ?? 'Link could not be opened'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackMessage ?? 'Link could not be opened'),
          ),
        );
      }
    }
  }

  void _showInfoDialog({
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyNotes() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('App Privacy Notes', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrivacyBullet('Files are selected by you — nothing is uploaded automatically.'),
              _PrivacyBullet('Transfer history is stored locally on your device.'),
              _PrivacyBullet('Device discovery runs on your local Wi-Fi network.'),
              _PrivacyBullet('The network speed test contacts the configured test URL.'),
              _PrivacyBullet('No account or sign-in is required.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildSection(
              title: 'Transfer Preferences',
              children: [
                _ToggleRow(
                  icon: Icons.movie_creation_outlined,
                  label: 'Prefer MP4 for casting',
                  subtitle: 'Shows MP4 recommendations on cast screens',
                  value: _settingsService.settings.preferMp4ForCasting,
                  onChanged: (value) async {
                    await _settingsService.updatePreferMp4ForCasting(value);
                    setState(() {});
                    _showSavedSnackBar();
                  },
                ),
                _ToggleRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'Show compatibility warning before transfer',
                  subtitle: 'Warn before unsupported or partial methods',
                  value: _settingsService.settings.showCompatibilityWarning,
                  onChanged: (value) async {
                    await _settingsService.updateShowCompatibilityWarning(value);
                    setState(() {});
                    _showSavedSnackBar();
                  },
                ),
                _ToggleRow(
                  icon: Icons.history,
                  label: 'Save transfer history',
                  subtitle: 'Store recent transfers on this device',
                  value: _settingsService.settings.saveTransferHistory,
                  onChanged: (value) async {
                    await _settingsService.updateSaveTransferHistory(value);
                    setState(() {});
                    _showSavedSnackBar();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Privacy & Permissions',
              children: [
                _ActionRow(
                  icon: Icons.wifi_tethering,
                  label: 'Local Network Permission',
                  onTap: () => _showInfoDialog(
                    title: 'Local Network Permission',
                    message:
                        'Local network access is used to discover supported Chromecast, DLNA, and AirPlay devices on your Wi-Fi network.',
                  ),
                ),
                _ActionRow(
                  icon: Icons.folder_open,
                  label: 'Photos & Files Access',
                  onTap: () => _showInfoDialog(
                    title: 'Photos & Files Access',
                    message:
                        'File access is used only when you choose a file. Files stay on your device unless you share or cast them.',
                  ),
                ),
                _ActionRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        type: LegalDocumentType.privacyPolicy,
                      ),
                    ),
                  ),
                ),
                _ActionRow(
                  icon: Icons.language,
                  label: 'Privacy Policy (Online)',
                  subtitle: 'Opens web version in browser',
                  onTap: () => _openUrl(
                    _privacyPolicyUrl,
                    fallbackMessage: 'Privacy page could not be opened.',
                  ),
                ),
                _ActionRow(
                  icon: Icons.shield_outlined,
                  label: 'App Privacy Notes',
                  onTap: _showPrivacyNotes,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Support',
              children: [
                _ActionRow(
                  icon: Icons.menu_book_outlined,
                  label: 'How to Transfer Files',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferGuideScreen()),
                  ),
                ),
                _ActionRow(
                  icon: Icons.build_circle_outlined,
                  label: 'Troubleshooting',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TroubleshootingScreen()),
                  ),
                ),
                _ActionRow(
                  icon: Icons.mail_outline,
                  label: 'Contact Support',
                  subtitle: 'Opens support page in browser',
                  onTap: () => _openUrl(
                    _supportUrl,
                    fallbackMessage: 'Support page could not be opened.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Legal',
              children: [
                _ActionRow(
                  icon: Icons.description_outlined,
                  label: 'Terms of Use',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        type: LegalDocumentType.termsOfUse,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.gradientCyan,
            activeTrackColor: AppColors.gradientBlue.withValues(alpha: 0.5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: _SettingsTile(
          icon: icon,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.child,
  });

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.gradientBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.gradientCyan, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  const _PrivacyBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.gradientCyan)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
