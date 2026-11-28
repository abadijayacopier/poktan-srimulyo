import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../models/kloter.dart';
import '../services/data_service.dart';
import '../widgets/farmer_card.dart';

class KloterScreen extends StatefulWidget {
  const KloterScreen({super.key});

  @override
  State<KloterScreen> createState() => _KloterScreenState();
}

class _KloterScreenState extends State<KloterScreen> {
  final DataService _dataService = DataService();
  int _selectedKloterIndex = 0;

  void _showSuratKuasaModal(KloterGroup kloter) {
    int totalUrea = 0;
    int totalNpk = 0;
    int totalOrg = 0;

    for (final f in kloter.members) {
      totalUrea += int.tryParse(f.ureaSak) ?? 0;
      totalNpk += int.tryParse(f.npkSak) ?? 0;
      totalOrg += int.tryParse(f.organikSak) ?? 0;
    }

    final draft = '''SURAT KUASA PENEBUSAN PUPUK BERSUBSIDI
KELOMPOK TANI "SRI MULYO" DESA KEDIREN
FORMAT RESMI F4 - ${kloter.nama.toUpperCase()} (MT3 2026)
===================================================

PENERIMA KUASA:
Nama Lengkap : SUPRIYANTO
NIK          : 3520033010900002
Kelompok     : POKTAN SRI MULYO
Alamat       : DSN SELUNGGUH RT 006 RW 001 DESA KEDIREN, KEC. LEMBEYAN, KAB. MAGETAN

PEMBERI KUASA (${kloter.members.length} Petani Anggota ${kloter.nama}):
${kloter.members.asMap().entries.map((e) => '${e.key + 1}. ${e.value.nama} (NIK: ${e.value.nik}) - Urea: ${e.value.ureaSak} Sak, NPK: ${e.value.npkSak} Sak').join('\n')}

---------------------------------------------------
TOTAL ALOKASI ${kloter.nama.toUpperCase()}:
• Total Urea    : $totalUrea Sak
• Total NPK     : $totalNpk Sak
• Total Organik : $totalOrg Sak
• Total Sak     : ${totalUrea + totalNpk + totalOrg} Sak
===================================================
Titik Serah : Kios Resmi Poktan Sri Mulyo, Kediren
Tanggal     : ${kloter.tanggal}''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: GojekColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Surat Kuasa ${kloter.nama}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GojekColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GojekColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    draft,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: GojekColors.textPrimary, height: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: GojekColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.copy, size: 18, color: GojekColors.primary),
                    label: const Text('Salin Teks', style: TextStyle(color: GojekColors.primary, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: draft));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Surat kuasa kloter berhasil disalin!'), backgroundColor: GojekColors.primaryDark),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.chat, size: 18, color: Colors.white),
                    label: const Text('Bagikan WA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: draft));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Teks siap dibagikan ke grup WhatsApp Kloter!'), backgroundColor: Color(0xFF25D366)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kloters = _dataService.getKloters();
    final activeKloter = kloters.isNotEmpty && _selectedKloterIndex < kloters.length
        ? kloters[_selectedKloterIndex]
        : null;

    int totalUrea = 0;
    int totalNpk = 0;
    int totalOrg = 0;
    if (activeKloter != null) {
      for (final f in activeKloter.members) {
        totalUrea += int.tryParse(f.ureaSak) ?? 0;
        totalNpk += int.tryParse(f.npkSak) ?? 0;
        totalOrg += int.tryParse(f.organikSak) ?? 0;
      }
    }

    return Scaffold(
      backgroundColor: GojekColors.background,
      appBar: AppBar(
        title: const Text('GoKloter · Jadwal & Surat Kuasa F4'),
      ),
      body: Column(
        children: [
          // Horizontal Kloter Selector Chips (Kloter 1 s/d 10)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(kloters.length, (idx) {
                  final k = kloters[idx];
                  final isSelected = _selectedKloterIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(k.nama),
                      selected: isSelected,
                      selectedColor: GojekColors.primary,
                      backgroundColor: GojekColors.background,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : GojekColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? GojekColors.primary : GojekColors.border,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedKloterIndex = idx;
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          // Kloter Header Info Card
          if (activeKloter != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: GojekColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.groups, color: GojekColors.primaryDark, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            activeKloter.nama,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GojekColors.textPrimary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: activeKloter.totalBelumAmbil == 0 ? GojekColors.primarySoft : GojekColors.orangeSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activeKloter.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: activeKloter.totalBelumAmbil == 0 ? GojekColors.primaryDark : GojekColors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Penerima Kuasa Info (Sesuai cetak-kloter.html)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: GojekColors.background, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: GojekColors.primary),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Penerima Kuasa Resmi: SUPRIYANTO (Ketua/Pengurus)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 13, color: GojekColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Jadwal: ${activeKloter.tanggal}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GojekColors.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Container(height: 1, color: GojekColors.divider),
                  const SizedBox(height: 8),

                  // Kuota Sak Kloter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildKloterQuota('Petani', '${activeKloter.totalPetani}'),
                      _buildKloterQuota('Urea', '$totalUrea Sak'),
                      _buildKloterQuota('NPK', '$totalNpk Sak'),
                      _buildKloterQuota('Organik', '$totalOrg Sak'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tombol Lihat Surat Kuasa F4
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GojekColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.description, size: 16),
                      label: Text('Format Surat Kuasa ${activeKloter.nama} (F4)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      onPressed: () => _showSuratKuasaModal(activeKloter),
                    ),
                  ),
                ],
              ),
            ),

          // Member List of active Kloter
          Expanded(
            child: activeKloter == null || activeKloter.members.isEmpty
                ? const Center(
                    child: Text('Tidak ada data anggota di kloter ini', style: TextStyle(color: GojekColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: activeKloter.members.length,
                    itemBuilder: (ctx, idx) {
                      final farmer = activeKloter.members[idx];
                      return FarmerCard(
                        farmer: farmer,
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKloterQuota(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: GojekColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GojekColors.primaryDark)),
      ],
    );
  }
}
