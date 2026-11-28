import 'package:flutter/foundation.dart';
import '../models/farmer.dart';
import 'data_service.dart';

enum UserRole {
  tamu,
  petani,
  pengurus,
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserRole _role = UserRole.tamu;
  Farmer? _currentFarmer;
  String? _adminTitle;

  UserRole get role => _role;
  Farmer? get currentFarmer => _currentFarmer;
  String? get adminTitle => _adminTitle;

  bool get isLoggedIn => _role != UserRole.tamu;
  bool get isPetani => _role == UserRole.petani && _currentFarmer != null;
  bool get isPengurus => _role == UserRole.pengurus;

  String get displayName {
    if (isPetani) {
      return _currentFarmer!.nama;
    } else if (isPengurus) {
      return _adminTitle ?? 'Pengurus Poktan Sri Mulyo';
    } else {
      return 'Tamu / Petani Desa Kediren';
    }
  }

  /// Login sebagai Petani spesifik
  void loginAsFarmer(Farmer farmer) {
    _role = UserRole.petani;
    _currentFarmer = farmer;
    _adminTitle = null;
    notifyListeners();
  }

  /// Login menggunakan NIK atau Nama Petani
  Farmer? loginWithQuery(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return null;

    final dataService = DataService();
    // Prioritaskan pencarian NIK tepat
    Farmer? matched = dataService.farmers.cast<Farmer?>().firstWhere(
          (f) => f != null && f.nik.replaceAll(RegExp(r'\s+'), '') == cleanQuery.replaceAll(RegExp(r'\s+'), ''),
          orElse: () => null,
        );

    // Jika tidak ditemukan via NIK, cari via nama
    matched ??= dataService.farmers.cast<Farmer?>().firstWhere(
          (f) => f != null && f.nama.toLowerCase().contains(cleanQuery),
          orElse: () => null,
        );

    if (matched != null) {
      loginAsFarmer(matched);
      return matched;
    }
    return null;
  }

  /// Login sebagai Pengurus Poktan dengan PIN
  bool loginAsAdmin(String pin) {
    final cleanPin = pin.trim();
    // PIN pengurus bisa 1234 atau 2026 atau srimulyo
    if (cleanPin == '1234' || cleanPin == '2026' || cleanPin.toLowerCase() == 'srimulyo') {
      _role = UserRole.pengurus;
      _currentFarmer = null;
      _adminTitle = 'Pengurus Poktan Sri Mulyo';
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Masuk sebagai Tamu
  void loginAsGuest() {
    _role = UserRole.tamu;
    _currentFarmer = null;
    _adminTitle = null;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _role = UserRole.tamu;
    _currentFarmer = null;
    _adminTitle = null;
    notifyListeners();
  }
}
