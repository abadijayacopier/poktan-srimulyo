import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../models/farmer.dart';
import '../services/data_service.dart';
import '../widgets/farmer_card.dart';
import '../widgets/gojek_search_bar.dart';

class CekPetaniScreen extends StatefulWidget {
  final String? initialQuery;

  const CekPetaniScreen({super.key, this.initialQuery});

  @override
  State<CekPetaniScreen> createState() => _CekPetaniScreenState();
}

class _CekPetaniScreenState extends State<CekPetaniScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DataService _dataService = DataService();

  String _selectedFilter = 'SEMUA';
  List<Farmer> _filteredFarmers = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _filteredFarmers = _dataService.search(
        _searchController.text,
        statusFilter: _selectedFilter,
      );
    });
  }

  void _showDetailBottomSheet(Farmer farmer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GojekColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: GojekColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person, color: GojekColors.primaryDark, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: GojekColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NIK: ${farmer.nik}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: GojekColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20, color: GojekColors.primary),
                    tooltip: 'Salin NIK',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: farmer.nik));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('NIK ${farmer.nama} berhasil disalin!'),
                          backgroundColor: GojekColors.primaryDark,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: GojekColors.divider),
              const SizedBox(height: 14),

              // Rincian Alokasi Pupuk
              const Text(
                'Alokasi Pupuk Subsidi MT3 2026',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GojekColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailBox(
                      title: 'Urea (50kg)',
                      sak: farmer.ureaSak,
                      kg: farmer.urea,
                      color: Colors.green.shade800,
                      bg: Colors.green.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailBox(
                      title: 'NPK Phonska',
                      sak: farmer.npkSak,
                      kg: farmer.npk,
                      color: Colors.orange.shade800,
                      bg: Colors.orange.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailBox(
                      title: 'Petroganik',
                      sak: farmer.organikSak,
                      kg: farmer.organik,
                      color: Colors.brown.shade800,
                      bg: Colors.brown.shade50,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Detail Informasi Tambahan
              _buildInfoRow('Luas Lahan e-RDKK', '${farmer.lahan} Ha'),
              if (farmer.revisi.isNotEmpty)
                _buildInfoRow('Luas Revisi', '${farmer.revisi} Ha'),
              _buildInfoRow('Status Verifikasi', farmer.status),
              if (farmer.uang.isNotEmpty)
                _buildInfoRow('Nominal Pembayaran', farmer.uang),
              if (farmer.ket.isNotEmpty)
                _buildInfoRow('Catatan Khusus', farmer.ket),
              _buildInfoRow('Kelompok Tani', 'Poktan Sri Mulyo, Ds. Kediren'),

              const SizedBox(height: 20),

              // Tombol Tindakan
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
                      label: const Text('Salin Data', style: TextStyle(color: GojekColors.primary, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        final text = 'Data Petani Poktan Sri Mulyo:\nNama: ${farmer.nama}\nNIK: ${farmer.nik}\nUrea: ${farmer.ureaSak} Sak (${farmer.urea} kg)\nNPK: ${farmer.npkSak} Sak (${farmer.npk} kg)\nOrganik: ${farmer.organikSak} Sak (${farmer.organik} kg)\nStatus: ${farmer.status}';
                        Clipboard.setData(ClipboardData(text: text));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rincian petani berhasil disalin!'),
                            backgroundColor: GojekColors.primaryDark,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GojekColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat, size: 18, color: Colors.white),
                      label: const Text('Hubungi WA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showWaConfirmation(farmer);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWaConfirmation(Farmer farmer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.chat, color: Color(0xFF25D366)),
            SizedBox(width: 8),
            Text('Konfirmasi WhatsApp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hubungi Pengurus Poktan Sri Mulyo (0856-5562-0979) via WhatsApp untuk penebusan pupuk:',
              style: TextStyle(fontSize: 13, color: GojekColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GojekColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GojekColors.border),
              ),
              child: Text(
                'Halo Pengurus Poktan Sri Mulyo, saya ingin konfirmasi alokasi pupuk atas nama ${farmer.nama} (NIK: ${farmer.nik}). Mohon info jadwal pengambilan.',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: GojekColors.textPrimary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: GojekColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final text = 'Halo Pengurus Poktan Sri Mulyo, saya ingin konfirmasi alokasi pupuk atas nama ${farmer.nama} (NIK: ${farmer.nik}).';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesan WA telah disalin! Silakan kirim ke 0856-5562-0979'),
                  backgroundColor: Color(0xFF25D366),
                ),
              );
            },
            child: const Text('Salin Pesan WA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBox({
    required String title,
    required String sak,
    required String kg,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text('$sak Sak', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
          Text('$kg kg', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: GojekColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GojekColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoTani · Cek Kuota Pupuk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: GojekColors.primary),
            tooltip: 'Sinkronkan Google Sheets',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                const SnackBar(content: Text('Menghubungkan ke Google Sheets...'), duration: Duration(seconds: 1)),
              );
              final ok = await _dataService.syncOnline();
              if (mounted) {
                _applyFilter();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Sinkronisasi berhasil!' : 'Mode offline aktif (menggunakan data lokal)'),
                    backgroundColor: ok ? GojekColors.primaryDark : GojekColors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                GojekSearchBar(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  onClear: () => _applyFilter(),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('SEMUA', 'Semua (${_dataService.farmers.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('SUDAH', 'Sudah Ambil'),
                      const SizedBox(width: 8),
                      _buildFilterChip('BELUM', 'Belum Ambil'),
                      const SizedBox(width: 8),
                      _buildFilterChip('KTP', 'Setor KTP'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Total Count Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredFarmers.length} Petani Terdata',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: GojekColors.textSecondary,
                  ),
                ),
                Text(
                  _dataService.syncSource,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: GojekColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),

          // List of Farmers
          Expanded(
            child: _filteredFarmers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Petani tidak ditemukan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: GojekColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pastikan NIK atau Nama dieja dengan benar',
                          style: TextStyle(fontSize: 12, color: GojekColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _filteredFarmers.length,
                    itemBuilder: (ctx, idx) {
                      final farmer = _filteredFarmers[idx];
                      return FarmerCard(
                        farmer: farmer,
                        onTap: () => _showDetailBottomSheet(farmer),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
          _applyFilter();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? GojekColors.primary : GojekColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? GojekColors.primary : GojekColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : GojekColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
