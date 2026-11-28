import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../models/farmer.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();

  Farmer? _selectedFarmer;
  List<Farmer> _autocompleteResults = [];
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _errorMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nikController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (val.trim().isEmpty) {
      setState(() {
        _autocompleteResults = [];
        _selectedFarmer = null;
        _errorMessage = null;
      });
      return;
    }

    final query = val.trim().toLowerCase();
    final results = _dataService.farmers.where((f) {
      final nameMatches = f.nama.toLowerCase().contains(query);
      final nikMatches = f.nik.contains(query);
      return nameMatches || nikMatches;
    }).take(5).toList();

    setState(() {
      _autocompleteResults = results;
      _errorMessage = null;
    });
  }

  void _selectFarmer(Farmer f) {
    setState(() {
      _selectedFarmer = f;
      _nikController.text = f.nama;
      _autocompleteResults = [];
      _errorMessage = null;
    });
  }

  void _loginAsPetani() {
    if (_selectedFarmer != null) {
      _authService.loginAsFarmer(_selectedFarmer!);
      _onSuccess();
      return;
    }

    final query = _nikController.text.trim();
    if (query.isEmpty) {
      setState(() => _errorMessage = 'Silakan masukkan NIK atau pilih nama petani');
      return;
    }

    final farmer = _authService.loginWithQuery(query);
    if (farmer != null) {
      _onSuccess();
    } else {
      setState(() {
        _errorMessage = 'Data petani tidak ditemukan. Periksa NIK atau pilih langsung dari daftar.';
      });
    }
  }

  void _loginAsPengurus() {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Silakan masukkan PIN Pengurus');
      return;
    }

    final ok = _authService.loginAsAdmin(pin);
    if (ok) {
      _onSuccess();
    } else {
      setState(() => _errorMessage = 'PIN Pengurus salah! Gunakan PIN default 1234');
    }
  }

  void _loginAsGuest() {
    _authService.loginAsGuest();
    _onSuccess();
  }

  void _onSuccess() {
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showFarmerPickerBottomSheet() {
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
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: GojekColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Akun Petani',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GojekColors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GojekColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${list.length} Petani',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GojekColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Ketik nama petani atau NIK...',
                        prefixIcon: const Icon(Icons.search, color: GojekColors.primary),
                        filled: true,
                        fillColor: GojekColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => filter = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (c, i) => const Divider(height: 1, color: GojekColors.border),
                      itemBuilder: (ctx, i) {
                        final f = list[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: GojekColors.primarySoft,
                            child: Text(
                              f.nama.isNotEmpty ? f.nama[0] : 'P',
                              style: const TextStyle(color: GojekColors.primaryDark, fontWeight: FontWeight.w900),
                            ),
                          ),
                          title: Text(
                            f.nama,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: GojekColors.textPrimary),
                          ),
                          subtitle: Text(
                            'NIK: ${f.maskedNik} • Lahan: ${f.effectiveLahan} Ha',
                            style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: GojekColors.primary),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _selectFarmer(f);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.close, color: GojekColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          TextButton(
            onPressed: _loginAsGuest,
            child: const Text(
              'Lewati',
              style: TextStyle(color: GojekColors.textSecondary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo & Icon SRI MULYO
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: GojekColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: GojekColors.primary,
                            child: const Center(
                              child: Text(
                                'SRI\nMULYO',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'POKTAN SRI MULYO',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: GojekColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Desa Kediren, Kec. Lembeyan, Kab. Magetan',
                      style: TextStyle(fontSize: 12, color: GojekColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Tab Selector Gojek style
              Container(
                decoration: BoxDecoration(
                  color: GojekColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GojekColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: GojekColors.primary,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: GojekColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.agriculture, size: 20),
                      text: 'Petani Anggota',
                    ),
                    Tab(
                      icon: Icon(Icons.admin_panel_settings, size: 20),
                      text: 'Pengurus Poktan',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Error banner if any
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: GojekColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GojekColors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: GojekColors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: GojekColors.red, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tab content
              SizedBox(
                height: 330,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPetaniTab(),
                    _buildPengurusTab(),
                  ],
                ),
              ),

              // Footer help & WhatsApp
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: '085655620979'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nomor WA Pengurus (0856-5562-0979) berhasil disalin!'),
                            backgroundColor: Color(0xFF25D366),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 18),
                      label: const Text(
                        'Bantuan Login: Hubungi WA Pengurus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF25D366),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Poktan Sri Mulyo Mobile • Gojek Green Design',
                      style: TextStyle(fontSize: 10, color: GojekColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetaniTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Masuk dengan NIK / Nama Petani',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ketik NIK 16 digit, atau ketik nama petani untuk melihat data alokasi.',
          style: TextStyle(fontSize: 12, color: GojekColors.textSecondary),
        ),
        const SizedBox(height: 12),

        // Input TextField
        TextField(
          controller: _nikController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Contoh: 352003... atau MARJUKI',
            prefixIcon: const Icon(Icons.badge_outlined, color: GojekColors.primary),
            suffixIcon: _nikController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _nikController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: GojekColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: GojekColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: GojekColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: GojekColors.primary, width: 2),
            ),
          ),
        ),

        // Autocomplete suggestions
        if (_autocompleteResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GojekColors.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _autocompleteResults.map((f) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.person, color: GojekColors.primary, size: 18),
                  title: Text(f.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  subtitle: Text('NIK: ${f.maskedNik}', style: const TextStyle(fontSize: 11)),
                  onTap: () => _selectFarmer(f),
                );
              }).toList(),
            ),
          ),

        // Selected Farmer Card preview
        if (_selectedFarmer != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GojekColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GojekColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: GojekColors.primaryDark, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFarmer!.nama,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GojekColors.primaryDark),
                      ),
                      Text(
                        'Lahan: ${_selectedFarmer!.effectiveLahan} Ha • Urea: ${_selectedFarmer!.urea} kg • NPK: ${_selectedFarmer!.npk} kg',
                        style: const TextStyle(fontSize: 11, color: GojekColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 10),

        // Quick picker button
        OutlinedButton.icon(
          onPressed: _showFarmerPickerBottomSheet,
          style: OutlinedButton.styleFrom(
            foregroundColor: GojekColors.primaryDark,
            side: const BorderSide(color: GojekColors.primary, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.list_alt, size: 18),
          label: const Text(
            '📋 Pilih Langsung dari 195 Petani',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),

        const Spacer(),

        // Submit button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _loginAsPetani,
            style: ElevatedButton.styleFrom(
              backgroundColor: GojekColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              'Masuk Sekarang',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPengurusTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Login Pengurus / Admin Poktan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GojekColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'Khusus Ketua, Sekretaris, dan Bendahara Kelompok Tani Sri Mulyo.',
          style: TextStyle(fontSize: 12, color: GojekColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // PIN Input
        TextField(
          controller: _pinController,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Masukkan 4 digit PIN Pengurus',
            prefixIcon: const Icon(Icons.lock_outline, color: GojekColors.primary),
            suffixIcon: IconButton(
              icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, color: GojekColors.textSecondary),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
            ),
            filled: true,
            fillColor: GojekColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: GojekColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: GojekColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: GojekColors.primary, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Hint box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GojekColors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GojekColors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: GojekColors.blue, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PIN Default Pengurus: 1234 (dapat diubah sesuai rapat kelompok tani).',
                  style: TextStyle(color: GojekColors.blueDark, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Submit button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _loginAsPengurus,
            style: ElevatedButton.styleFrom(
              backgroundColor: GojekColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              'Masuk sebagai Pengurus',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}
