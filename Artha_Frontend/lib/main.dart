import 'package:flutter/material.dart';
import 'pages/splash_page.dart'; // Sesuaikan jika path beda

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artha App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4D55CC)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
