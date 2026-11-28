import 'package:flutter/material.dart';
import '../constants/theme.dart';

class GojekWalletCard extends StatelessWidget {
  final int totalPetani;
  final double persenPenyaluran;
  final VoidCallback onCekKuota;
  final VoidCallback onStokPupuk;
  final VoidCallback onKloter;
  final VoidCallback onSuratKuasa;

  const GojekWalletCard({
    super.key,
    required this.totalPetani,
    required this.persenPenyaluran,
    required this.onCekKuota,
    required this.onStokPupuk,
    required this.onKloter,
    required this.onSuratKuasa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF006C7A), // Gojek GoPay Deep Blue/Teal
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006C7A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Info Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Kantong Tani',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: GojekColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MT3 2026',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalPetani Petani Terdata · Realisasi ${persenPenyaluran.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.lightGreenAccent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Resmi e-RDKK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider inside card
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),

          // 4 Action Buttons in GoPay Style
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  icon: Icons.search,
                  label: 'Cek Kuota',
                  badgeColor: Colors.white,
                  iconColor: const Color(0xFF006C7A),
                  onTap: onCekKuota,
                ),
                _buildActionItem(
                  icon: Icons.inventory_2,
                  label: 'Stok Pupuk',
                  badgeColor: Colors.white,
                  iconColor: const Color(0xFF006C7A),
                  onTap: onStokPupuk,
                ),
                _buildActionItem(
                  icon: Icons.groups,
                  label: 'Kloter',
                  badgeColor: Colors.white,
                  iconColor: const Color(0xFF006C7A),
                  onTap: onKloter,
                ),
                _buildActionItem(
                  icon: Icons.description,
                  label: 'Kuasa Tani',
                  badgeColor: Colors.white,
                  iconColor: const Color(0xFF006C7A),
                  onTap: onSuratKuasa,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color badgeColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
