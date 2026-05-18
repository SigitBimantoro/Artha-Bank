import 'package:flutter/material.dart';
import 'landing_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> logoTop;
  late Animation<double> logoLeft;
  late Animation<double> textOpacity;
  late Animation<double> textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

  
    const logoSize = 74.0; 
    const textWidth = 140.0;
    const gap = 10.0;
    
    
    final totalContentWidth = logoSize + gap + textWidth;
    
    final centerLeftLogo = (screenWidth - logoSize) / 2; 
   final finalLeftLogo = ((screenWidth - totalContentWidth) / 2) + 15; 
    final centerTop = (screenHeight - logoSize) / 2;

   
    logoTop = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: screenHeight + 50, end: centerTop)
            .chain(CurveTween(curve: Curves.easeOutBack)), 
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ConstantTween(centerTop),
        weight: 50,
      ),
    ]).animate(_controller);

    
    logoLeft = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(centerLeftLogo),
        weight: 60, 
      ),
      TweenSequenceItem(
        tween: Tween(begin: centerLeftLogo, end: finalLeftLogo)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
    ]).animate(_controller);

   
    textOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 65),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_controller);

   
    textSlide = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(30.0), weight: 65), 
      TweenSequenceItem(
        tween: Tween(begin: 30.0, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          const logoSize = 74.0;
          const gap = 10.0;
          
          return Stack(
            children: [
              // LOGO
              Positioned(
                left: logoLeft.value,
                top: logoTop.value,
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    'assets/artha.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              
              Positioned(
                
                left: logoLeft.value + logoSize + gap + textSlide.value,
                top: logoTop.value + 4, 
                child: Opacity(
                  opacity: textOpacity.value,
                  child: const Text(
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
            ],
          );
        },
      ),
    );
  }
}