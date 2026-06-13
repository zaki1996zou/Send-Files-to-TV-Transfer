import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ads_actions.dart';
import '../util/global.dart';
import '../data/methods_data.dart';
import '../models/sharing_method.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/method_card.dart';
import 'advanced_tools_screen.dart';
import 'file_transfer_tools_screen.dart';
import 'method_detail_screen.dart';
import 'settings_screen.dart';
import 'tools/transfer_history_screen.dart';
import 'transfer/transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SharingMethod> get _filteredMethods {
    if (_searchQuery.isEmpty) return sharingMethods;
    final query = _searchQuery.toLowerCase();
    return sharingMethods.where((method) {
      return method.name.toLowerCase().contains(query) ||
          method.type.toLowerCase().contains(query) ||
          method.description.toLowerCase().contains(query) ||
          method.fileTypes.any((t) => t.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMethods;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Send Files to TV Transfer',
        titleFontSize: 15,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Transfer History',
            onPressed: () => AdsActions.pushRewarded(
              context,
              const TransferHistoryScreen(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () => AdsActions.pushInterstitial(
              context,
              const SettingsScreen(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildQuickTransferButton(context),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
            const SizedBox(height: 24),
            const Text(
              'File Sharing Methods',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${filtered.length} available methods',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No methods found',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final method = filtered[index];
                  return MethodCard(
                    method: method,
                    onTap: () => _openTransfer(context, method),
                    onInfoTap: () => _openMethodDetail(context, method),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tv, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Send Files to TV Transfer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Share and cast files using iOS-compatible options',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Choose files and share them using AirPlay, Chromecast, DLNA, and system sharing options. Availability depends on your TV, iPhone, and network.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Search methods, devices, or file types...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 22),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'File Transfer Tools',
            icon: Icons.build,
            color: AppColors.accentTeal,
            onTap: () => AdsActions.pushRewarded(
              context,
              const FileTransferToolsScreen(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Advanced Tools',
            icon: Icons.lightbulb_outline,
            color: AppColors.accentOrange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedToolsScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTransferButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMethodPicker(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.accentTeal,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentTeal.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Quick Transfer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMethodPicker(BuildContext homeContext) {
    hideBottomBanner.value = true;
    showModalBottomSheet<void>(
      context: homeContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sheetHeight = MediaQuery.sizeOf(ctx).height * 0.72;
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;

        return SizedBox(
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Choose Transfer Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: bottomInset + 16),
                  itemCount: sharingMethods.length,
                  itemBuilder: (sheetContext, index) {
                    final method = sharingMethods[index];
                    return ListTile(
                      leading: Icon(method.icon, color: AppColors.gradientCyan),
                      title: Text(
                        method.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        method.type,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openTransfer(homeContext, method);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => hideBottomBanner.value = false);
  }

  void _openTransfer(BuildContext context, SharingMethod method) {
    AdsActions.pushRewarded(
      context,
      TransferScreen(method: method),
    );
  }

  void _openMethodDetail(BuildContext context, SharingMethod method) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MethodDetailScreen(method: method)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
