import 'package:flutter/material.dart';
import 'dart:math'; // Diperlukan untuk perhitungan lingkaran grafik (pi)

// --- KELAS MODEL DATA UNTUK GRAFIK ---
class ChartData {
  final Color color;
  final double value;
  final String label;

  ChartData({required this.color, required this.value, required this.label});
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  // Melacak tab yang sedang aktif (0: Mingguan, 1: Bulanan, 2: Tahunan)
  int _selectedTab = 0;

  // --- DATA DUMMY MINGGUAN (Kuning & Merah Mendominasi) ---
  final List<ChartData> _mingguanData = [
    ChartData(color: const Color(0xFFFFCC00), value: 200, label: 'Rp200rb'),
    ChartData(color: const Color(0xFFFF383C), value: 150, label: 'Rp150rb'),
    ChartData(color: const Color(0xFF0088FF), value: 40, label: 'Rp40rb'),
    ChartData(color: const Color(0xFF19D759), value: 40, label: 'Rp40rb'),
    ChartData(color: const Color(0xFFFF8D28), value: 13, label: 'Rp13rb'),
  ];

  // --- DATA DUMMY BULANAN (Biru & Hijau Mendominasi) ---
  final List<ChartData> _bulananData = [
    ChartData(color: const Color(0xFFFFCC00), value: 150, label: 'Rp150rb'),
    ChartData(color: const Color(0xFFFF383C), value: 200, label: 'Rp200rb'),
    ChartData(
      color: const Color(0xFF0088FF),
      value: 800,
      label: 'Rp800rb',
    ), // Biru paling besar
    ChartData(color: const Color(0xFF19D759), value: 400, label: 'Rp400rb'),
    ChartData(color: const Color(0xFFFF8D28), value: 100, label: 'Rp100rb'),
  ];

  // --- DATA DUMMY TAHUNAN (Merah & Orange Mendominasi) ---
  final List<ChartData> _tahunanData = [
    ChartData(color: const Color(0xFFFFCC00), value: 2, label: 'Rp2jt'),
    ChartData(
      color: const Color(0xFFFF383C),
      value: 15,
      label: 'Rp15jt',
    ), // Merah paling besar
    ChartData(color: const Color(0xFF0088FF), value: 4, label: 'Rp4jt'),
    ChartData(color: const Color(0xFF19D759), value: 1, label: 'Rp1jt'),
    ChartData(color: const Color(0xFFFF8D28), value: 12, label: 'Rp12jt'),
  ];

  // Getter untuk mengambil data sesuai tab aktif
  List<ChartData> get _currentData {
    if (_selectedTab == 0) return _mingguanData;
    if (_selectedTab == 1) return _bulananData;
    return _tahunanData;
  }

  // Getter untuk mengganti judul kartu grafik
  String get _currentTitle {
    if (_selectedTab == 0) return 'Minggu-1';
    if (_selectedTab == 1) return 'Bulan Ini';
    return 'Tahun Ini';
  }

  // Fungsi cetakan untuk tombol Tab
  Widget _buildTab(String title, int index) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF4D55CC) : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  // Fungsi cetakan untuk daftar Legenda Warna
  Widget _buildLegendItem(Color color, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Judul Halaman ---
              const Text(
                'Tracking keuangan',
                style: TextStyle(
                  color: Color(0xFF4D55CC),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),

              // --- Teks yang sudah diubah khusus halaman Tracking ---
              const Text(
                'Evaluasi riwayat pengeluaranmu di sini. Jadikan bahan pertimbangan untuk lebih hemat!',
                style: TextStyle(
                  color: Color(0xFF4D55CC),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),

              // --- Tab Selector ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D55CC),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTab('Mingguan', 0),
                    _buildTab('Bulanan', 1),
                    _buildTab('Tahunan', 2),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Kartu Grafik ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D55CC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Kartu Dinamis
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentTitle,
                        key: ValueKey<String>(_currentTitle),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Area Grafik dan Legenda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. Grafik Donat Custom dengan ANIMASI
                        TweenAnimationBuilder<double>(
                          key: ValueKey<int>(_selectedTab),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return SizedBox(
                              width: 140,
                              height: 140,
                              child: CustomPaint(
                                painter: DonutChartPainter(
                                  _currentData,
                                  animationValue: value,
                                ),
                              ),
                            );
                          },
                        ),

                        // 2. Daftar Legenda Dinamis
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _currentData.map((data) {
                                return _buildLegendItem(data.color, data.label);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// KELAS PELUKIS (PAINTER) UNTUK MENGGAMBAR GRAFIK DONAT SECARA MANUAL
// (VERSI ANIMASI LENGKUNGAN MULUS)
// ======================================================================
class DonutChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double
  animationValue; // Variabel penangkap nilai animasi (0.0 sampai 1.0)

  DonutChartPainter(this.data, {this.animationValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    double total = data.fold(0, (sum, item) => sum + item.value);
    double startAngle = -pi / 2; // Mulai dari jam 12
    Offset center = Offset(size.width / 2, size.height / 2);

    // --- KONFIGURASI UKURAN ---
    double donutThickness = 24.0; // Ketebalan donat
    double outerRadius = size.width / 2;
    double innerRadius = outerRadius - donutThickness;

    // --- TINGKAT KELENGKUNGAN SUDUT ---
    double cornerRadius = 5.0;

    double pathOuterRadius = outerRadius - cornerRadius;
    double pathInnerRadius = innerRadius + cornerRadius;

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerRadius * 2
      ..strokeJoin = StrokeJoin.round;

    double gapAngle = 0.08; // Jarak pemisah antar warna
    double averageRadius = (outerRadius + innerRadius) / 2;
    double capAngle = cornerRadius / averageRadius;

    for (var item in data) {
      double sweepAngle = (item.value / total) * 2 * pi;

      // Porsi aslinya jika sudah selesai 100%
      double baseActualSweep = sweepAngle - gapAngle - (capAngle * 2);

      // --- EFEK ANIMASI TERJADI DI SINI ---
      double actualSweep = baseActualSweep * animationValue;
      double actualStart = startAngle + (gapAngle / 2) + capAngle;

      if (actualSweep <= 0) actualSweep = 0.001;

      fillPaint.color = item.color;
      strokePaint.color = item.color;

      Path path = Path();
      path.arcTo(
        Rect.fromCircle(center: center, radius: pathOuterRadius),
        actualStart,
        actualSweep,
        false,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: pathInnerRadius),
        actualStart + actualSweep,
        -actualSweep,
        false,
      );
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animationValue != animationValue;
  }
}
