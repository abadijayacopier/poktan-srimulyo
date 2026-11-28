import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/data_service.dart';

class PupukStokScreen extends StatefulWidget {
  const PupukStokScreen({super.key});

  @override
  State<PupukStokScreen> createState() => _PupukStokScreenState();
}

class _PupukStokScreenState extends State<PupukStokScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final stats = _dataService.getStats();
    final totalPetani = stats['total'] as int? ?? 195;
    final sudahAmbil = stats['sudah'] as int? ?? 172;
    final belumAmbil = stats['belum'] as int? ?? 23;
    final persen = stats['persen'] as double? ?? 88.2;

    final sakUrea = stats['sakUrea'] as int? ?? 286;
    final sakNpk = stats['sakNpk'] as int? ?? 268;
    final sakOrganik = stats['sakOrganik'] as int? ?? 220;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoPupuk · Stok & Sisa Pupuk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Status Card (Gojek Green Gradient)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00AA13), Color(0xFF007A0E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: GojekColors.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Sisa Pupuk Cadangan',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Text(
                        'MT3 2026',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '77 SAK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total sisa cadangan fisik siap ditebus di Kios Poktan Sri Mulyo',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar Penyaluran
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Realisasi Penyaluran Pupuk',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${persen.toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (persen / 100).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3 Kartu Pupuk Subsidi
            const Text(
              'Rincian 3 Komoditas Pupuk Subsidi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildStokCard(
              title: 'Urea Bersubsidi (50 kg)',
              sisaSak: 28,
              tertebusSak: sakUrea,
              formula: '= 17 Sak Non-eRDKK + 11 Sak Fisik Petani',
              hetPrice: 'Rp 2.250 / kg (Rp 112.500 / Sak)',
              color: Colors.green.shade700,
              bgColor: Colors.green.shade50,
              icon: Icons.grain,
            ),
            const SizedBox(height: 10),

            _buildStokCard(
              title: 'NPK Phonska (50 kg)',
              sisaSak: 25,
              tertebusSak: sakNpk,
              formula: '= 15 Sak Non-eRDKK + 10 Sak Fisik Petani',
              hetPrice: 'Rp 2.300 / kg (Rp 115.000 / Sak)',
              color: Colors.orange.shade800,
              bgColor: Colors.orange.shade50,
              icon: Icons.eco,
            ),
            const SizedBox(height: 10),

            _buildStokCard(
              title: 'Petroganik Organik (40 kg)',
              sisaSak: 24,
              tertebusSak: sakOrganik,
              formula: '= 14 Sak Non-eRDKK + 10 Sak Fisik Petani',
              hetPrice: 'Rp 800 / kg (Rp 32.000 / Sak)',
              color: Colors.brown.shade700,
              bgColor: Colors.brown.shade50,
              icon: Icons.yard,
            ),

            const SizedBox(height: 20),

            // Rekap Petani Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GojekColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Rekapitulasi Petani MT3',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          'Total Petani',
                          '$totalPetani',
                          GojekColors.primary,
                        ),
                      ),
                      Container(width: 1, height: 40, color: GojekColors.divider),
                      Expanded(
                        child: _buildMiniStat(
                          'Sudah Ambil',
                          '$sudahAmbil',
                          Colors.green.shade700,
                        ),
                      ),
                      Container(width: 1, height: 40, color: GojekColors.divider),
                      Expanded(
                        child: _buildMiniStat(
                          'Belum Ambil',
                          '$belumAmbil',
                          GojekColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStokCard({
    required String title,
    required int sisaSak,
    required int tertebusSak,
    required String formula,
    required String hetPrice,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GojekColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sisaSak SAK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
                  ),
                  const Text(
                    'Sisa Cadangan',
                    style: TextStyle(fontSize: 10, color: GojekColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: GojekColors.divider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sudah Tertebus Petani:', style: TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
              Text('$tertebusSak Sak', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HET Resmi Pemerintah:', style: TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
              Text(hetPrice, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: GojekColors.background, borderRadius: BorderRadius.circular(6)),
            child: Text(
              'Formula: $formula',
              style: const TextStyle(fontSize: 10, color: GojekColors.textMuted, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
      ],
    );
  }
}
