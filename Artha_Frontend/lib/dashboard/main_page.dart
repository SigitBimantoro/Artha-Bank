import 'package:flutter/material.dart';
import 'home_page.dart';
import 'tracking_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  final int initialIndex; 
  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  // Inisialisasi index berdasarkan parameter yang dikirim
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const HomePage(),
    const TrackingPage(),
    const WishlistPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _pages[_selectedIndex],

      // --- MENU BAR BAWAH ---
      bottomNavigationBar: Container(
        color: primaryColor, // Background Navbar Ungu
        child: SafeArea(
          child: SizedBox(
            height: 70, // Tinggi Navbar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildNavItem(icon: Icons.home_filled, label: "Home", index: 0),
                _buildNavItem(icon: Icons.pie_chart, label: "Tracking", index: 1),
                _buildNavItem(icon: Icons.savings, label: "Wishlist", index: 2), // Icon Babi
                _buildNavItem(icon: Icons.person, label: "Profile", index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DESAIN ITEM NAVBAR (LENGKUNGAN KUBAH PUTIH) ---
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Align(
          alignment: Alignment.bottomCenter, 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 75, 
            height: double.infinity, 
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(35), 
                topRight: Radius.circular(35), 
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? const Color(0xFF4D55CC) : Colors.white,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? const Color(0xFF4D55CC) : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}