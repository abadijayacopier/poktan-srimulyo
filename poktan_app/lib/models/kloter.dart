import 'farmer.dart';

class KloterGroup {
  final int nomor;
  final String nama;
  final String tanggal;
  final String lokasi;
  final String status;
  final List<Farmer> members;

  KloterGroup({
    required this.nomor,
    required this.nama,
    required this.tanggal,
    required this.lokasi,
    required this.status,
    required this.members,
  });

  int get totalPetani => members.length;
  int get totalSudahAmbil => members.where((m) => m.isSudahAmbil).length;
  int get totalBelumAmbil => totalPetani - totalSudahAmbil;
  double get persentase => totalPetani == 0 ? 0.0 : (totalSudahAmbil / totalPetani);
}
