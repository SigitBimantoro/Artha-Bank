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

  final List<String> _landingImages = [
    'assets/koin.png',
    'assets/savings.png',
    'assets/analisis.png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.jumpToPage(_currentPage + 1);
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WelcomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.fastLinearToSlowEaseIn;

            final slideTween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            final offsetAnimation = animation.drive(slideTween);

            final radiusAnimation = Tween<double>(
              begin: 40.0,
              end: 0.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, childWidget) {
                  return ClipRRect(
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
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildSlide(
                imagePath: _landingImages[0],
                title: 'Kendali Penuh atas\nSetiap Rupiah!',
                descPrefix:
                    'Pantau seluruh pengeluaran Anda secara otomatis dan rapi. ',
                descBold: 'Artha',
                descSuffix:
                    ' mengelompokkan transaksi Anda ke dalam kategori yang jelas, sehingga Anda tahu persis ke mana uang Anda pergi.',
              ),
              _buildSlide(
                imagePath: _landingImages[1],
                title: 'Wujudkan Impian,\nLangkah demi Langkah.',
                descPrefix: 'Dengan fitur ',
                descBold: 'Wishlist',
                descSuffix:
                    ', Anda dapat menjadikan barang impian atau rencana liburan menjadi nyata. Wishlist memungkinkan Anda menyisihkan dana khusus untuk mencapai tujuan Anda.',
              ),
              _buildSlide(
                imagePath: _landingImages[2],
                title: 'Belanja Bijak,\nTabungan Aman.',
                descPrefix:
                    'Atur batas belanja harian Anda untuk menjaga arus kas tetap sehat. Artha akan memberikan ',
                descBold: 'pengingat',
                descSuffix:
                    ' jika pengeluaran Anda mulai mendekati batas anggaran yang telah Anda tentukan sendiri.',
              ),
            ],
          ),

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

  Widget _buildSlide({
    required String imagePath,
    required String title,
    required String descPrefix,
    required String descBold,
    required String descSuffix,
  }) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 95,
                left: 28,
                right: 28,
                bottom: 20,
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

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
                    fontFamily: 'Poppins',
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
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