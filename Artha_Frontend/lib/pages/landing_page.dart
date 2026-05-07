import 'package:flutter/material.dart';
import 'welcome_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk berpindah ke slide selanjutnya
  void _nextPage() {
    if (_currentPage < 2) {
      // Pindah slide secara INSTAN tanpa animasi geser
      _pageController.jumpToPage(_currentPage + 1);
    } else {
      // Transisi dari BAWAH ke ATAS dengan ujung melengkung yang mulus
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          // Durasi dipanjangkan sedikit agar efek "smooth" / perlambatannya lebih terasa
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WelcomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 1. Setup Animasi Slide (Naik dari bawah)
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            // Gunakan curve ini untuk efek awal cepat, tapi sangat mulus & pelan saat mau berhenti
            const curve = Curves.fastLinearToSlowEaseIn;

            var slideTween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(slideTween);

            // 2. Setup Animasi Lengkungan (Border Radius dari 40 ke 0)
            var radiusAnimation = Tween<double>(
              begin: 40.0,
              end: 0.0,
            ).animate(CurvedAnimation(parent: animation, curve: curve));

            // 3. Gabungkan transisi geser dengan perubahan bentuk sudut
            return SlideTransition(
              position: offsetAnimation,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, childWidget) {
                  return ClipRRect(
                    // Ujung kiri atas dan kanan atas melengkung lalu perlahan jadi kotak
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radiusAnimation.value),
                    ),
                    child: childWidget,
                  );
                },
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // PAGE VIEW UNTUK 3 SLIDE
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // Slide 1
              _buildSlide(
                title: 'Kendali Penuh atas\nSetiap Rupiah!',
                descPrefix:
                    'Pantau seluruh pengeluaran Anda secara otomatis dan rapi. ',
                descBold: 'Artha',
                descSuffix:
                    ' mengelompokkan transaksi Anda ke dalam kategori yang jelas, sehingga Anda tahu persis ke mana uang Anda pergi.',
              ),
              // Slide 2
              _buildSlide(
                title: 'Wujudkan Impian,\nLangkah demi Langkah.',
                descPrefix: 'Dengan fitur ',
                descBold: 'Wishlist',
                descSuffix:
                    ', Anda dapat menjadikan barang impian atau rencana liburan menjadi nyata. Wishlist memungkinkan Anda menyisihkan dana khusus untuk mencapai tujuan Anda.',
              ),
              // Slide 3
              _buildSlide(
                title: 'Belanja Bijak,\nTabungan Aman.',
                descPrefix:
                    'Atur batas belanja harian Anda untuk menjaga arus kas tetap sehat. Artha akan memberikan ',
                descBold: 'pengingat',
                descSuffix:
                    ' jika pengeluaran Anda mulai mendekati batas anggaran yang telah Anda tentukan sendiri.',
              ),
            ],
          ),

          // DOTS INDICATOR
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => _buildDot(isActive: index == _currentPage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Indikator Titik (Dots)
  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF211C84) : const Color(0xFFB5A8D5),
        shape: BoxShape.circle,
      ),
    );
  }

  // Komponen pembangun untuk Slide 1, 2, dan 3
  Widget _buildSlide({
    required String title,
    required String descPrefix,
    required String descBold,
    required String descSuffix,
  }) {
    return Column(
      children: [
        const Expanded(flex: 1, child: SizedBox()),
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF4D55CC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(90),
                topRight: Radius.circular(90),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 50,
              left: 32,
              right: 32,
              bottom: 40,
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: descPrefix),
                      TextSpan(
                        text: descBold,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: descSuffix),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF4D55CC),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
