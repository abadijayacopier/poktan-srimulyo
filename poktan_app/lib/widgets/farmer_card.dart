import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/farmer.dart';

class FarmerCard extends StatefulWidget {
  final Farmer farmer;
  final VoidCallback onTap;

  const FarmerCard({
    super.key,
    required this.farmer,
    required this.onTap,
  });

  @override
  State<FarmerCard> createState() => _FarmerCardState();
}

class _FarmerCardState extends State<FarmerCard> {
  bool _showFullNik = false;

  Color _getStatusBg(String status) {
    final s = status.toUpperCase();
    if (s.contains('SUDAH')) return GojekColors.primarySoft;
    if (s.contains('BELUM')) return GojekColors.orangeSoft;
    if (s.contains('KUASA')) return GojekColors.purpleSoft;
    return GojekColors.blueSoft;
  }

  Color _getStatusText(String status) {
    final s = status.toUpperCase();
    if (s.contains('SUDAH')) return GojekColors.primaryDark;
    if (s.contains('BELUM')) return GojekColors.orange;
    if (s.contains('KUASA')) return GojekColors.purple;
    return GojekColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.farmer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GojekColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: No, Name, Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (f.no.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        margin: const EdgeInsets.only(right: 8, top: 1),
                        decoration: BoxDecoration(
                          color: GojekColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: GojekColors.border),
                        ),
                        child: Text(
                          '#${f.no}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: GojekColors.textSecondary,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.nama,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: GojekColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showFullNik = !_showFullNik;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  _showFullNik ? f.nik : f.maskedNik,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: GojekColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _showFullNik ? Icons.visibility_off : Icons.visibility,
                                  size: 13,
                                  color: GojekColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusBg(f.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        f.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _getStatusText(f.status),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Container(height: 1, color: GojekColors.divider),
                const SizedBox(height: 12),

                // Fertilizer Allocation Badges
                Row(
                  children: [
                    Expanded(
                      child: _buildFertilizerBadge(
                        title: 'Urea',
                        sak: f.ureaSak,
                        kg: f.urea,
                        color: Colors.green.shade700,
                        bgColor: Colors.green.shade50,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFertilizerBadge(
                        title: 'NPK',
                        sak: f.npkSak,
                        kg: f.npk,
                        color: Colors.orange.shade800,
                        bgColor: Colors.orange.shade50,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFertilizerBadge(
                        title: 'Organik',
                        sak: f.organikSak,
                        kg: f.organik,
                        color: Colors.brown.shade700,
                        bgColor: Colors.brown.shade50,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bottom details: Lahan, Uang, Detail Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.landscape, size: 14, color: GojekColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Lahan: ${f.effectiveLahan} Ha',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: GojekColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (f.uang.isNotEmpty)
                      Text(
                        f.uang,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: GojekColors.primaryDark,
                        ),
                      ),
                    const Row(
                      children: [
                        Text(
                          'Rincian',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GojekColors.primary,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16, color: GojekColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFertilizerBadge({
    required String title,
    required String sak,
    required String kg,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$sak Sak ($kg kg)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
