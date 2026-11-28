import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/theme.dart';
import 'screens/cek_petani_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/tanya_tani_screen.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final dataService = DataService();
  await dataService.init();

  runApp(const PoktanSriMulyoApp());
}

class PoktanSriMulyoApp extends StatefulWidget {
  const PoktanSriMulyoApp({super.key});

  @override
  State<PoktanSriMulyoApp> createState() => _PoktanSriMulyoAppState();
}

class _PoktanSriMulyoAppState extends State<PoktanSriMulyoApp> {
  final AuthService _authService = AuthService();
  bool _enteredApp = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        final showLogin = !_enteredApp && !_authService.isLoggedIn;

        return MaterialApp(
          title: 'Poktan Sri Mulyo',
          debugShowCheckedModeBanner: false,
          theme: GojekTheme.lightTheme,
          home: showLogin
              ? LoginScreen(
                  onLoginSuccess: () {
                    setState(() {
                      _enteredApp = true;
                    });
                  },
                )
              : const MainNavigationShell(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onTabChange: _onTabTapped),
      const CekPetaniScreen(),
      const TanyaTaniScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: GojekColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_filled, 'Beranda'),
                _buildNavItem(1, Icons.agriculture, 'GoTani'),
                _buildNavItem(2, Icons.psychology, 'Tanya Tani'),
                _buildNavItem(3, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? GojekColors.primary : GojekColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? GojekColors.primary : GojekColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
