import 'package:flutter/material.dart';
import 'dart:math';

// --- MODEL DATA UNTUK GRAFIK DINAMIS ---
class ChartData {
  final double nominal;
  final Color color;
  ChartData(this.nominal, this.color);
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  int _selectedTab = 0; // 0: Mingguan, 1: Bulanan, 2: Tahunan

  // --- DATA NOMINAL GRAFIK DONAT ---
  final List<ChartData> dataPengeluaran = [
    ChartData(600000, const Color(0xFF4D55CC)), // Ungu Utama
    ChartData(200000, const Color(0xFFD2CFF0)), // Ungu Terang
    ChartData(200000, const Color(0xFF2C265C)), // Ungu Gelap
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    const Color bgColor = Color(0xFFF8F9FA); // Off-white cerah

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- JUDUL HALAMAN ---
              const Text(
                'Tracking keuangan',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Yuk, cek pengeluaranmu hari ini biar rencana\nbesarmu tetap terjaga.',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  height: 1.4,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 25),

              // --- TAB SELECTOR (Mingguan, Bulanan, Tahunan) ---
              Container(
                height: 55,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTabItem("Mingguan", 0)),
                    Expanded(child: _buildTabItem("Bulanan", 1)),
                    Expanded(child: _buildTabItem("Tahunan", 2)),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- KARTU 1: TRACKING KEUANGAN (HARI INI) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    // Header Kartu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tracking Keuangan",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Hari ini",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Kotak Putih Grafik Doughnut
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CustomPaint(
                                painter: DynamicDoughnutPainter(
                                  dataList: dataPengeluaran,
                                ),
                              ),
                            ),
                            const Text(
                              "Rp 1 jt",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Legenda Bawah (Pembayaran, Top up, Transfer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLegendItem(const Color(0xFF2C265C), "Pembayaran"),
                        _buildLegendItem(const Color(0xFF4D55CC), "Top up"),
                        _buildLegendItem(const Color(0xFFD2CFF0), "Transfer"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- KARTU 2: TRACKING KEUANGAN (MINGGU INI) - BAR CHART ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    // Header Kartu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tracking Keuangan",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Minggu ini",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Area Grafik Bar Bertumpuk
                    SizedBox(
                      height: 160, // Tinggi area grafik
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStackedBar("S", 0.20, 0.20, 0.25),
                          _buildStackedBar("S", 0.35, 0.15, 0.15),
                          _buildStackedBar("R", 0.35, 0.30, 0.0),
                          _buildStackedBar("K", 0.55, 0.05, 0.20),
                          _buildStackedBar("J", 0.35, 0.30, 0.10),
                          _buildStackedBar("S", 0.15, 0.15, 0.25),
                          _buildStackedBar("M", 0.50, 0.20, 0.05),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Legenda Bawah (Pembayaran, Top up, Transfer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLegendItem(const Color(0xFF2C265C), "Pembayaran"),
                        _buildLegendItem(const Color(0xFF4D55CC), "Top up"),
                        _buildLegendItem(const Color(0xFFD2CFF0), "Transfer"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: TAB SELECTOR ---
  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4D55CC) : Colors.white,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: LEGENDA (PILL BENTUK) ---
  Widget _buildLegendItem(Color dotColor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4D55CC),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: STACKED BAR CHART ---
  // Parameter berupa persentase tinggi relatif (0.0 - 1.0) dari total tinggi track (120px)
  Widget _buildStackedBar(
    String label,
    double darkPct,
    double midPct,
    double lightPct,
  ) {
    const double maxBarHeight = 120.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Batang Grafik
        Container(
          width: 32,
          height: maxBarHeight,
          decoration: BoxDecoration(
            color: const Color(
              0xFF6E75D1,
            ), // Warna track background (Ungu pudar)
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (lightPct > 0)
                Container(
                  height: maxBarHeight * lightPct,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2CFF0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              if (lightPct > 0 && (midPct > 0 || darkPct > 0))
                const SizedBox(height: 2), // Jarak pemisah

              if (midPct > 0)
                Container(
                  height: maxBarHeight * midPct,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D55CC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              if (midPct > 0 && darkPct > 0)
                const SizedBox(height: 2), // Jarak pemisah

              if (darkPct > 0)
                Container(
                  height: maxBarHeight * darkPct,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C265C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Label Sumbu X (Hari)
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4D55CC),
              fontWeight: FontWeight.w900,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CUSTOM PAINTER: GRAFIK DOUGHNUT DINAMIS BENTUK MEMBULAT (SANGAT PRESISI)
// ============================================================================
class DynamicDoughnutPainter extends CustomPainter {
  final List<ChartData> dataList;
  DynamicDoughnutPainter({required this.dataList});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const double strokeWidth = 26.0;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Membuat ujung lengkung mulus

    double total = dataList.fold(0, (sum, item) => sum + item.nominal);
    if (total == 0) return;

    double startAngle = -pi / 2; // Mulai memutar dari atas (Jam 12)
    const double gapAngle = 0.40; // Jarak pemisah antar warna

    for (var item in dataList) {
      double sweepAngle = (item.nominal / total) * 2 * pi;
      double actualSweep = sweepAngle - gapAngle;
      if (actualSweep <= 0) actualSweep = 0.001;

      paint.color = item.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gapAngle / 2),
        actualSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
