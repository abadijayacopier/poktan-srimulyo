import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../models/farmer.dart';
import '../services/data_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final DataService _dataService = DataService();

  String _filterStatus = 'SEMUA';
  String _filterKloter = 'SEMUA';
  final TextEditingController _searchController = TextEditingController();

  List<Farmer> get _filteredList {
    final farmers = _dataService.farmers;
    final query = _searchController.text.trim().toLowerCase();

    return farmers.where((f) {
      if (query.isNotEmpty) {
        final matches = f.nama.toLowerCase().contains(query) || f.nik.contains(query);
        if (!matches) return false;
      }

      // Filter Status
      if (_filterStatus == 'SUDAH' && !f.isSudahAmbil) return false;
      if (_filterStatus == 'BELUM' && !f.isBelumAmbil) return false;
      if (_filterStatus == 'KTP' && !f.hasSetorKtp) return false;
      if (_filterStatus == 'KUASA' && !f.hasSuratKuasa) return false;

      // Filter Kloter (per 20 petani)
      if (_filterKloter != 'SEMUA') {
        final noIdx = int.tryParse(f.no) ?? 1;
        final kloterNum = ((noIdx - 1) ~/ 20) + 1;
        if ('Kloter $kloterNum' != _filterKloter) return false;
      }

      return true;
    }).toList();
  }

  void _salinLaporan() {
    final list = _filteredList;
    int totalUrea = 0;
    int totalNpk = 0;
    int totalOrg = 0;
    double totalHa = 0.0;

    for (final f in list) {
      totalUrea += int.tryParse(f.ureaSak) ?? 0;
      totalNpk += int.tryParse(f.npkSak) ?? 0;
      totalOrg += int.tryParse(f.organikSak) ?? 0;
      totalHa += f.effectiveLahan;
    }

    final text = '''*LAPORAN RESMI PENYALURAN PUPUK BERSUBSIDI*
*POKTAN "SRI MULYO" DESA KEDIREN - MT3 2026*
===========================================
Filter Status   : $_filterStatus
Filter Kloter   : $_filterKloter
Jumlah Petani   : ${list.length} Petani
Total Luas Lahan: ${totalHa.toStringAsFixed(2)} Ha
-------------------------------------------
REKAPITULASI REALISASI PUPUK:
• Urea (50kg)   : $totalUrea Sak (${totalUrea * 50} kg)
• NPK Phonska   : $totalNpk Sak (${totalNpk * 50} kg)
• Petroganik    : $totalOrg Sak (${totalOrg * 40} kg)
• Total Seluruh : ${totalUrea + totalNpk + totalOrg} Sak
===========================================
Laporan dibuat otomatis via Sistem Mobile Poktan Sri Mulyo
Kecamatan Lembeyan, Kabupaten Magetan''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ringkasan laporan resmi berhasil disalin! Siap dikirim ke WhatsApp pengurus.'),
        backgroundColor: GojekColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;

    int totalUrea = 0;
    int totalNpk = 0;
    int totalOrg = 0;
    double totalHa = 0.0;

    for (final f in list) {
      totalUrea += int.tryParse(f.ureaSak) ?? 0;
      totalNpk += int.tryParse(f.npkSak) ?? 0;
      totalOrg += int.tryParse(f.organikSak) ?? 0;
      totalHa += f.effectiveLahan;
    }

    return Scaffold(
      backgroundColor: GojekColors.background,
      appBar: AppBar(
        title: const Text('GoLaporan · Dokumen Laporan Resmi'),
      ),
      body: Column(
        children: [
          // Header Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIK di laporan...',
                    prefixIcon: const Icon(Icons.search, color: GojekColors.primary, size: 20),
                    filled: true,
                    fillColor: GojekColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),

                // Filters Row
                Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: InputDecoration(
                          labelText: 'Status Kios',
                          filled: true,
                          fillColor: GojekColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GojekColors.border)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'SEMUA', child: Text('Semua Status', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'SUDAH', child: Text('Sudah Ambil', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'BELUM', child: Text('Belum Ambil', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'KTP', child: Text('Setor KTP', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'KUASA', child: Text('Surat Kuasa', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _filterStatus = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Kloter Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterKloter,
                        decoration: InputDecoration(
                          labelText: 'Kloter',
                          filled: true,
                          fillColor: GojekColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GojekColors.border)),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'SEMUA', child: Text('Semua Kloter', style: TextStyle(fontSize: 12))),
                          ...List.generate(10, (i) => DropdownMenuItem(value: 'Kloter ${i + 1}', child: Text('Kloter ${i + 1}', style: const TextStyle(fontSize: 12)))),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _filterKloter = v);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ringkasan Statistik Laporan Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GojekColors.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hasil Filter: ${list.length} Petani Terpilih', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GojekColors.textPrimary)),
                    Text('Lahan: ${totalHa.toStringAsFixed(2)} Ha', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GojekColors.primaryDark)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: GojekColors.divider),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Urea', '$totalUrea Sak', Colors.green),
                    _buildStatCol('NPK', '$totalNpk Sak', Colors.orange),
                    _buildStatCol('Organik', '$totalOrg Sak', Colors.brown),
                    _buildStatCol('Total Sak', '${totalUrea + totalNpk + totalOrg} Sak', GojekColors.primaryDark),
                  ],
                ),

                const SizedBox(height: 12),

                // Button Salin Laporan
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GojekColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Salin Ringkasan Laporan WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    onPressed: _salinLaporan,
                  ),
                ),
              ],
            ),
          ),

          // Daftar Petani Terfilter
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Tidak ada data petani yang sesuai filter', style: TextStyle(color: GojekColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final f = list[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: GojekColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: GojekColors.primarySoft,
                              radius: 18,
                              child: Text(f.no, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GojekColors.primaryDark)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.nama, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GojekColors.textPrimary)),
                                  Text('NIK: ${f.maskedNik} • Lahan: ${f.effectiveLahan} Ha', style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text('Alokasi: ${f.ureaSak} Urea • ${f.npkSak} NPK • ${f.organikSak} Org (${f.totalSak} Sak)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.primaryDark)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: f.isSudahAmbil ? GojekColors.primarySoft : GojekColors.orangeSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                f.status.contains('SUDAH') ? 'SUDAH' : 'BELUM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: f.isSudahAmbil ? GojekColors.primaryDark : GojekColors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: GojekColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
