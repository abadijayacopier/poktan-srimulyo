import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';

class KuasaPenggarapScreen extends StatefulWidget {
  const KuasaPenggarapScreen({super.key});

  @override
  State<KuasaPenggarapScreen> createState() => _KuasaPenggarapScreenState();
}

class _KuasaPenggarapScreenState extends State<KuasaPenggarapScreen> {
  final _namaPemilikController = TextEditingController();
  final _nikPemilikController = TextEditingController();
  final _namaPenggarapController = TextEditingController();
  final _nikPenggarapController = TextEditingController();
  final _hubunganController = TextEditingController(text: 'Penggarap Sawah');

  void _generateSuratDraft() {
    final pemilik = _namaPemilikController.text.trim();
    final nikPemilik = _nikPemilikController.text.trim();
    final penggarap = _namaPenggarapController.text.trim();
    final nikPenggarap = _nikPenggarapController.text.trim();
    final hubungan = _hubunganController.text.trim();

    if (pemilik.isEmpty || penggarap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi nama pemilik dan nama penggarap terlebih dahulu!'),
          backgroundColor: GojekColors.red,
        ),
      );
      return;
    }

    final draft = '''SURAT KUASA PENGAMBILAN PUPUK BERSUBSIDI
POKTAN "SRI MULYO" DESA KEDIREN, KEC. LEMBEYAN
MUSIM TANAM III (MT3) 2026

Yang bertanda tangan di bawah ini (Pemberi Kuasa):
Nama Lengkap : $pemilik
NIK          : $nikPemilik
Status       : Pemilik Lahan (Terdaftar e-RDKK)

Memberikan KUASA PENUH kepada (Penerima Kuasa):
Nama Lengkap : $penggarap
NIK          : $nikPenggarap
Hubungan     : $hubungan

Untuk mengambil dan menebus jatah alokasi pupuk bersubsidi (Urea / NPK / Organik) atas nama Pemberi Kuasa di Kios Resmi Poktan Sri Mulyo, Desa Kediren, Kec. Lembeyan, Kab. Magetan.

Kediren, ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}

Penerima Kuasa,                    Pemberi Kuasa (Materai Rp 10.000),

( $penggarap )                      ( $pemilik )

Mengetahui,
Ketua Poktan Sri Mulyo''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Draft Surat Kuasa Resmi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: SingleChildScrollView(
          child: Text(draft, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: GojekColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.copy, size: 16, color: Colors.white),
            label: const Text('Salin Draft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: draft));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Draft Surat Kuasa berhasil disalin!'),
                  backgroundColor: GojekColors.primaryDark,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoKuasa · Kuasa Penggarap'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GojekColors.blueSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GojekColors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: GojekColors.blue, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ketentuan Pengambilan Diwakilkan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GojekColors.blue),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bagi pemilik lahan yang berhalangan hadir / lanjut usia / di luar kota, penebusan pupuk subsidi wajib menyertakan Surat Kuasa Penggarap bermaterai Rp 10.000 disertai fotokopi KTP.',
                          style: TextStyle(fontSize: 11, color: GojekColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form Pembuat Surat Kuasa Cepat
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: GojekColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formulir Surat Kuasa Cepat',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Isi data di bawah ini untuk membuat format surat resmi otomatis',
                    style: TextStyle(fontSize: 11, color: GojekColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionLabel('1. DATA PEMILIK LAHAN (Pemberi Kuasa)'),
                  const SizedBox(height: 8),
                  _buildTextField(_namaPemilikController, 'Nama Lengkap Pemilik Sesuai KTP'),
                  const SizedBox(height: 8),
                  _buildTextField(_nikPemilikController, 'NIK Pemilik Lahan (16 Digit)', isNumber: true),

                  const SizedBox(height: 16),
                  _buildSectionLabel('2. DATA PENGGARAP (Penerima Kuasa)'),
                  const SizedBox(height: 8),
                  _buildTextField(_namaPenggarapController, 'Nama Lengkap Penggarap'),
                  const SizedBox(height: 8),
                  _buildTextField(_nikPenggarapController, 'NIK Penggarap', isNumber: true),
                  const SizedBox(height: 8),
                  _buildTextField(_hubunganController, 'Hubungan (Penggarap / Anak / Keluarga)'),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GojekColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.description, color: Colors.white),
                      label: const Text(
                        'Buat Draft Surat Kuasa',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      onPressed: _generateSuratDraft,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SOP Pengambilan Pupuk
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
                  const Text('Langkah Pengambilan dengan Kuasa:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  _buildStepItem('1', 'Cetak atau tulis tangan draft surat kuasa di atas kertas HVS.'),
                  _buildStepItem('2', 'Tempelkan materai Rp 10.000 pada tanda tangan Pemberi Kuasa.'),
                  _buildStepItem('3', 'Lampirkan FC KTP Pemilik Lahan dan FC KTP Penggarap.'),
                  _buildStepItem('4', 'Bawa berkas ke Kios Resmi Poktan Sri Mulyo untuk difoto dan verifikasi sistem.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GojekColors.primaryDark),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13, color: GojekColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: GojekColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: GojekColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GojekColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildStepItem(String num, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: GojekColors.primary, shape: BoxShape.circle),
            child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary))),
        ],
      ),
    );
  }
}
