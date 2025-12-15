import 'package:flutter/material.dart';
import 'home_page.dart';
import 'add_destination_screen.dart';
import 'peta_page.dart';
import 'statistik_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final GlobalKey<_HomePageRefreshState> _homeKey =
      GlobalKey<_HomePageRefreshState>();
  final GlobalKey<_PetaPageRefreshState> _petaKey =
      GlobalKey<_PetaPageRefreshState>();

  List<Widget> get _pages => [
        HomePageRefresh(key: _homeKey),
        const AddDestinationScreen(),
        PetaPageRefresh(key: _petaKey),
        const StatistikPage(),
        const ProfilePage(),
      ];

  void _onNavItemTapped(int index) async {
    if (index == 1) {
      // Jika tap "Tambah", navigate ke halaman tambah dan tunggu hasil
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddDestinationScreen()),
      );

      // Jika berhasil menambah, refresh home dan peta
      if (result == true) {
        _homeKey.currentState?.refresh();
        _petaKey.currentState?.refresh();
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Beranda'),
                _buildNavItem(1, Icons.add_circle, 'Tambah'),
                _buildNavItem(2, Icons.map_rounded, 'Peta'),
                _buildNavItem(3, Icons.bar_chart_rounded, 'Statistik'),
                _buildNavItem(4, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper untuk HomePage dengan refresh capability
class HomePageRefresh extends StatefulWidget {
  const HomePageRefresh({Key? key}) : super(key: key);

  @override
  State<HomePageRefresh> createState() => _HomePageRefreshState();
}

class _HomePageRefreshState extends State<HomePageRefresh> {
  final GlobalKey<State> _homePageKey = GlobalKey<State>();

  void refresh() {
    // Trigger rebuild dengan setState
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(key: _homePageKey);
  }
}

// Wrapper untuk PetaPage dengan refresh capability
class PetaPageRefresh extends StatefulWidget {
  const PetaPageRefresh({Key? key}) : super(key: key);

  @override
  State<PetaPageRefresh> createState() => _PetaPageRefreshState();
}

class _PetaPageRefreshState extends State<PetaPageRefresh> {
  final GlobalKey<State> _petaPageKey = GlobalKey<State>();

  void refresh() {
    // Trigger rebuild dengan setState
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PetaPage(key: _petaPageKey);
  }
}
