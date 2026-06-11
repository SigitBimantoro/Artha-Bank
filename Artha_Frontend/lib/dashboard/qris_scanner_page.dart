import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qris_payment_page.dart';

class QRISScannerPage extends StatefulWidget {
  const QRISScannerPage({super.key});

  @override
  State<QRISScannerPage> createState() => _QRISScannerPageState();
}

class _QRISScannerPageState extends State<QRISScannerPage>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF4D55CC);

  final MobileScannerController _controller = MobileScannerController();
  bool _isHandlingScan = false;

  // Variabel untuk animasi
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller animasi (durasi 2 detik, bolak-balik)
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Mengatur pergerakan dari atas (-1.0) ke bawah (1.0)
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_isHandlingScan) return;

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .firstOrNull;

    if (rawValue == null) return;

    _isHandlingScan = true;
    _controller.stop();

    final qrisData = QrisScanData.fromPayload(rawValue);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => QrisPaymentPage(data: qrisData)),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // Memastikan ukuran frame kotak scan proporsional
    final frameSize = (screenWidth * 0.75).clamp(250.0, 320.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                // 1. Kamera Scanner (Paling Bawah)
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _handleDetect,
                  ),
                ),

                // 2. UI Elements & Overlay di atas Kamera
                Positioned.fill(
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Menghitung posisi kotak frame agar presisi
                        final frameTop = constraints.maxHeight * 0.25;
                        final frameLeft = (constraints.maxWidth - frameSize) / 2;
                        
                        // Menentukan area kotak (lubang transparan)
                        final holeRect = Rect.fromLTWH(
                            frameLeft, frameTop, frameSize, frameSize);

                        return Stack(
                          children: [
                            // Overlay Gelap dengan Lubang Transparan di Tengah
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _OverlayPainter(holeRect),
                              ),
                            ),

                            // Teks "Scan" dan Logo QRIS
                            Positioned(
                              top: constraints.maxHeight * 0.15,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Scan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    'assets/scanqris.png',
                                    height: 26,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),

                            // Kotak Frame Scan dengan Animasi Laser
                            Positioned(
                              top: frameTop,
                              left: frameLeft,
                              child: SizedBox(
                                width: frameSize,
                                height: frameSize,
                                child: Stack(
                                  children: [
                                    // Animasi Gradient & Laser
                                    ClipRect(
                                      child: AnimatedBuilder(
                                        animation: _animation,
                                        builder: (context, child) {
                                          return Align(
                                            alignment:
                                                Alignment(0, _animation.value),
                                            child: child,
                                          );
                                        },
                                        child: Container(
                                          width: frameSize,
                                          height: frameSize * 0.45,
                                          decoration: BoxDecoration(
                                            border: const Border(
                                              top: BorderSide(
                                                color: primaryColor,
                                                width: 3.0,
                                              ),
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                primaryColor.withValues(
                                                    alpha: 0.6),
                                                primaryColor.withValues(
                                                    alpha: 0.1),
                                                Colors.transparent,
                                              ],
                                              stops: const [0.0, 0.6, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Frame Sudut Kustom
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter:
                                            _ScanFramePainter(primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Label Instruksi Bawah
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: constraints.maxHeight * 0.15,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'Posisikan kode QRIS di dalam kotak',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Text(
                  'Pindai QRIS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter baru untuk membuat overlay gelap dengan lubang transparan di tengah
class _OverlayPainter extends CustomPainter {
  final Rect holeRect;

  _OverlayPainter(this.holeRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75) // Warna gelap overlay
      ..style = PaintingStyle.fill;

    // Path yang menutupi seluruh layar
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      
    // Path untuk area yang dilubangi (kotak scan)
    final holePath = Path()..addRect(holeRect);

    // Mengurangi bgPath dengan holePath agar tengahnya bolong
    final path = Path.combine(PathOperation.difference, bgPath, holePath);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.holeRect != holeRect;
  }
}

class _ScanFramePainter extends CustomPainter {
  final Color color;

  _ScanFramePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const corner = 32.0;

    // Sudut Kiri Atas
    canvas.drawLine(Offset.zero, const Offset(corner, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, corner), paint);

    // Sudut Kanan Atas
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - corner, 0),
      paint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, corner), paint);

    // Sudut Kiri Bawah
    canvas.drawLine(Offset(0, size.height), Offset(corner, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - corner),
      paint,
    );

    // Sudut Kanan Bawah
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - corner, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - corner),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}