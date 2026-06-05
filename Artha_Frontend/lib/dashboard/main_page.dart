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

      // --- 1. TOMBOL QRIS MENGAMBANG DI TENGAH ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Arahkan ke halaman Kamera Scanner QRIS nanti
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Membuka Kamera QRIS..."), backgroundColor: primaryColor),
          );
        },
        backgroundColor: primaryColor,
        elevation: 4,
        // Membuat bentuknya kotak melengkung (rounded square) persis seperti desainmu
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
        ),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
      ),
      
      // Mengunci posisi tombol mengambang tepat di tengah bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- 2. MENU BAR BAWAH WARNA PUTIH DENGAN CEKUNGAN ---
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(), // Membuat cekungan untuk tombol QRIS
        notchMargin: 8.0, // Jarak ruang antara tombol QRIS dan bar putih
        elevation: 15,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Sisi Kiri (Home & Tracking) ---
              Row(
                children: [
                  _buildNavItem(icon: Icons.home_filled, label: "Home", index: 0),
                  _buildNavItem(icon: Icons.pie_chart, label: "Tracking", index: 1),
                ],
              ),
              
              // --- Teks kecil "QRIS" di bawah tombol tengah ---
              const Padding(
                padding: EdgeInsets.only(top: 35),
                child: Text(
                  "QRIS",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins'
                  ),
                ),
              ),

              // --- Sisi Kanan (Wishlist & Profile) ---
              Row(
                children: [
                  _buildNavItem(icon: Icons.savings, label: "Wishlist", index: 2),
                  _buildNavItem(icon: Icons.person, label: "Profile", index: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK ITEM MENU NAVIGASI ---
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedIndex == index;
    const Color primaryColor = Color(0xFF4D55CC);
    
    return MaterialButton(
      minWidth: 75,
      onPressed: () => setState(() => _selectedIndex = index),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            // Jika aktif warna ungu, jika tidak warna abu-abu
            color: isActive ? primaryColor : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? primaryColor : Colors.grey.shade600,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}