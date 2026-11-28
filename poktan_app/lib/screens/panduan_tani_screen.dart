import 'package:flutter/material.dart';
import '../constants/theme.dart';

class PanduanTaniScreen extends StatefulWidget {
  const PanduanTaniScreen({super.key});

  @override
  State<PanduanTaniScreen> createState() => _PanduanTaniScreenState();
}

class _PanduanTaniScreenState extends State<PanduanTaniScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State Kalkulator Dosis
  String _komoditas = 'Padi Sawah';
  String _varietas = 'Inpari 32';
  final TextEditingController _luasController = TextEditingController(text: '50');
  String _unit = 'RU'; // RU (14 m2), BATA, HA, M2

  // State Kalender Tanam
  DateTime _tanggalTanam = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _luasController.dispose();
    super.dispose();
  }

  double get _luasHa {
    final val = double.tryParse(_luasController.text.replaceAll(',', '.')) ?? 0.0;
    if (_unit == 'RU' || _unit == 'BATA') return (val * 14.0) / 10000.0;
    if (_unit == 'M2') return val / 10000.0;
    return val;
  }

  // Dosis Pupuk Rekomendasi BPP Kec. Lembeyan (per Ha):
  // Padi: Urea 250 kg (5 Sak), NPK 275 kg (5.5 Sak), Organik 500 kg (12.5 Sak)
  // Jagung: Urea 300 kg (6 Sak), NPK 300 kg (6 Sak), Organik 500 kg
  // Kedelai: Urea 50 kg, NPK 150 kg, Organik 500 kg
  double get _ureaKg => _luasHa * (_komoditas == 'Padi Sawah' ? 250.0 : (_komoditas == 'Jagung Hibrida' ? 300.0 : 50.0));
  double get _npkKg => _luasHa * (_komoditas == 'Padi Sawah' ? 275.0 : (_komoditas == 'Jagung Hibrida' ? 300.0 : 150.0));
  double get _organikKg => _luasHa * 500.0;

  int get _ureaSak => (_ureaKg / 50.0).ceil();
  int get _npkSak => (_npkKg / 50.0).ceil();
  int get _organikSak => (_organikKg / 40.0).ceil();

  // Umur varietas dalam hari
  int get _umurVarietas {
    if (_varietas.contains('Inpari 32') || _varietas.contains('Ciherang')) return 115;
    if (_varietas.contains('Membramo')) return 120;
    if (_varietas.contains('BC 18') || _varietas.contains('NK 212')) return 105;
    return 110;
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GojekColors.background,
      appBar: AppBar(
        title: const Text('GoPanduan · Dosis & Kalender Tani'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: GojekColors.primary,
          unselectedLabelColor: GojekColors.textSecondary,
          indicatorColor: GojekColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.calculate_outlined, size: 20), text: 'Dosis Pupuk'),
            Tab(icon: Icon(Icons.calendar_month, size: 20), text: 'Kalender Tanam'),
            Tab(icon: Icon(Icons.bug_report_outlined, size: 20), text: 'Solusi Hama'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDosisTab(),
          _buildKalenderTab(),
          _buildHamaTab(),
        ],
      ),
    );
  }

  Widget _buildDosisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pilihan Komoditas & Varietas Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GojekColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilihan Komoditas & Varietas Benih', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                const SizedBox(height: 12),

                // Komoditas
                DropdownButtonFormField<String>(
                  value: _komoditas,
                  decoration: InputDecoration(
                    labelText: 'Komoditas Tanaman',
                    filled: true,
                    fillColor: GojekColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Padi Sawah', child: Text('🌾 Padi Sawah')),
                    DropdownMenuItem(value: 'Jagung Hibrida', child: Text('🌽 Jagung Hibrida')),
                    DropdownMenuItem(value: 'Kedelai', child: Text('🌱 Kedelai')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _komoditas = v;
                        if (v == 'Padi Sawah') {
                          _varietas = 'Inpari 32';
                        } else if (v == 'Jagung Hibrida') {
                          _varietas = 'BC 18';
                        } else {
                          _varietas = 'Anjasmoro';
                        }
                      });
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Varietas
                DropdownButtonFormField<String>(
                  value: _varietas,
                  decoration: InputDecoration(
                    labelText: 'Varietas Benih Resmi',
                    filled: true,
                    fillColor: GojekColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
                  ),
                  items: _komoditas == 'Padi Sawah'
                      ? const [
                          DropdownMenuItem(value: 'Inpari 32', child: Text('Inpari 32 (~115 HST, Tahan Blas)')),
                          DropdownMenuItem(value: 'Ciherang', child: Text('Ciherang (~115 HST, Nasi Pulen)')),
                          DropdownMenuItem(value: 'Membramo', child: Text('Membramo (~120 HST, Tahan Wereng)')),
                        ]
                      : _komoditas == 'Jagung Hibrida'
                          ? const [
                              DropdownMenuItem(value: 'BC 18', child: Text('Bisi 18 (~105 HST, Tongkol Ganda)')),
                              DropdownMenuItem(value: 'NK 212', child: Text('NK 212 (~105 HST, Bobot Tinggi)')),
                            ]
                          : const [
                              DropdownMenuItem(value: 'Anjasmoro', child: Text('Anjasmoro (~85 HST)')),
                            ],
                  onChanged: (v) {
                    if (v != null) setState(() => _varietas = v);
                  },
                ),

                const SizedBox(height: 14),

                // Input Luas Lahan
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _luasController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Luas Lahan',
                          filled: true,
                          fillColor: GojekColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _unit,
                        decoration: InputDecoration(
                          labelText: 'Satuan',
                          filled: true,
                          fillColor: GojekColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'RU', child: Text('Ru (14 m²)')),
                          DropdownMenuItem(value: 'HA', child: Text('Hektar (Ha)')),
                          DropdownMenuItem(value: 'M2', child: Text('Meter (m²)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _unit = v);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Total Kebutuhan Pupuk Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GojekColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Rekomendasi Dosis Pupuk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                    Text('Luas: ${_luasHa.toStringAsFixed(3)} Ha', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.primaryDark)),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildDosisBox('Urea (N)', '$_ureaSak Sak', '${_ureaKg.toStringAsFixed(1)} kg', Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDosisBox('NPK Phonska', '$_npkSak Sak', '${_npkKg.toStringAsFixed(1)} kg', Colors.orange),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDosisBox('Organik', '$_organikSak Sak', '${_organikKg.toStringAsFixed(1)} kg', Colors.brown),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SOP Jadwal Pemupukan Berimbang per HST
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GojekColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jadwal Aplikasi Pemupukan Berimbang (HST)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                const SizedBox(height: 12),

                _buildHstRow('Fase Dasar (0 - 1 HST)', '100% Organik + 1/3 Dosis Urea + 1/2 Dosis NPK. Disebar merata saat olah tanah terakhir sebelum bibit ditancap.'),
                _buildHstRow('Susulan I (7 - 14 HST)', '1/3 Dosis Urea + 1/2 Dosis NPK. Merangsang pembentukan akar dan tunas anakan aktif. Macak-macak air sawah.'),
                _buildHstRow('Susulan II (25 - 30 HST)', '1/3 Sisa Dosis Urea. Pembentukan malai dan anakan produktif maksimal.'),
                if (_komoditas == 'Padi Sawah')
                  _buildHstRow('Pengisian Bulir (45 - 50 HST)', 'Semprot pupuk daun Kalium tinggi (KNO3 / MKP) untuk mengoptimalkan gabah berisi padat dan bernas.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKalenderTab() {
    final tglTanam = _tanggalTanam;
    final tglOlah = tglTanam.subtract(const Duration(days: 14));
    final tglSemai = tglTanam.subtract(const Duration(days: 21));
    final tglPupuk1 = tglTanam.add(const Duration(days: 10));
    final tglPupuk2 = tglTanam.add(const Duration(days: 28));
    final tglBunting = tglTanam.add(const Duration(days: 60));
    final tglPanen = tglTanam.add(Duration(days: _umurVarietas - 20));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Input Tanggal Tanam
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GojekColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Tanggal Tanam Sawah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Kalender akan mengkalkulasi jadwal olah tanah, pupuk, hingga hari H panen.', style: TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                const SizedBox(height: 14),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _tanggalTanam,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _tanggalTanam = picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: GojekColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GojekColors.primary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: GojekColors.primaryDark),
                            const SizedBox(width: 10),
                            Text('Tanggal Tanam: ${_formatDate(_tanggalTanam)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: GojekColors.primaryDark)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: GojekColors.primaryDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Timeline Kalender Tanam
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GojekColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Timeline Budidaya $_komoditas ($_varietas)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                const SizedBox(height: 14),

                _buildTimelineItem('Penyemaian Benih', _formatDate(tglSemai), 'Siapkan persemaian 21 hari sebelum tanam. Rawat dari orong-orong.', Colors.blue),
                _buildTimelineItem('Olah Tanah & Pupuk Dasar', _formatDate(tglOlah), 'Bajak sawah, garu, dan berikan pupuk Organik petroganik.', Colors.amber),
                _buildTimelineItem('Hari H Penanaman Bibit', _formatDate(tglTanam), 'Tanam bibit umur 18-21 hari dengan sistem Jajar Legowo 2:1.', GojekColors.primary),
                _buildTimelineItem('Pemupukan Susulan I', _formatDate(tglPupuk1), '10 HST: Aplikasi Urea + NPK dosis pertama.', Colors.teal),
                _buildTimelineItem('Pemupukan Susulan II', _formatDate(tglPupuk2), '28 HST: Aplikasi Urea susulan kedua untuk pacu anakan.', Colors.indigo),
                _buildTimelineItem('Fase Bunting / Primordia', _formatDate(tglBunting), '60 HST: Waspada penggerek batang dan wereng. Jaga air tetap lembab.', Colors.purple),
                _buildTimelineItem('Perkiraan Panen Raya', _formatDate(tglPanen), '90-95% bulir padi telah menguning keemasan. Panen siap dilakukan!', Colors.green.shade800, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHamaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHamaCard(
          nama: 'Wereng Batang Coklat (WBC)',
          gejala: 'Batang padi kering kecoklatan melingkar seperti terbakar (hopperburn). Serangan cepat pada pangkal rumpun.',
          solusi: 'Keringkan air sawah berkala. Semprot bahan aktif Pimetrozin / Buprofezin tepat mengarah ke pangkal batang pagi hari.',
          bahanAktif: 'Pimetrozin 50%, Buprofezin 10%',
          warna: Colors.orange,
        ),
        _buildHamaCard(
          nama: 'Penggerek Batang (Sundep / Beluk)',
          gejala: 'Pucuk tanaman mati layu pada fase vegetatif (sundep) atau malai hampa tegak putih pada fase generatif (beluk).',
          solusi: 'Kumpulkan kelompok telur. Aplikasi insektisida sistemik Dimehipo atau Karbofuran sesuai ambang kendali BPP.',
          bahanAktif: 'Dimehipo 400 SL / Klorantraniliprol',
          warna: Colors.red,
        ),
        _buildHamaCard(
          nama: 'Hawar Daun Bakteri (Kresek)',
          gejala: 'Daun mengering mulai dari ujung tepi daun berwarna kuning keabu-abuan bergelombang.',
          solusi: 'Kurangi pupuk Urea berlebih. Tambah unsur Kalium (KCL). Gunakan bakterisida tembaga hidroksida.',
          bahanAktif: 'Tembaga Hidroksida / Asam Oksolinat',
          warna: Colors.amber.shade800,
        ),
        _buildHamaCard(
          nama: 'Penyakit Blas (Pyricularia oryzae)',
          gejala: 'Bercak belah ketupat runcing di daun (blas daun) atau leher malai membusuk patah (blas leher).',
          solusi: 'Hindari jarak tanam terlalu rapat. Semprot fungisida Trisiklazol atau Difenokonazol saat bunting muda.',
          bahanAktif: 'Trisiklazol 75 WP / Difenokonazol',
          warna: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDosisBox(String title, String sak, String kg, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 6),
          Text(sak, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(kg, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GojekColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildHstRow(String fase, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: GojekColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 14, color: GojekColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fase, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String judul, String tanggal, String deskripsi, Color color, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(width: 2, height: 48, color: GojekColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(judul, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                    Text(tanggal, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(deskripsi, style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHamaCard({
    required String nama,
    required String gejala,
    required String solusi,
    required String bahanAktif,
    required Color warna,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                decoration: BoxDecoration(color: warna.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.bug_report, color: warna, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Gejala: $gejala', style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary, height: 1.3)),
          const SizedBox(height: 6),
          Text('Pengendalian: $solusi', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GojekColors.textPrimary, height: 1.3)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: GojekColors.background, borderRadius: BorderRadius.circular(8)),
            child: Text('Bahan Aktif Rekomendasi: $bahanAktif', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GojekColors.primaryDark)),
          ),
        ],
      ),
    );
  }
}
