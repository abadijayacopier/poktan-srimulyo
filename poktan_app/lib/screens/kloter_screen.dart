import 'package:flutter/material.dart';
import '../constants/theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final kloters = _dataService.getKloters();
    final activeKloter = kloters.isNotEmpty && _selectedKloterIndex < kloters.length
        ? kloters[_selectedKloterIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoKloter · Jadwal & Pembagian'),
      ),
      body: Column(
        children: [
          // Horizontal Kloter Selector Chips
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
              margin: const EdgeInsets.all(16),
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: GojekColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Jadwal: ${activeKloter.tanggal}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GojekColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: GojekColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activeKloter.lokasi,
                          style: const TextStyle(fontSize: 12, color: GojekColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(height: 1, color: GojekColors.divider),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${activeKloter.totalPetani} Petani Terdaftar',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GojekColors.textPrimary),
                      ),
                      Text(
                        '${activeKloter.totalSudahAmbil} Selesai · ${activeKloter.totalBelumAmbil} Belum',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GojekColors.textSecondary),
                      ),
                    ],
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
}
