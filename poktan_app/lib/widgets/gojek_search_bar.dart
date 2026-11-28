import 'package:flutter/material.dart';
import '../constants/theme.dart';

class GojekSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final String hintText;

  const GojekSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.hintText = 'Cari nama petani, NIK, atau kloter...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: GojekColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: GojekColors.textSecondary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                color: GojekColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: GojekColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cancel, size: 18, color: GojekColors.textMuted),
              onPressed: () {
                controller.clear();
                if (onClear != null) onClear!();
                if (onChanged != null) onChanged!('');
              },
            ),
          if (onFilterTap != null) ...[
            Container(
              height: 20,
              width: 1,
              color: GojekColors.divider,
            ),
            IconButton(
              icon: const Icon(Icons.tune, size: 20, color: GojekColors.primary),
              onPressed: onFilterTap,
            ),
          ] else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
