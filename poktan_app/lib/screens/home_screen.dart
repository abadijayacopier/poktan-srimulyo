import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/data_service.dart';
import '../widgets/farmer_card.dart';
import '../widgets/gojek_search_bar.dart';
import '../widgets/gojek_service_icon.dart';
import '../widgets/gojek_wallet_card.dart';
import 'cek_petani_screen.dart';
import 'kalkulator_lep_screen.dart';
import 'kloter_screen.dart';
import 'kuasa_penggarap_screen.dart';
import 'panduan_tani_screen.dart';
import 'pupuk_stok_screen.dart';
import 'tanya_tani_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final stats = _dataService.getStats();
    final totalPetani = stats['total'] as int? ?? 195;
    final persenPenyaluran = stats['persen'] as double? ?? 88.0;
    final recentFarmers = _dataService.farmers.take(4).toList();

    return Scaffold(
      backgroundColor: GojekColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: GojekColors.primary,
          onRefresh: () async {
            await _dataService.syncOnline();
            if (mounted) setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Gojek Header (Green Theme with Search & Location)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      // Location & Profile Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: GojekColors.primarySoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on, color: GojekColors.primaryDark, size: 16),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Poktan Sri Mulyo',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: GojekColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Desa Kediren, Lembeyan, Magetan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: GojekColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: GojekColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'SM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Gojek Search Bar
                      GojekSearchBar(
                        controller: _searchController,
                        hintText: 'Cari nama petani, NIK, atau pupuk...',
                        onChanged: (query) {
                          if (query.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CekPetaniScreen(initialQuery: query),
                              ),
                            );
                            _searchController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Gojek GoPay-style "Kantong Tani" Wallet Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GojekWalletCard(
                    totalPetani: totalPetani,
                    persenPenyaluran: persenPenyaluran,
                    onCekKuota: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CekPetaniScreen())),
                    onStokPupuk: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PupukStokScreen())),
                    onKloter: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KloterScreen())),
                    onSuratKuasa: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KuasaPenggarapScreen())),
                  ),
                ),

                const SizedBox(height: 18),

                // Gojek 8-Icon Grid Menu
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GojekColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Row 1 of 4 Services
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GojekServiceIcon(
                            title: 'GoTani',
                            icon: Icons.search,
                            backgroundColor: const Color(0xFF00AA13), // Gojek Green
                            badgeText: 'e-RDKK',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CekPetaniScreen())),
                          ),
                          GojekServiceIcon(
                            title: 'GoPupuk',
                            icon: Icons.inventory_2,
                            backgroundColor: const Color(0xFFFF6B00), // Gojek Orange
                            badgeText: '77 Sak',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PupukStokScreen())),
                          ),
                          GojekServiceIcon(
                            title: 'GoKloter',
                            icon: Icons.groups,
                            backgroundColor: const Color(0xFF0081A0), // Gojek Blue
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KloterScreen())),
                          ),
                          GojekServiceIcon(
                            title: 'GoKuasa',
                            icon: Icons.description,
                            backgroundColor: const Color(0xFF8E44AD), // Gojek Purple
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KuasaPenggarapScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Row 2 of 4 Services
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GojekServiceIcon(
                            title: 'GoLEP',
                            icon: Icons.calculate,
                            backgroundColor: const Color(0xFF00B0FF), // Cyan
                            badgeText: 'Dosis',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalkulatorLepScreen())),
                          ),
                          GojekServiceIcon(
                            title: 'GoPanduan',
                            icon: Icons.menu_book,
                            backgroundColor: const Color(0xFFFFB800), // Gojek Yellow
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PanduanTaniScreen())),
                          ),
                          GojekServiceIcon(
                            title: 'GoTanya',
                            icon: Icons.chat_bubble,
                            backgroundColor: const Color(0xFF009688), // Teal
                            badgeText: 'AI',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TanyaTaniScreen())),
                          ),
                          GojekServiceIcon(
                            title: 'GoLaporan',
                            icon: Icons.pie_chart,
                            backgroundColor: const Color(0xFFEE2737), // Gojek Red
                            onTap: () => _showLaporanModal(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Gojek Promo / Information Feed Cards ("Ada apa yang baru di Sri Mulyo?")
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Informasi Penting Petani',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GojekColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildPromoCard(
                        title: 'Penebusan Pupuk MT3 Dibuka',
                        desc: 'Bawa KTP Asli atau Surat Kuasa ke Kios Poktan Sri Mulyo.',
                        badge: 'Wajib KTP',
                        color: const Color(0xFF00AA13),
                        icon: Icons.verified_user,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CekPetaniScreen())),
                      ),
                      const SizedBox(width: 12),
                      _buildPromoCard(
                        title: 'Kalkulator LEP Sawah',
                        desc: 'Hitung dosis pupuk berimbang per petak sawah Ru / Bata.',
                        badge: '1 Ru = 14m²',
                        color: const Color(0xFF0081A0),
                        icon: Icons.calculate,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalkulatorLepScreen())),
                      ),
                      const SizedBox(width: 12),
                      _buildPromoCard(
                        title: 'Waspada Wereng Batang Coklat',
                        desc: 'Cek gejala awal dan SOP penyemprotan bahan aktif Buprofezin.',
                        badge: 'Pencegahan',
                        color: const Color(0xFFFF6B00),
                        icon: Icons.bug_report,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PanduanTaniScreen())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Daftar Petani Terdata (Preview)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Data Petani e-RDKK MT3',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GojekColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CekPetaniScreen())),
                        child: const Row(
                          children: [
                            Text('Lihat Semua', style: TextStyle(color: GojekColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                            Icon(Icons.chevron_right, size: 16, color: GojekColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 4 Recent Farmer Cards
                ...recentFarmers.map(
                  (f) => FarmerCard(
                    farmer: f,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CekPetaniScreen())),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLaporanModal() {
    final stats = _dataService.getStats();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GoLaporan · Ringkasan Penyaluran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Text('• Total Petani Terdata : ${stats['total']} Petani'),
            Text('• Sudah Menebus Pupuk : ${stats['sudah']} Petani (${(stats['persen'] as double).toStringAsFixed(1)}%)'),
            Text('• Belum Menebus       : ${stats['belum']} Petani'),
            Text('• Total Pupuk Urea     : ${stats['sakUrea']} Sak'),
            Text('• Total Pupuk NPK      : ${stats['sakNpk']} Sak'),
            Text('• Total Pupuk Organik  : ${stats['sakOrganik']} Sak'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: GojekColors.primary),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String desc,
    required String badge,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GojekColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
