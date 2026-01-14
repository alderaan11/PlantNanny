import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';
import '../devices/devices_page.dart';
import '../settings/settings_page.dart';
import '../settings/server_config_page.dart';
import '../../data/auth/auth_notifier.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: const [
          HomeScreen(),
          DevicesPage(),
          ArrosagePage(),
          ServerConfigPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: const Color(0xFF606C38).withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF606C38),
          unselectedItemColor: Colors.grey,
          onTap: (i) {
            setState(() => _currentIndex = i);
            _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Capteurs'),
            BottomNavigationBarItem(icon: Icon(Icons.water_damage), label: 'Arrosage'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async => await ref.read(authNotifierProvider.notifier).signOut(),
              child: const Icon(Icons.logout),
              tooltip: 'Se déconnecter',
            )
          : null,
    );
  }
}
