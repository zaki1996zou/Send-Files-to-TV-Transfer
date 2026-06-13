import 'package:flutter/material.dart';
import '../models/sharing_method.dart';
import '../theme/app_colors.dart';
import 'info_badge.dart';

class MethodCard extends StatelessWidget {
  const MethodCard({
    super.key,
    required this.method,
    required this.onTap,
    this.onInfoTap,
  });

  final SharingMethod method;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gradientBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(method.icon, color: AppColors.gradientBlue, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        method.type,
                        style: const TextStyle(
                          color: AppColors.accentTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onInfoTap != null)
                  GestureDetector(
                    onTap: onInfoTap,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              method.shortDescription,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                InfoBadge(
                  icon: Icons.access_time,
                  label: method.duration,
                  color: AppColors.accentOrange,
                ),
                InfoBadge(
                  icon: Icons.check_circle_outline,
                  label: method.difficulty,
                  color: AppColors.accentGreen,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: method.fileTypes.map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
