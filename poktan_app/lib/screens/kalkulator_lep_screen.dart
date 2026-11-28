import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../services/data_service.dart';

class KalkulatorLepScreen extends StatefulWidget {
  const KalkulatorLepScreen({super.key});

  @override
  State<KalkulatorLepScreen> createState() => _KalkulatorLepScreenState();
}

class _KalkulatorLepScreenState extends State<KalkulatorLepScreen> {
  final DataService _dataService = DataService();

  // Form Controllers
  final TextEditingController _pemilikController = TextEditingController(text: 'Diesel Poktan Sri Mulyo');
  final TextEditingController _petaniController = TextEditingController();
  final TextEditingController _waController = TextEditingController();
  final TextEditingController _blokController = TextEditingController(text: 'Sawah Desa Kediren');
  final TextEditingController _jamMulaiController = TextEditingController(text: '07:00');
  final TextEditingController _jamSelesaiController = TextEditingController(text: '11:30');
  final TextEditingController _durasiJamController = TextEditingController(text: '4');
  final TextEditingController _durasiMenitController = TextEditingController(text: '30');
  final TextEditingController _tarifController = TextEditingController(text: '30000');
  final TextEditingController _bbmController = TextEditingController(text: '0');
  final TextEditingController _diskonController = TextEditingController(text: '0');

  // State
  String _modeWaktu = 'JAM'; // 'JAM' (Mulai-Selesai) atau 'DURASI' (Jam & Menit)
  String _statusBayar = 'LUNAS'; // 'LUNAS' atau 'BELUM LUNAS'
  final DateTime _tanggalLep = DateTime.now();

  @override
  void initState() {
    super.initState();
    _recalculateFromJam();
  }

  void _setPresetTarif(int tarif) {
    setState(() {
      _tarifController.text = tarif.toString();
    });
  }

  void _recalculateFromJam() {
    try {
      final mParts = _jamMulaiController.text.split(':');
      final sParts = _jamSelesaiController.text.split(':');
      if (mParts.length == 2 && sParts.length == 2) {
        final mH = int.parse(mParts[0]);
        final mM = int.parse(mParts[1]);
        final sH = int.parse(sParts[0]);
        final sM = int.parse(sParts[1]);

        int startMin = mH * 60 + mM;
        int endMin = sH * 60 + sM;
        if (endMin < startMin) endMin += 24 * 60; // Lintas tengah malam

        int diffMin = endMin - startMin;
        int h = diffMin ~/ 60;
        int m = diffMin % 60;

        _durasiJamController.text = h.toString();
        _durasiMenitController.text = m.toString();
      }
    } catch (_) {}
  }

  double get _totalDurasiJam {
    final j = double.tryParse(_durasiJamController.text) ?? 0.0;
    final m = double.tryParse(_durasiMenitController.text) ?? 0.0;
    return j + (m / 60.0);
  }

  double get _biayaPokokPompa {
    final tarif = double.tryParse(_tarifController.text) ?? 0.0;
    return _totalDurasiJam * tarif;
  }

  double get _biayaBbm => double.tryParse(_bbmController.text) ?? 0.0;
  double get _diskon => double.tryParse(_diskonController.text) ?? 0.0;
  double get _totalTagihan => (_biayaPokokPompa + _biayaBbm) - _diskon;

