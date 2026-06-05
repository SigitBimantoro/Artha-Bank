import 'package:flutter/material.dart';
import 'dart:math';
import '../services/api_service.dart';

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
  double _totalNominal = 0; // Default nominal 0 agar real dari API

  List<ChartData> dataPengeluaran = [
    ChartData(1, const Color(0xFFE0E0E0)), // Default Abu-abu agar tidak blank
  ];

  @override
  void initState() {
    super.initState();
    _fetchData(); 
  }

  // --- LOGIKA API ---
  Future<void> _fetchData() async {
    String period = _selectedTab == 0 ? 'weekly' : (_selectedTab == 1 ? 'monthly' : 'yearly');
    
    try {
      final res = await ApiService.getTrackingKeuangan(period);
      
      if (mounted && res['success'] == true && res['data'] != null && res['data']['data'] != null) {
        final pieData = res['data']['data']['pie_chart'];
        if (pieData != null) {
          double p = (pieData['pembayaran'] ?? 0).toDouble();
          double t = (pieData['top_up'] ?? 0).toDouble();
          double tr = (pieData['transfer_keluar'] ?? 0).toDouble();
          
          setState(() {
            _totalNominal = p + t + tr;
            
            if (_totalNominal > 0) {
              dataPengeluaran = [
                ChartData(p, const Color(0xFF2C265C)), // Pembayaran
                ChartData(t, const Color(0xFF4D55CC)), // Top up
                ChartData(tr, const Color(0xFFD2CFF0)), // Transfer
              ];
            } else {
              dataPengeluaran = [
                ChartData(1, const Color(0xFFE0E0E0)),
              ];
            }
          });
        }
      }
    } catch (e) {
      // Abaikan error agar UI tidak terganggu
    }
  }

  // Helper untuk Teks Periode Aktif
  String get _periodeText {
    if (_selectedTab == 0) return "Minggu ini";
    if (_selectedTab == 1) return "Bulan ini";
    return "Tahun ini";
  }

  String _formatRupiahSingkat(double value) {
    if (value == 0) return "Rp 0";
    if (value >= 1000000) {
      double result = value / 1000000;
      return "Rp ${result == result.toInt() ? result.toInt() : result.toStringAsFixed(1)} jt";
    } else if (value >= 1000) {
      double result = value / 1000;
      return "Rp ${result == result.toInt() ? result.toInt() : result.toStringAsFixed(1)} rb";
    }
    return "Rp ${value.toInt()}";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    const Color bgColor = Color(0xFFF8F9FA); 

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // --- TAB SELECTOR ---
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

              // --- KARTU 1: TRACKING KEUANGAN (DONUT CHART) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _periodeText, // <-- Berubah dinamis (Minggu/Bulan/Tahun ini)
                            style: const TextStyle(
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
                            Text(
                              _formatRupiahSingkat(_totalNominal),
                              style: const TextStyle(
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

              // --- KARTU 2: TRACKING KEUANGAN (BAR CHART) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Statistik",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _periodeText, // <-- Berubah dinamis
                            style: const TextStyle(
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
                      height: 160,
                      child: _buildDynamicBarChart(), // <-- Render bar dinamis
                    ),
                    const SizedBox(height: 20),

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

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTab != index) {
          setState(() => _selectedTab = index);
          _fetchData(); 
        }
      },
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

  // --- MERENDER BAR CHART SESUAI TAB ---
  Widget _buildDynamicBarChart() {
    if (_selectedTab == 0) {
      // MINGGUAN (7 Hari)
      return Row(
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
      );
    } else if (_selectedTab == 1) {
      // BULANAN (4 Minggu)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildStackedBar("M1", 0.40, 0.20, 0.10),
          _buildStackedBar("M2", 0.25, 0.35, 0.15),
          _buildStackedBar("M3", 0.50, 0.10, 0.20),
          _buildStackedBar("M4", 0.30, 0.30, 0.10),
        ],
      );
    } else {
      // TAHUNAN (Bisa dibuat 12 bulan atau 6 bulan per view, kita buat representatif)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildStackedBar("J", 0.20, 0.10, 0.15),
          _buildStackedBar("F", 0.30, 0.20, 0.10),
          _buildStackedBar("M", 0.40, 0.15, 0.20),
          _buildStackedBar("A", 0.25, 0.25, 0.10),
          _buildStackedBar("M", 0.50, 0.05, 0.25),
          _buildStackedBar("J", 0.35, 0.20, 0.15),
        ],
      );
    }
  }

  Widget _buildStackedBar(String label, double darkPct, double midPct, double lightPct) {
    const double maxBarHeight = 120.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: maxBarHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF6E75D1),
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
                  decoration: BoxDecoration(color: const Color(0xFFD2CFF0), borderRadius: BorderRadius.circular(10)),
                ),
              if (lightPct > 0 && (midPct > 0 || darkPct > 0)) const SizedBox(height: 2),

              if (midPct > 0)
                Container(
                  height: maxBarHeight * midPct,
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFF4D55CC), borderRadius: BorderRadius.circular(10)),
                ),
              if (midPct > 0 && darkPct > 0) const SizedBox(height: 2),

              if (darkPct > 0)
                Container(
                  height: maxBarHeight * darkPct,
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFF2C265C), borderRadius: BorderRadius.circular(10)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Color(0xFF4D55CC), fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}

// ============================================================================
// CUSTOM PAINTER (TIDAK DIUBAH)
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
      ..strokeCap = StrokeCap.round; 

    double total = dataList.fold(0, (sum, item) => sum + item.nominal);
    if (total == 0) return;

    double startAngle = -pi / 2; 
    const double gapAngle = 0.40; 

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