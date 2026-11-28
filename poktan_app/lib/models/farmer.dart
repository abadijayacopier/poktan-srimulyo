class Farmer {
  final String no;
  final String nik;
  final String nama;
  final String lahan;
  final String revisi;
  final String status;
  final String urea;
  final String npk;
  final String organik;
  final String ureaSak;
  final String npkSak;
  final String organikSak;
  final String uang;
  final String ket;

  // Biodata tambahan (opsional dari e-RDKK)
  final String tempatLahir;
  final String tanggalLahir;
  final String ibuKandung;
  final String alamat;

  Farmer({
    required this.no,
    required this.nik,
    required this.nama,
    required this.lahan,
    this.revisi = '',
    required this.status,
    required this.urea,
    required this.npk,
    required this.organik,
    required this.ureaSak,
    required this.npkSak,
    required this.organikSak,
    this.uang = '',
    this.ket = '',
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.ibuKandung = '',
    this.alamat = 'Desa Kediren, Kec. Lembeyan',
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      no: json['no']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      nama: json['nama']?.toString().toUpperCase() ?? '',
      lahan: json['lahan']?.toString() ?? '0',
      revisi: json['revisi']?.toString() ?? '',
      status: json['status']?.toString() ?? 'BELUM AMBIL',
      urea: json['urea']?.toString() ?? '0',
      npk: json['npk']?.toString() ?? '0',
      organik: json['organik']?.toString() ?? '0',
      ureaSak: json['urea_sak']?.toString() ?? json['ureaSak']?.toString() ?? '0',
      npkSak: json['npk_sak']?.toString() ?? json['npkSak']?.toString() ?? '0',
      organikSak: json['organik_sak']?.toString() ?? json['organikSak']?.toString() ?? '0',
      uang: json['uang']?.toString() ?? '',
      ket: json['ket']?.toString() ?? '',
      tempatLahir: json['tempatLahir']?.toString() ?? '',
      tanggalLahir: json['tanggalLahir']?.toString() ?? '',
      ibuKandung: json['ibuKandung']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? 'Desa Kediren, Kec. Lembeyan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'nik': nik,
      'nama': nama,
      'lahan': lahan,
      'revisi': revisi,
      'status': status,
      'urea': urea,
      'npk': npk,
      'organik': organik,
      'urea_sak': ureaSak,
      'npk_sak': npkSak,
      'organik_sak': organikSak,
      'uang': uang,
      'ket': ket,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir,
      'ibuKandung': ibuKandung,
      'alamat': alamat,
    };
  }

  bool get isSudahAmbil => status.toUpperCase().contains('SUDAH');
  bool get isBelumAmbil => !isSudahAmbil;
  bool get hasSetorKtp => status.toUpperCase().contains('KTP');
  bool get hasSuratKuasa => status.toUpperCase().contains('KUASA');

  // Sensored NIK helper: 352003******0001
  String get maskedNik {
    if (nik.length <= 8) return nik;
    final prefix = nik.substring(0, 6);
    final suffix = nik.substring(nik.length - 4);
    return '$prefix******$suffix';
  }

  // Estimasi total sak
  int get totalSak {
    final u = int.tryParse(ureaSak) ?? 0;
    final n = int.tryParse(npkSak) ?? 0;
    final o = int.tryParse(organikSak) ?? 0;
    return u + n + o;
  }

  // Luas efektif terhitung
  double get effectiveLahan {
    final rev = double.tryParse(revisi.replaceAll(',', '.'));
    if (rev != null && rev > 0) return rev;
    return double.tryParse(lahan.replaceAll(',', '.')) ?? 0.0;
  }
}