  String _formatRupiah(double val) {
    final intVal = val.round();
    final str = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  void _showPetaniPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final list = _dataService.farmers.where((f) {
              if (filter.isEmpty) return true;
              return f.nama.toLowerCase().contains(filter.toLowerCase()) || f.nik.contains(filter);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: GojekColors.border, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Pilih Petani Pemakai Pompa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari nama petani atau NIK...',
                        prefixIcon: const Icon(Icons.search, color: GojekColors.primary),
                        filled: true,
                        fillColor: GojekColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (v) => setModalState(() => filter = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: GojekColors.border),
                      itemBuilder: (ctx, i) {
                        final f = list[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: CircleAvatar(
                            backgroundColor: GojekColors.primarySoft,
                            child: Text(f.nama.isNotEmpty ? f.nama[0] : 'P', style: const TextStyle(color: GojekColors.primaryDark, fontWeight: FontWeight.w800)),
                          ),
                          title: Text(f.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          subtitle: Text('Lahan: ${f.effectiveLahan} Ha • ${f.alamat}', style: const TextStyle(fontSize: 11)),
                          onTap: () {
                            setState(() {
                              _petaniController.text = f.nama;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _kirimNotaWa() {
    final tglStr = '${_tanggalLep.day}-${_tanggalLep.month}-${_tanggalLep.year}';
    final text = '''*NOTA RESMI SEWA POMPA LEP SAWAH*
*POKTAN "SRI MULYO" DESA KEDIREN*
=================================
Tanggal     : $tglStr
Pemilik Pompa: ${_pemilikController.text}
Petani Pemakai: ${_petaniController.text.isNotEmpty ? _petaniController.text : '-'}
Lokasi/Blok : ${_blokController.text}
---------------------------------
Waktu Lep   : ${_durasiJamController.text} Jam ${_durasiMenitController.text} Menit
Tarif Sewa  : ${_formatRupiah(double.tryParse(_tarifController.text) ?? 0)} / Jam
Biaya Sewa  : ${_formatRupiah(_biayaPokokPompa)}
Biaya BBM   : ${_formatRupiah(_biayaBbm)}
Potongan    : ${_formatRupiah(_diskon)}
---------------------------------
*TOTAL BIAYA: ${_formatRupiah(_totalTagihan)}*
*STATUS     : $_statusBayar*
=================================
_Terima kasih atas kerja sama irigasi sawah Poktan Sri Mulyo_''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nota Lep Sawah disalin! Siap dikirim ke WhatsApp petani.'),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GojekColors.background,
      appBar: AppBar(
        title: const Text('GoLEP · Nota Lep Sawah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006C7A), Color(0xFF0081A0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF006C7A).withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalkulator & Nota Sewa Pompa',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hitung durasi jam pompa diesel sawah, tarif sewa, BBM, dan cetak nota digital resmi.',
                          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 1: Data Transaksi Petani
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
                  const Text('1. Data Pemakai & Sumur', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                  const SizedBox(height: 12),

                  // Pemilik Mesin
                  _buildLabel('Nama Pemilik Sumur / Diesel'),
                  TextField(
                    controller: _pemilikController,
                    decoration: _inputDeco('Contoh: Diesel Poktan Sri Mulyo', Icons.precision_manufacturing),
                  ),
                  const SizedBox(height: 12),

                  // Petani Pemakai
                  _buildLabel('Nama Petani Pemakai *'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _petaniController,
                          decoration: _inputDeco('Nama Petani Pemakai', Icons.person),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: GojekColors.primary),
                        icon: const Icon(Icons.list, color: Colors.white),
                        tooltip: 'Pilih dari 195 Petani',
                        onPressed: _showPetaniPicker,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // WhatsApp Petani
                  _buildLabel('No. WhatsApp Petani (Opsional)'),
                  TextField(
                    controller: _waController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDeco('Contoh: 085655620979', Icons.chat),
                  ),
                  const SizedBox(height: 12),

                  // Blok Lahan
                  _buildLabel('Lokasi / Blok Sawah & Tanaman'),
                  TextField(
                    controller: _blokController,
                    decoration: _inputDeco('Contoh: Blok Melin - Padi Sawah', Icons.landscape),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 2: Durasi Waktu Lep Sawah
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
                      const Text('2. Durasi Waktu Lep', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'JAM', label: Text('Jam Mulai', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: 'DURASI', label: Text('Durasi', style: TextStyle(fontSize: 11))),
                        ],
                        selected: {_modeWaktu},
                        onSelectionChanged: (set) {
                          setState(() {
                            _modeWaktu = set.first;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_modeWaktu == 'JAM') ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Jam Mulai (HH:mm)'),
                              TextField(
                                controller: _jamMulaiController,
                                keyboardType: TextInputType.datetime,
                                decoration: _inputDeco('07:00', Icons.access_time),
                                onChanged: (_) {
                                  _recalculateFromJam();
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Jam Selesai (HH:mm)'),
                              TextField(
                                controller: _jamSelesaiController,
                                keyboardType: TextInputType.datetime,
                                decoration: _inputDeco('11:30', Icons.timelapse),
                                onChanged: (_) {
                                  _recalculateFromJam();
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Jumlah Jam'),
                            TextField(
                              controller: _durasiJamController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDeco('0', Icons.timer),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Jumlah Menit'),
                            TextField(
                              controller: _durasiMenitController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDeco('0', Icons.timelapse_outlined),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: GojekColors.primarySoft, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '⏱️ Total Durasi: ${_durasiJamController.text} Jam ${_durasiMenitController.text} Menit (${_totalDurasiJam.toStringAsFixed(2)} Jam Efektif)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GojekColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 3: Tarif & Biaya Tambahan
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
                  const Text('3. Tarif & Pengaturan Biaya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                  const SizedBox(height: 12),

                  _buildLabel('Tarif Sewa Pompa Per Jam (Rp) *'),
                  TextField(
                    controller: _tarifController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('30000', Icons.payments_outlined),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),

                  // Preset Buttons
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildPresetChip(25000),
                      _buildPresetChip(30000),
                      _buildPresetChip(35000),
                      _buildPresetChip(40000),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Biaya BBM / Solar (Rp)'),
                            TextField(
                              controller: _bbmController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDeco('0', Icons.local_gas_station),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Potongan / Diskon (Rp)'),
                            TextField(
                              controller: _diskonController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDeco('0', Icons.discount_outlined),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildLabel('Status Pembayaran'),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('LUNAS')),
                          selected: _statusBayar == 'LUNAS',
                          selectedColor: GojekColors.primary,
                          labelStyle: TextStyle(
                            color: _statusBayar == 'LUNAS' ? Colors.white : GojekColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                          onSelected: (s) => setState(() => _statusBayar = 'LUNAS'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('BELUM LUNAS')),
                          selected: _statusBayar == 'BELUM LUNAS',
                          selectedColor: GojekColors.orange,
                          labelStyle: TextStyle(
                            color: _statusBayar == 'BELUM LUNAS' ? Colors.white : GojekColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                          onSelected: (s) => setState(() => _statusBayar = 'BELUM LUNAS'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 4: Preview Struk / Nota Resmi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GojekColors.primary, width: 1.5),
                boxShadow: [
                  BoxShadow(color: GojekColors.primary.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('POKTAN SRI MULYO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GojekColors.primaryDark)),
                          Text('Nota Resmi Lep Sawah', style: TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusBayar == 'LUNAS' ? GojekColors.primarySoft : GojekColors.orangeSoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _statusBayar == 'LUNAS' ? GojekColors.primary : GojekColors.orange),
                        ),
                        child: Text(
                          _statusBayar,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: _statusBayar == 'LUNAS' ? GojekColors.primaryDark : GojekColors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: GojekColors.border),

                  _buildNotaLine('Petani Pemakai', _petaniController.text.isNotEmpty ? _petaniController.text : '-'),
                  _buildNotaLine('Pemilik Pompa', _pemilikController.text),
                  _buildNotaLine('Lokasi Lahan', _blokController.text),
                  _buildNotaLine('Durasi Waktu', '${_durasiJamController.text} Jam ${_durasiMenitController.text} Menit'),
                  _buildNotaLine('Biaya Pokok Sewa', _formatRupiah(_biayaPokokPompa)),
                  if (_biayaBbm > 0)
                    _buildNotaLine('BBM Solar / Bensin', '+ ${_formatRupiah(_biayaBbm)}'),
                  if (_diskon > 0)
                    _buildNotaLine('Potongan', '- ${_formatRupiah(_diskon)}'),

                  const Divider(height: 20, color: GojekColors.border),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL TAGIHAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: GojekColors.textPrimary)),
                      Text(
                        _formatRupiah(_totalTagihan),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GojekColors.primaryDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text('Kirim Struk ke WhatsApp Petani', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      onPressed: _kirimNotaWa,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.textSecondary)),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: GojekColors.primary, size: 18),
      filled: true,
      fillColor: GojekColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.primary, width: 1.5)),
    );
  }

  Widget _buildPresetChip(int tarif) {
    final isSelected = _tarifController.text == tarif.toString();
    return ActionChip(
      label: Text('Rp ${tarif ~/ 1000}k/jam'),
      backgroundColor: isSelected ? GojekColors.primarySoft : GojekColors.background,
      side: BorderSide(color: isSelected ? GojekColors.primary : GojekColors.border),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? GojekColors.primaryDark : GojekColors.textSecondary,
      ),
      onPressed: () => _setPresetTarif(tarif),
    );
  }

  Widget _buildNotaLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: GojekColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GojekColors.textPrimary)),
        ],
      ),
    );
  }
}
