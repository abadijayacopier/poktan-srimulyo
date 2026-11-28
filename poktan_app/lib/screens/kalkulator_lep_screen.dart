import 'package:flutter/material.dart';
import '../constants/theme.dart';

class KalkulatorLepScreen extends StatefulWidget {
  const KalkulatorLepScreen({super.key});

  @override
  State<KalkulatorLepScreen> createState() => _KalkulatorLepScreenState();
}

class _KalkulatorLepScreenState extends State<KalkulatorLepScreen> {
  final TextEditingController _luasController = TextEditingController(text: '50');
  String _selectedUnit = 'RU'; // RU (14 m2), HA (10000 m2), M2
  String _selectedKomoditas = 'Padi Sawah';

  // Perhitungan Dosis & Biaya
  double get _luasHa {
    final val = double.tryParse(_luasController.text.replaceAll(',', '.')) ?? 0.0;
    if (_selectedUnit == 'RU') return (val * 14.0) / 10000.0;
    if (_selectedUnit == 'M2') return val / 10000.0;
    return val;
  }

  double get _luasRu => _luasHa * (10000.0 / 14.0);

  // Dosis per Ha (Standar Dinas Pertanian Magetan untuk Padi Sawah):
  // Urea: 250 kg/Ha
  // NPK: 275 kg/Ha
  // Organik: 500 kg/Ha
  double get _ureaKg => _luasHa * (_selectedKomoditas == 'Padi Sawah' ? 250.0 : (_selectedKomoditas == 'Jagung' ? 300.0 : 100.0));
  double get _npkKg => _luasHa * (_selectedKomoditas == 'Padi Sawah' ? 275.0 : (_selectedKomoditas == 'Jagung' ? 300.0 : 200.0));
  double get _organikKg => _luasHa * 500.0;

  int get _ureaSak => (_ureaKg / 50.0).ceil();
  int get _npkSak => (_npkKg / 50.0).ceil();
  int get _organikSak => (_organikKg / 40.0).ceil();

  // HET: Urea = 2250, NPK = 2300, Organik = 800
  double get _biayaUrea => _ureaSak * (50 * 2250.0);
  double get _biayaNpk => _npkSak * (50 * 2300.0);
  double get _biayaOrganik => _organikSak * (40 * 800.0);
  double get _totalBiaya => _biayaUrea + _biayaNpk + _biayaOrganik;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoLEP · Kalkulator Lahan & Pupuk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Input Lahan
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
                  const Text('Input Luas Lahan Pertanian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _luasController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            filled: true,
                            fillColor: GojekColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GojekColors.primary, width: 1.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: GojekColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: GojekColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: GojekColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 13),
                            items: const [
                              DropdownMenuItem(value: 'RU', child: Text('Ru / Bata (14m²)')),
                              DropdownMenuItem(value: 'HA', child: Text('Hektar (Ha)')),
                              DropdownMenuItem(value: 'M2', child: Text('Meter² (m²)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Pilihan Komoditas
                  Row(
                    children: ['Padi Sawah', 'Jagung', 'Kedelai'].map((k) {
                      final isSel = _selectedKomoditas == k;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(k),
                          selected: isSel,
                          selectedColor: GojekColors.primary,
                          backgroundColor: GojekColors.background,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : GojekColors.textSecondary,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 11,
                          ),
                          onSelected: (s) {
                            if (s) setState(() => _selectedKomoditas = k);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: GojekColors.background, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Konversi: ${_luasHa.toStringAsFixed(3)} Ha · ${_luasRu.toStringAsFixed(1)} Ru · ${(_luasHa * 10000).toStringAsFixed(0)} m²',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GojekColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card Hasil Rekomendasi Pupuk
            const Text('Rekomendasi Pemupukan Berimbang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            _buildResultCard(
              nama: 'Urea (50 kg)',
              kg: _ureaKg.toStringAsFixed(1),
              sak: _ureaSak,
              biaya: _formatRupiah(_biayaUrea),
              color: Colors.green.shade800,
              bgColor: Colors.green.shade50,
            ),
            const SizedBox(height: 10),

            _buildResultCard(
              nama: 'NPK Phonska (50 kg)',
              kg: _npkKg.toStringAsFixed(1),
              sak: _npkSak,
              biaya: _formatRupiah(_biayaNpk),
              color: Colors.orange.shade800,
              bgColor: Colors.orange.shade50,
            ),
            const SizedBox(height: 10),

            _buildResultCard(
              nama: 'Petroganik Organik (40 kg)',
              kg: _organikKg.toStringAsFixed(1),
              sak: _organikSak,
              biaya: _formatRupiah(_biayaOrganik),
              color: Colors.brown.shade800,
              bgColor: Colors.brown.shade50,
            ),

            const SizedBox(height: 16),

            // Total Biaya Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: GojekColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GojekColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Estimasi Biaya HET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GojekColors.primaryDark)),
                      Text('Sesuai harga resmi pemerintah', style: TextStyle(fontSize: 10, color: GojekColors.textSecondary)),
                    ],
                  ),
                  Text(
                    _formatRupiah(_totalBiaya),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GojekColors.primaryDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SOP Tahapan Aplikasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GojekColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jadwal Aplikasi Pemupukan Padi:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  SizedBox(height: 10),
                  Text('• Pupuk Dasar (0 - 7 HST): Seluruh Organik + 50% NPK Phonska', style: TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                  SizedBox(height: 4),
                  Text('• Susulan I (21 - 25 HST): 50% Urea + 50% NPK Phonska sisa', style: TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                  SizedBox(height: 4),
                  Text('• Susulan II (35 - 40 HST): 50% Urea sisa saat pembentukan malai', style: TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String nama,
    required String kg,
    required int sak,
    required String biaya,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GojekColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 38,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GojekColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Kebutuhan: $kg kg', style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sak SAK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 2),
              Text(biaya, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GojekColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
