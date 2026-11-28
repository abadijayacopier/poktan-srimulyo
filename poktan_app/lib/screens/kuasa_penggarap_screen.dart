import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../models/penggarap.dart';
import '../services/data_service.dart';

class KuasaPenggarapScreen extends StatefulWidget {
  const KuasaPenggarapScreen({super.key});

  @override
  State<KuasaPenggarapScreen> createState() => _KuasaPenggarapScreenState();
}

class _KuasaPenggarapScreenState extends State<KuasaPenggarapScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DataService _dataService = DataService();

  // Form Controllers untuk Surat Kuasa Baru
  final _namaPemilikController = TextEditingController();
  final _nikPemilikController = TextEditingController();
  final _alamatPemilikController = TextEditingController(text: 'Desa Kediren, Kec. Lembeyan');
  final _lahanController = TextEditingController(text: '0.25');

  final _namaPenggarapController = TextEditingController();
  final _nikPenggarapController = TextEditingController();
  final _alamatPenggarapController = TextEditingController(text: 'Desa Kediren, Kec. Lembeyan');
  final _hubunganController = TextEditingController(text: 'Penggarap Sawah');

  final _sakUreaController = TextEditingController(text: '1');
  final _sakNpkController = TextEditingController(text: '1');
  final _sakOrganikController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaPemilikController.dispose();
    _nikPemilikController.dispose();
    _alamatPemilikController.dispose();
    _lahanController.dispose();
    _namaPenggarapController.dispose();
    _nikPenggarapController.dispose();
    _alamatPenggarapController.dispose();
    _hubunganController.dispose();
    _sakUreaController.dispose();
    _sakNpkController.dispose();
    _sakOrganikController.dispose();
    super.dispose();
  }

  void _showSuratKuasaDialog(Penggarap p) {
    final text = '''SURAT KUASA PENGGARAP SAWAH
PENEBUSAN PUPUK BERSUBSIDI POKTAN "SRI MULYO"
DESA KEDIREN, KEC. LEMBEYAN, KAB. MAGETAN
MUSIM TANAM III (MT3) 2026 - FORMAT RESMI F4
============================================

PEMBERI KUASA (PEMILIK LAHAN):
Nama Lengkap : ${p.namaPemilik}
NIK KTP      : ${p.nikPemilik}
Alamat       : ${p.alamatPemilik}
Luas Lahan   : ${p.luasLahan} Ha

PENERIMA KUASA (PENGGARAP SAWAH):
Nama Lengkap : ${p.namaPenggarap}
NIK KTP      : ${p.nikPenggarap}
Alamat       : ${p.alamatPenggarap}
Hubungan     : ${p.statusGarap}

RINCIAN ALOKASI PUPUK DITEBUS:
• Urea (50kg)  : ${p.sakUrea} Sak (${p.ureaKg} kg)
• NPK Phonska  : ${p.sakPhonska} Sak (${p.phonskaKg} kg)
• Petroganik   : ${p.sakOrganik} Sak (${p.organikKg} kg)
Total Biaya    : ${p.totalBiaya.isNotEmpty ? p.totalBiaya : '-'}
Titik Serah    : Kios Poktan Sri Mulyo, Ds. Kediren

Dengan ini Pemilik Lahan memberikan kuasa penuh kepada Penggarap di atas untuk mengambil jatah pupuk bersubsidi resmi.

Kediren, ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}

Penerima Kuasa,                    Pemberi Kuasa (Materai Rp 10.000),

(${p.namaPenggarap})               (${p.namaPemilik})''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: GojekColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Surat Kuasa: ${p.namaPenggarap}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
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
                    text,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
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
                    label: const Text('Salin Format', style: TextStyle(color: GojekColors.primary, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Surat kuasa penggarap berhasil disalin!'), backgroundColor: GojekColors.primaryDark),
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
                    label: const Text('Kirim WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Teks siap dikirim ke WhatsApp penggarap!'), backgroundColor: Color(0xFF25D366)),
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

  void _generateCustomSurat() {
    final pem = _namaPemilikController.text.trim();
    final peng = _namaPenggarapController.text.trim();
    if (pem.isEmpty || peng.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi nama pemilik dan nama penggarap!'), backgroundColor: GojekColors.red),
      );
      return;
    }

    final p = Penggarap(
      no: 'NEW',
      nikPemilik: _nikPemilikController.text.trim(),
      namaPemilik: pem,
      alamatPemilik: _alamatPemilikController.text.trim(),
      luasLahan: _lahanController.text.trim(),
      nikPenggarap: _nikPenggarapController.text.trim(),
      namaPenggarap: peng,
      alamatPenggarap: _alamatPenggarapController.text.trim(),
      statusGarap: _hubunganController.text.trim(),
      ureaKg: '${(int.tryParse(_sakUreaController.text) ?? 1) * 50}',
      phonskaKg: '${(int.tryParse(_sakNpkController.text) ?? 1) * 50}',
      organikKg: '${(int.tryParse(_sakOrganikController.text) ?? 1) * 40}',
      sakUrea: _sakUreaController.text.trim(),
      sakPhonska: _sakNpkController.text.trim(),
      sakOrganik: _sakOrganikController.text.trim(),
      totalBiaya: '',
      statusPenebusan: 'BELUM AMBIL',
      statusBerkas: 'SURAT KUASA',
    );
    _showSuratKuasaDialog(p);
  }

  @override
  Widget build(BuildContext context) {
    final penggaraps = _dataService.penggaraps;

    return Scaffold(
      backgroundColor: GojekColors.background,
      appBar: AppBar(
        title: const Text('GoKuasa · Surat Kuasa Penggarap'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: GojekColors.primary,
          unselectedLabelColor: GojekColors.textSecondary,
          indicatorColor: GojekColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: [
            Tab(icon: const Icon(Icons.list_alt, size: 20), text: 'Data Penggarap (${penggaraps.length})'),
            const Tab(icon: Icon(Icons.edit_note, size: 20), text: 'Buat Surat Kuasa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Data Rekap Penggarap Resmi MT3 (Sesuai cetak-penggarap.html)
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: penggaraps.length,
            itemBuilder: (ctx, idx) {
              final p = penggaraps[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: GojekColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                          child: Text('No. ${p.no} • ${p.statusGarap}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GojekColors.primaryDark)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.statusPenebusan.contains('SUDAH') ? GojekColors.primarySoft : GojekColors.orangeSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.statusPenebusan,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: p.statusPenebusan.contains('SUDAH') ? GojekColors.primaryDark : GojekColors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Relasi Kuasa Pemilik -> Penggarap
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pemilik Lahan', style: TextStyle(fontSize: 10, color: GojekColors.textSecondary)),
                              Text(p.namaPemilik, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GojekColors.textPrimary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: GojekColors.primary, size: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Penerima Kuasa / Penggarap', style: TextStyle(fontSize: 10, color: GojekColors.textSecondary)),
                              Text(p.namaPenggarap, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GojekColors.primaryDark)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 20, color: GojekColors.border),

                    // Rincian Sak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jatah: ${p.sakUrea} Urea • ${p.sakPhonska} NPK • ${p.sakOrganik} Organik (${p.totalSak} Sak)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        Text(p.totalBiaya.isNotEmpty ? p.totalBiaya : '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GojekColors.primaryDark)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GojekColors.primaryDark,
                          side: const BorderSide(color: GojekColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text('Buka Format Surat Kuasa F4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        onPressed: () => _showSuratKuasaDialog(p),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab 2: Buat Surat Kuasa Baru
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box Syarat
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GojekColors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GojekColors.blue.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: GojekColors.blueDark, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sesuai SOP Poktan Sri Mulyo: Surat Kuasa Penggarap wajib bermaterai Rp 10.000 dan melampirkan FC KTP Pemilik Lahan saat penebusan di kios.',
                          style: TextStyle(fontSize: 11, color: GojekColors.blueDark, height: 1.3, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Form Pemberi Kuasa (Pemilik)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: GojekColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. Data Pemilik Lahan (Pemberi Kuasa)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      TextField(controller: _namaPemilikController, decoration: _deco('Nama Lengkap Pemilik Sesuai KTP')),
                      const SizedBox(height: 8),
                      TextField(controller: _nikPemilikController, keyboardType: TextInputType.number, decoration: _deco('NIK Pemilik Lahan (16 digit)')),
                      const SizedBox(height: 8),
                      TextField(controller: _alamatPemilikController, decoration: _deco('Alamat / RT RW Pemilik')),
                      const SizedBox(height: 8),
                      TextField(controller: _lahanController, keyboardType: TextInputType.number, decoration: _deco('Luas Lahan (Ha)')),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Form Penerima Kuasa (Penggarap)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: GojekColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('2. Data Petani Penggarap (Penerima Kuasa)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      TextField(controller: _namaPenggarapController, decoration: _deco('Nama Lengkap Penggarap')),
                      const SizedBox(height: 8),
                      TextField(controller: _nikPenggarapController, keyboardType: TextInputType.number, decoration: _deco('NIK Penggarap (16 digit)')),
                      const SizedBox(height: 8),
                      TextField(controller: _alamatPenggarapController, decoration: _deco('Alamat Penggarap')),
                      const SizedBox(height: 8),
                      TextField(controller: _hubunganController, decoration: _deco('Hubungan (misal: Penggarap Sawah / Ahli Waris)')),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Kuota Pupuk yang Diberikan
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: GojekColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('3. Rincian Sak Pupuk yang Ditebus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _sakUreaController, keyboardType: TextInputType.number, decoration: _deco('Sak Urea'))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: _sakNpkController, keyboardType: TextInputType.number, decoration: _deco('Sak NPK'))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: _sakOrganikController, keyboardType: TextInputType.number, decoration: _deco('Sak Org'))),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GojekColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _generateCustomSurat,
                    child: const Text('Buat Format Surat Kuasa F4', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _deco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: GojekColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.primary, width: 1.5)),
    );
  }
}
