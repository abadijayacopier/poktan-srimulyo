import 'package:flutter/material.dart';
import '../constants/theme.dart';

class PanduanTaniScreen extends StatelessWidget {
  const PanduanTaniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoPanduan · Kalender & Solusi Hama'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Musim Tanam
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00AA13), Color(0xFF005A0A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Kalender Musim Tanam 2026',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• MT1 (Rendeng): Okt - Feb (Padi Sawah Utama)\n'
                  '• MT2 (Gadu 1): Mar - Jun (Padi Musim Kemarau I)\n'
                  '• MT3 (Gadu 2/Palawija): Jul - Okt (Jagung / Kedelai / Padi Lep)',
                  style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Ensiklopedia Pengendalian Hama & Penyakit',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
          ),
          const SizedBox(height: 12),

          _buildHamaCard(
            nama: 'Wereng Batang Coklat (WBC)',
            gejala: 'Daun menguning dari bawah, tanaman kering seperti terbakar (hopperburn).',
            solusi: 'Semprot insektisida berbahan aktif Pimetrozin atau Buprofezin di pangkal batang pagi hari. Keringkan sawah secara berkala.',
            bahayaLevel: 'Sangat Tinggi',
            color: Colors.red.shade700,
            icon: Icons.bug_report,
          ),
          const SizedBox(height: 10),

          _buildHamaCard(
            nama: 'Penggerek Batang (Sundep & Beluk)',
            gejala: 'Pucuk daun layu mati (Sundep pada fase anakan) atau malai tegak putih hampa (Beluk).',
            solusi: 'Aplikasi insektisida Dimehipo atau Klorantraniliprol. Buang telur ngengat di persemaian.',
            bahayaLevel: 'Tinggi',
            color: Colors.orange.shade800,
            icon: Icons.pest_control,
          ),
          const SizedBox(height: 10),

          _buildHamaCard(
            nama: 'Hawar Daun Bakteri (Kresek)',
            gejala: 'Bercak kuning keabu-abuan memanjang di tepi daun, daun layu mengeriting.',
            solusi: 'Gunakan bakterisida Tembaga Hidroksida (Kocide). Kurangi dosis pupuk Urea (Nitrogen) saat daun basah.',
            bahayaLevel: 'Sedang',
            color: Colors.amber.shade900,
            icon: Icons.coronavirus,
          ),
          const SizedBox(height: 10),

          _buildHamaCard(
            nama: 'Tikus Sawah (Rattus argentiventer)',
            gejala: 'Batang padi terpotong runcing miring 45°, serangan melingkar dari tengah petak.',
            solusi: 'Gropyokan massal saat awal olah tanah, pasang TBS (Trap Barrier System), gunakan rodentisida antikoagulan.',
            bahayaLevel: 'Tinggi',
            color: Colors.brown.shade700,
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: 10),

          _buildHamaCard(
            nama: 'Penyakit Blas (Pyricularia oryzae)',
            gejala: 'Bercak belah ketupat di daun (blas daun) dan leher malai patah membusuk (blas leher).',
            solusi: 'Gunakan fungisida Trisiklazol atau Difenokonazol. Jangan menanam terlalu rapat pada musim hujan.',
            bahayaLevel: 'Sedang',
            color: Colors.purple.shade700,
            icon: Icons.spa,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHamaCard({
    required String nama,
    required String gejala,
    required String solusi,
    required String bahayaLevel,
    required Color color,
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
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nama,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bahayaLevel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Gejala: $gejala',
            style: const TextStyle(fontSize: 12, color: GojekColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GojekColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 14, color: GojekColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    solusi,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GojekColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
