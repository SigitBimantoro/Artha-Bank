import 'package:flutter/material.dart';
import '../auth/auth_page.dart'; // Sesuaikan path ini dengan struktur folder kamu

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Fungsi khusus untuk membuat animasi transisi Fade (Memudar)
  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kita gunakan warna dominan bagian bawah sebagai warna dasar
    const Color baseColor = Color(0xFF4D55CC); // Biru/Ungu bawaan aplikasi

    return Scaffold(
      backgroundColor: baseColor,
      body: Stack(
        children: [
          // 1. Gambar Gradient HANYA di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/GRADIENT.jpg',
              fit: BoxFit
                  .fitWidth, // Mengikuti lebar layar, tidak dipaksa full screen
            ),
          ),

          // 2. Efek Fade (Blend) agar batas bawah gambar menyatu mulus dengan warna dasar
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Sesuaikan titik mulai transisi (0.3 berarti mulai dari 30% tinggi layar)
                  stops: const [0.3, 0.6],
                  colors: [
                    Colors.transparent, // Bagian atas biarkan gambar terlihat
                    baseColor, // Bagian bawah tertutup warna solid
                  ],
                ),
              ),
            ),
          ),

          // 3. Konten Teks dan Tombol (Rata Kiri, Posisi di Bawah)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pantau, Tabung,\nWujudkan!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Solusi cerdas untuk mengelola pengeluaran\nharian dan meraih setiap target finansial\nimpian Anda dalam satu aplikasi yang\nterintegrasi dan mudah digunakan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          _fadeRoute(const AuthPage(isLoginInitial: false)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(
                          0xFF2A2E80,
                        ), // Warna teks tombol
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Wujudkan Impianmu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          _fadeRoute(const AuthPage(isLoginInitial: true)),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: 'Sudah punya akun? '),
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
