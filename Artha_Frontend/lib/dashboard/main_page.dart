import 'package:flutter/material.dart';
import 'home_page.dart';
import 'tracking_page.dart';
import 'transaksi_page.dart';
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

      // --- Tombol Tengah (Transaksi) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransaksiPage()),
          );
        },
        backgroundColor: const Color(0xFF4D55CC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        // --- TANDAIN jpg: FAB Transaksi ---
        child: Image.asset(
          'assets/fab_transaksi.jpg', // GANTI DENGAN NAMA FILE jpg KAMU
          width: 28,
          height: 28,
          // Kalau file jpg belum ada, pakai icon wallet sementara
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.account_balance_wallet, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- Menu Bar Bawah ---
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(
                    imagePath: 'assets/nav_home.jpg', // TANDAIN jpg: HOME
                    fallbackIcon: Icons.home_filled,
                    label: "Home",
                    index: 0,
                  ),
                  _buildNavItem(
                    imagePath:
                        'assets/nav_tracking.jpg', // TANDAIN jpg: TRACKING
                    fallbackIcon: Icons.pie_chart,
                    label: "Tracking",
                    index: 1,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(
                    imagePath:
                        'assets/nav_wishlist.jpg', // TANDAIN jpg: WISHLIST
                    fallbackIcon: Icons.favorite,
                    label: "Wishlist",
                    index: 2,
                  ),
                  _buildNavItem(
                    imagePath: 'assets/nav_profile.jpg', // TANDAIN jpg: PROFILE
                    fallbackIcon: Icons.person,
                    label: "Profile",
                    index: 3,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi cetakan untuk membuat item menu bawah
  Widget _buildNavItem({
    required String imagePath,
    required IconData fallbackIcon,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedIndex == index;
    return MaterialButton(
      minWidth: 80,
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- TANDAIN jpg: Ikon Menu ---
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
            // Opsional: Kalau jpg kamu warnanya abu/hitam dan mau diwarnain biru saat aktif, nyalakan color di bawah:
            // color: isActive ? const Color(0xFF4D55CC) : const Color(0xFF444444),

            // Kalau file jpg belum ada, pakai icon bawaan sementara
            errorBuilder: (context, error, stackTrace) => Icon(
              fallbackIcon,
              color: isActive
                  ? const Color(0xFF4D55CC)
                  : const Color(0xFF444444),
            ),
          ),
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
