import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../services/data_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final DataService _dataService = DataService();
  bool _isSyncing = false;

  void _syncData() async {
    setState(() => _isSyncing = true);
    final ok = await _dataService.syncOnline();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Data Google Sheets berhasil diperbarui!' : 'Gagal terhubung, mode offline tetap aktif.'),
          backgroundColor: ok ? GojekColors.primaryDark : GojekColors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Poktan & Bantuan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profil Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GojekColors.border),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: GojekColors.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: GojekColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.agriculture, color: GojekColors.primaryDark, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kelompok Tani "Sri Mulyo"',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GojekColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Desa Kediren, Kec. Lembeyan, Kab. Magetan, Jawa Timur',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: GojekColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GojekColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Program Pupuk Bersubsidi MT3 2026',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GojekColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pengurus & Kontak WA
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
                const Text('Pengurus & Layanan Bantuan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _buildContactTile(
                  icon: Icons.person,
                  title: 'Ketua Poktan Sri Mulyo',
                  subtitle: 'Desa Kediren, Lembeyan',
                ),
                const SizedBox(height: 8),
                _buildContactTile(
                  icon: Icons.chat,
                  title: 'WhatsApp Center Pengurus',
                  subtitle: '0856-5562-0979 (Klik untuk salin)',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: '085655620979'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor WA 0856-5562-0979 disalin!'),
                        backgroundColor: Color(0xFF25D366),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildContactTile(
                  icon: Icons.business,
                  title: 'PPL BPP Kec. Lembeyan',
                  subtitle: 'Balai Penyuluhan Pertanian Kab. Magetan',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sinkronisasi & Status Sistem
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
                const Text('Sinkronisasi Data Spreadsheet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  'Sumber Data: ${_dataService.syncSource}',
                  style: const TextStyle(fontSize: 12, color: GojekColors.textSecondary),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GojekColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: _isSyncing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.sync, color: Colors.white),
                    label: Text(
                      _isSyncing ? 'Sedang Menyinkronkan...' : 'Sinkronkan Google Sheets Sekarang',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    onPressed: _isSyncing ? null : _syncData,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info Aplikasi
          const Center(
            child: Column(
              children: [
                Text(
                  'Poktan Sri Mulyo Mobile v1.0.0 (Gojek Green Edition)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.textMuted),
                ),
                SizedBox(height: 2),
                Text(
                  'Dikembangkan untuk Kemudahan Petani Desa Kediren',
                  style: TextStyle(fontSize: 10, color: GojekColors.textMuted),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = GojekColors.primary,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: GojekColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GojekColors.textPrimary)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 18, color: GojekColors.textMuted),
          ],
        ),
      ),
    );
  }
}
