import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'reset_pin_page.dart'; // Import halaman Reset PIN
import '../auth/auth_page.dart';
import '../auth/forgot_password_page.dart'; // Import halaman Lupa Sandi untuk pop-up
import '../services/api_service.dart';

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

  static const Color primaryColor = Color(0xFF4D55CC);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

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

  Future<void> _openCustomerService() async {
    final message = Uri.encodeComponent('Halo Artha, saya butuh bantuan terkait akun saya.');
    final uri = Uri.parse('https://wa.me/$_customerServiceWhatsAppNumber?text=$message');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka WhatsApp. Pastikan aplikasi terinstal.'), backgroundColor: Colors.red),
      );
    }
  }

  // Menampilkan Pop-Up Verifikasi Sandi untuk Ubah PIN
  void _showPasswordBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa menyesuaikan tinggi saat keyboard muncul
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _PasswordBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(color: primaryColor, fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 25),

                // --- Kartu Profil Utama (Biru) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(30)),
                  child: Column(
                    children: [
                      // --- Kotak Foto Profil ---
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: _photoUrl.isEmpty
                              ? const Center(child: Icon(Icons.person, size: 50, color: primaryColor))
                              : Image.network(
                                  ApiService.resolveMediaUrl(_photoUrl),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.person, size: 50, color: primaryColor)),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- Data User ---
                      Text(_namaLengkap, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Poppins'), textAlign: TextAlign.center),
                      const SizedBox(height: 5),
                      Text(_emailUser, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins')),
                      const SizedBox(height: 5),
                      Text(_nomorHp, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins')),
                      const SizedBox(height: 20),

                      // --- Tombol Ubah Profil ---
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                          if (result == true) _loadProfileData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                        child: const Text('Ubah Profil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // --- Menu Pilihan ---
                _buildMenuButton(
                  title: 'Ubah Kata Sandi',
                  color: primaryColor,
                  icon: Icons.chevron_right,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                  },
                ),
                const SizedBox(height: 15),

                // Panggil Pop-Up saat menu Ubah PIN di-klik
                _buildMenuButton(
                  title: 'Ubah PIN',
                  color: primaryColor,
                  icon: Icons.chevron_right,
                  onTap: _showPasswordBottomSheet,
                ),
                const SizedBox(height: 15),

                _buildMenuButton(
                  title: 'Pusat Bantuan',
                  color: const Color(0xFF25D366),
                  icon: Icons.wechat,
                  onTap: _openCustomerService,
                ),
                const SizedBox(height: 15),

                _buildMenuButton(
                  title: 'Log Out',
                  color: const Color(0xFFE53935),
                  icon: Icons.logout,
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryColor)),
                    );
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

  Widget _buildMenuButton({required String title, required Color color, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            Icon(icon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET POP-UP BOTTOM SHEET (Untuk Input Sandi Sebelum Ubah PIN)
// =========================================================================
class _PasswordBottomSheet extends StatefulWidget {
  const _PasswordBottomSheet();

  @override
  State<_PasswordBottomSheet> createState() => _PasswordBottomSheetState();
}

class _PasswordBottomSheetState extends State<_PasswordBottomSheet> {
  final TextEditingController _passController = TextEditingController();
  bool _obscure = true;
  static const Color primaryColor = Color(0xFF4D55CC);

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  void _submitPassword() {
    if (_passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kata sandi untuk melanjutkan.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Tutup pop-up
    Navigator.pop(context);
    
    // Pindah ke halaman Reset PIN (Membawa password)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPinPage(currentPassword: _passController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom agar form naik/tidak tertutup ketika keyboard muncul
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 30, bottom: bottomPadding + 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Masukan Kata sandi",
              style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
            ),
          ),
          const SizedBox(height: 30),
          
          const Text(
            "Kata sandi",
            style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          
          // Kolom Input Password
          TextFormField(
            controller: _passController,
            obscureText: _obscure,
            autofocus: true,
            style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: primaryColor),
            decoration: InputDecoration(
              hintText: "Masukkan kata sandi",
              hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.5), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: primaryColor),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: primaryColor, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Tombol Lupa Kata Sandi?
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Tutup pop up
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
              },
              child: const Text(
                "Lupa kata sandi?",
                style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Tombol Lanjutkan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text(
                "Lanjutkan",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}