class Penggarap {
  final String no;
  final String nikPemilik;
  final String namaPemilik;
  final String alamatPemilik;
  final String luasLahan;
  final String nikPenggarap;
  final String namaPenggarap;
  final String alamatPenggarap;
  final String statusGarap;
  final String ureaKg;
  final String phonskaKg;
  final String organikKg;
  final String sakUrea;
  final String sakPhonska;
  final String sakOrganik;
  final String totalBiaya;
  final String statusPenebusan;
  final String statusBerkas;

  Penggarap({
    required this.no,
    required this.nikPemilik,
    required this.namaPemilik,
    required this.alamatPemilik,
    required this.luasLahan,
    required this.nikPenggarap,
    required this.namaPenggarap,
    required this.alamatPenggarap,
    required this.statusGarap,
    required this.ureaKg,
    required this.phonskaKg,
    required this.organikKg,
    required this.sakUrea,
    required this.sakPhonska,
    required this.sakOrganik,
    required this.totalBiaya,
    required this.statusPenebusan,
    required this.statusBerkas,
  });

  factory Penggarap.fromJson(Map<String, dynamic> json) {
    return Penggarap(
      no: json['no']?.toString() ?? '',
      nikPemilik: json['nikPemilik']?.toString() ?? '',
      namaPemilik: json['namaPemilik']?.toString().toUpperCase() ?? '',
      alamatPemilik: json['alamatPemilik']?.toString() ?? 'Desa Kediren, Kec. Lembeyan',
      luasLahan: json['luasLahan']?.toString() ?? '',
      nikPenggarap: json['nikPenggarap']?.toString() ?? '',
      namaPenggarap: json['namaPenggarap']?.toString().toUpperCase() ?? '',
      alamatPenggarap: json['alamatPenggarap']?.toString() ?? 'Desa Kediren, Kec. Lembeyan',
      statusGarap: json['statusGarap']?.toString() ?? 'Penggarap Sawah',
      ureaKg: json['ureaKg']?.toString() ?? '0',
      phonskaKg: json['phonskaKg']?.toString() ?? '0',
      organikKg: json['organikKg']?.toString() ?? '0',
      sakUrea: json['sakUrea']?.toString() ?? '0',
      sakPhonska: json['sakPhonska']?.toString() ?? '0',
      sakOrganik: json['sakOrganik']?.toString() ?? '0',
      totalBiaya: json['totalBiaya']?.toString() ?? '',
      statusPenebusan: json['statusPenebusan']?.toString() ?? 'SUDAH AMBIL',
      statusBerkas: json['statusBerkas']?.toString() ?? 'SURAT KUASA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'nikPemilik': nikPemilik,
      'namaPemilik': namaPemilik,
      'alamatPemilik': alamatPemilik,
      'luasLahan': luasLahan,
      'nikPenggarap': nikPenggarap,
      'namaPenggarap': namaPenggarap,
      'alamatPenggarap': alamatPenggarap,
      'statusGarap': statusGarap,
      'ureaKg': ureaKg,
      'phonskaKg': phonskaKg,
      'organikKg': organikKg,
      'sakUrea': sakUrea,
      'sakPhonska': sakPhonska,
      'sakOrganik': sakOrganik,
      'totalBiaya': totalBiaya,
      'statusPenebusan': statusPenebusan,
      'statusBerkas': statusBerkas,
    };
  }

  int get totalSak {
    final u = int.tryParse(sakUrea) ?? 0;
    final p = int.tryParse(sakPhonska) ?? 0;
    final o = int.tryParse(sakOrganik) ?? 0;
    return u + p + o;
  }
}
