import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/farmer.dart';
import '../models/kloter.dart';
import '../models/penggarap.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Farmer> _farmers = [];
  List<Penggarap> _penggaraps = [];
  bool _isLoading = false;
  DateTime? _lastSync;
  String _syncSource = 'Offline Seed';

  List<Farmer> get farmers => _farmers;
  List<Penggarap> get penggaraps => _penggaraps;
  bool get isLoading => _isLoading;
  DateTime? get lastSync => _lastSync;
  String get syncSource => _syncSource;

  // Inisialisasi: Load data seed dari assets
  Future<void> init() async {
    if (_farmers.isNotEmpty) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/farmers_seed.json');
      final List<dynamic> list = json.decode(jsonString);
      _farmers = list.map((item) => Farmer.fromJson(item)).toList();
      _syncSource = 'Data Lokal (${_farmers.length} Petani)';
      _lastSync = DateTime.now();

      // Load Penggarap seed
      try {
        final penggarapStr = await rootBundle.loadString('assets/data/penggarap_seed.json');
        final List<dynamic> pList = json.decode(penggarapStr);
        _penggaraps = pList.map((item) => Penggarap.fromJson(item)).toList();
      } catch (_) {}
    } catch (e) {
      // Fallback data jika asset belum siap
      _farmers = _generateFallbackSeed();
      _syncSource = 'Data Bawaan Poktan';
    }
  }

  // Live Sync dari Google Sheets GViz API
  Future<bool> syncOnline() async {
    _isLoading = true;
    try {
      final url = Uri.parse(
        'https://docs.google.com/spreadsheets/d/1c7R1klPcFSZ7W1PLaZyayZxBUOrVyLh-Lwc24Cf6CEY/gviz/tq?tqx=out:json&sheet=ALOKASI%20PEMBAGIAN&range=A2:N245&headers=0',
      );
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final text = await response.transform(utf8.decoder).join();
        // Bersihkan pembungkus google.visualization.Query.setResponse(...)
        final cleanJson = text.replaceAll(RegExp(r'^[^{]*'), '').replaceAll(RegExp(r'[^}]*$'), '');
        final data = json.decode(cleanJson);

        if (data['table'] != null && data['table']['rows'] is List) {
          final List rows = data['table']['rows'];
          final List<Farmer> parsed = [];

          for (final r in rows) {
            final c = r['c'] as List?;
            if (c == null) continue;

            String getCell(int idx) {
              if (idx >= c.length || c[idx] == null) return '';
              final cell = c[idx];
              if (cell['f'] != null) return cell['f'].toString().trim();
              if (cell['v'] != null) return cell['v'].toString().trim();
              return '';
            }

            final no = getCell(0);
            final nik = getCell(1).replaceAll("'", '');
            final nama = getCell(2).toUpperCase();

            if (nama.isEmpty && nik.isEmpty) continue;
            if (nik == 'NIK' || nama == 'NAMA') continue;

            final lahan = getCell(3);
            final revisi = getCell(4);
            final status = getCell(5);
            final urea = getCell(6);
            final npk = getCell(7);
            final organik = getCell(8);
            final ureaSak = getCell(9);
            final npkSak = getCell(10);
            final organikSak = getCell(11);
            final uang = getCell(12);
            final ket = getCell(13);

            parsed.add(Farmer(
              no: no,
              nik: nik,
              nama: nama,
              lahan: lahan,
              revisi: revisi,
              status: status.isEmpty ? 'BELUM AMBIL' : status,
              urea: urea,
              npk: npk,
              organik: organik,
              ureaSak: ureaSak,
              npkSak: npkSak,
              organikSak: organikSak,
              uang: uang,
              ket: ket,
            ));
          }

          if (parsed.isNotEmpty) {
            _farmers = parsed;
            _lastSync = DateTime.now();
            _syncSource = 'Live Google Sheets (${_farmers.length} Petani)';
            _isLoading = false;
            return true;
          }
        }
      }
    } catch (_) {
      // Offline fallback aman
    }
    _isLoading = false;
    return false;
  }

  // Cari Petani berdasarkan Nama atau NIK
  List<Farmer> search(String query, {String statusFilter = 'SEMUA'}) {
    final q = query.trim().toLowerCase();
    return _farmers.where((f) {
      final matchesQuery = q.isEmpty ||
          f.nama.toLowerCase().contains(q) ||
          f.nik.contains(q) ||
          f.no.contains(q);

      if (!matchesQuery) return false;

      if (statusFilter == 'SEMUA') return true;
      if (statusFilter == 'SUDAH') return f.isSudahAmbil;
      if (statusFilter == 'BELUM') return f.isBelumAmbil;
      if (statusFilter == 'KTP') return f.hasSetorKtp;
      return true;
    }).toList();
  }

  // Statistik Realisasi Penebusan
  Map<String, dynamic> getStats() {
    final total = _farmers.length;
    final sudah = _farmers.where((f) => f.isSudahAmbil).length;
    final belum = total - sudah;

    int totalSakUrea = 0;
    int totalSakNpk = 0;
    int totalSakOrganik = 0;

    for (final f in _farmers) {
      if (f.isSudahAmbil) {
        totalSakUrea += int.tryParse(f.ureaSak) ?? 0;
        totalSakNpk += int.tryParse(f.npkSak) ?? 0;
        totalSakOrganik += int.tryParse(f.organikSak) ?? 0;
      }
    }

    final persen = total == 0 ? 0.0 : (sudah / total) * 100;

    return {
      'total': total,
      'sudah': sudah,
      'belum': belum,
      'persen': persen,
      'sakUrea': totalSakUrea,
      'sakNpk': totalSakNpk,
      'sakOrganik': totalSakOrganik,
      'totalSak': totalSakUrea + totalSakNpk + totalSakOrganik,
    };
  }

  // Bagi Kloter 1 s/d 10 (per 20 petani)
  List<KloterGroup> getKloters() {
    final List<KloterGroup> list = [];
    const int perKloter = 20;
    final totalKloter = (_farmers.length / perKloter).ceil();

    final tanggalList = [
      'Senin, 02 Nov 2026',
      'Selasa, 03 Nov 2026',
      'Rabu, 04 Nov 2026',
      'Kamis, 05 Nov 2026',
      'Jumat, 06 Nov 2026',
      'Sabtu, 07 Nov 2026',
      'Senin, 09 Nov 2026',
      'Selasa, 10 Nov 2026',
      'Rabu, 11 Nov 2026',
      'Kamis, 12 Nov 2026',
    ];

    for (int i = 0; i < (totalKloter == 0 ? 1 : totalKloter); i++) {
      final start = i * perKloter;
      final end = (start + perKloter < _farmers.length) ? start + perKloter : _farmers.length;
      final members = (start < _farmers.length) ? _farmers.sublist(start, end) : <Farmer>[];
      final tgl = i < tanggalList.length ? tanggalList[i] : 'Sesuai Pengumuman';

      list.add(KloterGroup(
        nomor: i + 1,
        nama: 'Kloter ${i + 1}',
        tanggal: tgl,
        lokasi: 'Kios Resmi Poktan Sri Mulyo, Kediren',
        status: (i < 8) ? 'Selesai Distribusi' : 'Jadwal Penebusan',
        members: members,
      ));
    }
    return list;
  }

  List<Farmer> _generateFallbackSeed() {
    return [
      Farmer(
        no: '1',
        nik: '3520032402810001',
        nama: 'AGUS JAENURI',
        lahan: '0.32',
        status: 'SUDAH AMBIL, SETOR KTP',
        urea: '80',
        npk: '75',
        organik: '59',
        ureaSak: '1',
        npkSak: '1',
        organikSak: '1',
      ),
      Farmer(
        no: '2',
        nik: '3520030510650001',
        nama: 'WIR SADIRUN',
        lahan: '0.41',
        status: 'SUDAH AMBIL, SURAT KUASA',
        urea: '102',
        npk: '96',
        organik: '76',
        ureaSak: '2',
        npkSak: '2',
        organikSak: '2',
      ),
    ];
  }
}
