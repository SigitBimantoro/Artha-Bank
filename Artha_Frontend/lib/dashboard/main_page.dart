import 'package:flutter/material.dart';
import 'home_page.dart';
import 'tracking_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TrackingPage(),
    const WishlistPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _pages[_selectedIndex],

      // --- Menu Bar Bawah (Tombol Tengah Ungu & Notch Sudah Dihapus Total) ---
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8, // Memberikan sedikit efek bayangan di atas bar bawah
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Membagi rata keempat menu secara presisi
            children: <Widget>[
              _buildNavItem(
                imagePath: 'assets/nav_home.jpg',
                fallbackIcon: Icons.home_filled,
                label: "Home",
                index: 0,
              ),
              _buildNavItem(
                imagePath: 'assets/nav_tracking.jpg',
                fallbackIcon: Icons.pie_chart,
                label: "Tracking",
                index: 1,
              ),
              _buildNavItem(
                imagePath: 'assets/nav_wishlist.jpg',
                fallbackIcon: Icons.favorite,
                label: "Wishlist",
                index: 2,
              ),
              _buildNavItem(
                imagePath: 'assets/nav_profile.jpg',
                fallbackIcon: Icons.person,
                label: "Profile",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi pembantu untuk membuat item menu navigasi bawah
  Widget _buildNavItem({
    required String imagePath,
    required IconData fallbackIcon,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedIndex == index;
    return MaterialButton(
      minWidth: 60,
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) => Icon(
              fallbackIcon,
              color: isActive
                  ? const Color(0xFF4D55CC)
                  : const Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF4D55CC)
                  : const Color(0xFF444444),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}