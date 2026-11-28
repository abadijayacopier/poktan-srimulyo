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

import '../services/auth_service.dart';
import 'laporan_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final stats = _dataService.getStats();
    final totalPetani = stats['total'] as int? ?? 195;
    final persenPenyaluran = stats['persen'] as double? ?? 88.0;
    final recentFarmers = _dataService.farmers.take(4).toList();

    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        final isPetani = _authService.isPetani;
        final farmer = _authService.currentFarmer;

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
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/icon/app_icon.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: GojekColors.primary,
                                        child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'POKTAN SRI MULYO',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: GojekColors.textPrimary,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      Text(
                                        isPetani && farmer != null
                                            ? 'Halo, ${farmer.nama.split(' ').first}'
                                            : 'Desa Kediren, Lembeyan, Magetan',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isPetani ? FontWeight.w700 : FontWeight.w500,
                                          color: isPetani ? GojekColors.primaryDark : GojekColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  if (_authService.isLoggedIn) {
                                    widget.onTabChange(3); // Profil
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _authService.isLoggedIn ? GojekColors.primarySoft : GojekColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _authService.isLoggedIn ? GojekColors.primary : GojekColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _authService.isLoggedIn ? Icons.account_circle : Icons.login,
                                        size: 16,
                                        color: _authService.isLoggedIn ? GojekColors.primaryDark : GojekColors.textPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _authService.isLoggedIn ? 'Akun' : 'Masuk',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: _authService.isLoggedIn ? GojekColors.primaryDark : GojekColors.textPrimary,
                                        ),
                                      ),
                                    ],
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

                          // Personalized Farmer Banner
                          if (isPetani && farmer != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: GojekColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified, color: GojekColors.primaryDark, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Alokasi Pupuk: ${farmer.nama}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: GojekColors.textPrimary),
                                        ),
                                        Text(
                                          'Urea: ${farmer.urea} kg • NPK: ${farmer.npk} kg (${farmer.totalSak} Sak)',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.primaryDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: farmer.isSudahAmbil ? GojekColors.primary : GojekColors.orange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      farmer.status,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (!_authService.isLoggedIn) ...[
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: GojekColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: GojekColors.border),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.badge_outlined, color: GojekColors.primary, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Petani Anggota? Masuk untuk cek jatah pupuk Anda',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.textPrimary),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: GojekColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                            icon: Icons.water_drop,
                            backgroundColor: const Color(0xFF00B0FF), // Cyan
                            badgeText: 'Pompa',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalkulatorLepScreen())),
                          ),
                          GojekServiceIcon(
                            title: 'GoPanduan',
                            icon: Icons.menu_book,
                            backgroundColor: const Color(0xFFFFB800), // Gojek Yellow
                            badgeText: 'Dosis',
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
                            badgeText: 'Resmi',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanScreen())),
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
  },
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
