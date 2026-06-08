import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Pastikan path import ini sesuai dengan struktur foldermu
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'ubah_pin_page.dart';
import '../services/api_service.dart';
import '../auth/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String _customerServiceWhatsAppNumber = '6285930217852';

  String _namaLengkap = "Memuat...";
  String _emailUser = "Memuat...";
  String _nomorHp = "Memuat...";
  String _photoUrl = "";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fungsi untuk menarik data dari Backend
  Future<void> _loadProfileData() async {
    final res = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        if (res['success']) {
          final data = res['data']['data'];
          _namaLengkap = data['nama'] ?? 'User Artha';
          _emailUser = data['email'] ?? 'user@artha.com';
          _nomorHp = data['phone_number'] ?? '-';
          _photoUrl = data['photo_url'] ?? '';
        } else {
          _namaLengkap = "Gagal memuat data";
          _emailUser = "-";
          _nomorHp = "-";
          _photoUrl = "";
        }
      });
    }
  }

  // Fungsi untuk membuka WhatsApp Customer Service
  Future<void> _openCustomerService() async {
    final message = Uri.encodeComponent('Halo Artha, saya butuh bantuan terkait akun saya.');
    final uri = Uri.parse(
      'https://wa.me/$_customerServiceWhatsAppNumber?text=$message',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka WhatsApp. Pastikan aplikasi terinstal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                      // --- Kotak Foto Profil ---
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: _photoUrl.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: primaryColor,
                                  ),
                                )
                              : Image.network(
                                  ApiService.resolveMediaUrl(_photoUrl),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: primaryColor,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- Data User ---
                      Text(
                        _namaLengkap,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),

                      Text(
                        _emailUser,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        _nomorHp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Tombol Ubah Profil ---
                      ElevatedButton(
                        onPressed: () async {
                          // Menunggu hasil dari halaman EditProfilePage
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                          // Jika user sukses menyimpan profil (termasuk foto), refresh data
                          if (result == true) {
                            _loadProfileData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
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
                      MaterialPageRoute(
                        builder: (context) => const UbahPinPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                _buildMenuButton(
                  title: 'Pusat Bantuan',
                  color: const Color(0xFF25D366), // Warna Hijau WhatsApp
                  icon: Icons.wechat,
                  onTap: _openCustomerService,
                ),
                const SizedBox(height: 15),

                _buildMenuButton(
                  title: 'Log Out',
                  color: const Color(0xFFE53935), // Warna Merah
                  icon: Icons.logout,
                  onTap: () async {
                    // Tampilkan indikator loading ringan saat logout
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    );

                    await ApiService.logoutProcess();
                    if (!context.mounted) return;

                    // Hapus semua rute sebelumnya (termasuk dialog) dan arahkan ke AuthPage
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(isLoginInitial: true),
                      ),
                      (route) => false,
                    );
                  },
                ),

                const SizedBox(height: 80), // Jarak bawah agar tidak tertutup bottom nav
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