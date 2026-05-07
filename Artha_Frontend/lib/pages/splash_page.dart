import 'package:flutter/material.dart';
import 'landing_page.dart'; // Ini otomatis memanggil halaman landing_page

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _step = -1;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Animasi naik ke tengah
    setState(() => _step = 0);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Logo mengecil
    setState(() => _step = 1);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Logo geser, teks muncul
    setState(() => _step = 2);

    // Jeda sebentar biar user sempat baca "Artha"
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Otomatis pindah ke halaman LandingPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const double logoLarge = 153.0;
    const double logoSmall = 74.0;
    const double textWidth = 140.0;
    const double gap = 8.0;

    final double groupWidth = logoSmall + gap + textWidth;
    final double centerSmallLeft = (screenWidth - logoSmall) / 2;
    final double groupLeft = (screenWidth - groupWidth) / 2;

    double logoSize = (_step <= 0) ? logoLarge : logoSmall;

    double logoLeft;
    if (_step <= 0) {
      logoLeft = (screenWidth - logoLarge) / 2;
    } else if (_step == 1) {
      logoLeft = centerSmallLeft;
    } else {
      logoLeft = groupLeft;
    }

    double logoTop;
    if (_step == -1) {
      logoTop = screenHeight + 100;
    } else if (_step == 0) {
      logoTop = (screenHeight - logoLarge) / 2;
    } else {
      logoTop = ((screenHeight - logoSmall) / 2) - 30;
    }

    double textLeft = logoLeft + logoSmall + gap;
    double textOpacity = (_step == 2) ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // TEKS "rtha"
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            left: textLeft,
            top: logoTop,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: textOpacity,
              child: SizedBox(
                width: textWidth,
                height: logoSmall,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'rtha',
                    style: TextStyle(
                      color: Color(0xFF4D55CC),
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // LOGO "Artha" Gambar JPG
          AnimatedPositioned(
            duration: Duration(milliseconds: (_step == 0) ? 800 : 600),
            curve: (_step == 0) ? Curves.easeOutBack : Curves.easeInOut,
            left: logoLeft,
            top: logoTop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: logoSize,
              height: logoSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(logoSize * 0.25),
                child: Image.asset(
                  'assets/artha.jpg',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
