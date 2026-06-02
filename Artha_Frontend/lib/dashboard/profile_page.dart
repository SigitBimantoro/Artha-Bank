import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'ubah_pin_page.dart';
import '../services/api_service.dart';
import '../auth/auth_page.dart'; // Pastikan path ini mengarah ke halaman loginmu

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Judul Halaman ---
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 25),

                // --- Kartu Profil Utama (Biru) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      // Kotak Foto Profil
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 50, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text(
                        'Reza Hafafi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),

                      const Text(
                        'Hafafi@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),

                      const Text(
                        '08****10',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Ubah Profil
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfilePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                        child: const Text(
                          'Ubah Profil',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // --- Menu Pilihan (List Buttons) ---
                _buildMenuButton(
                  title: 'Ubah Kata Sandi',
                  color: primaryColor,
                  icon: Icons.chevron_right,
                  onTap: () {
                    // Navigasi ke Ubah Sandi
                  },
                ),
                const SizedBox(height: 15),

                _buildMenuButton(
                  title: 'Ubah PIN',
                  color: primaryColor,
                  icon: Icons.chevron_right,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UbahPinPage()),
                    );
                  },
                ),
                const SizedBox(height: 15),

                _buildMenuButton(
                  title: 'Pusat Bantuan',
                  color: const Color(0xFF25D366), // Warna Hijau WhatsApp
                  icon: Icons.wechat, // Placeholder logo chat/WA
                  onTap: () {},
                ),
                const SizedBox(height: 15),

                _buildMenuButton(
                  title: 'Log Out',
                  color: const Color(0xFFE53935), // Warna Merah
                  icon: Icons.logout,
                  onTap: () async {
                    // Proses logout panggil API
                    await ApiService.logoutProcess();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage(isLoginInitial: true)),
                      (route) => false,
                    );
                  },
                ),

                const SizedBox(height: 80), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Pembuat Tombol Menu Seragam
  Widget _buildMenuButton({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}