import 'package:flutter/material.dart';
// Import file splash_page karena ini halaman pertama yang kita mau munculin
import 'pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Menghilangkan tulisan 'debug' di pojok kanan atas
      title: 'Artha App',
      theme: ThemeData(
        // Kita set font default ke Poppins karena desain Figma kamu pakai Poppins
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4D55CC)),
        useMaterial3: true,
      ),
      // Di sini kita tentukan halaman awal aplikasi adalah SplashPage
      home: const SplashPage(),
    );
  }
}
