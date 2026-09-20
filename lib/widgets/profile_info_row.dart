import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isFemale;

  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isFemale = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isFemale ? AppColors.femaleAccent : AppColors.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isFemale ? const Color(0xFFE63946).withValues(alpha: 0.12) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}