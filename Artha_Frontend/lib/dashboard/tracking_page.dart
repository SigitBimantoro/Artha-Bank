import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
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
  int _selectedTab = 0;
  double _totalNominal = 0;
  List<dynamic> _barChart = [];

  double _pembayaranTotal = 0.0;
  double _topUpTotal = 0.0;
  double _transferTotal = 0.0;

  List<ChartData> dataPengeluaran = [ChartData(0, const Color(0xFFE0E0E0))];
  OverlayEntry? _hoverOverlay;
  Timer? _touchOverlayTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- LOGIKA API ---
  Future<void> _fetchData() async {
    String period = _selectedTab == 0
        ? 'weekly'
        : (_selectedTab == 1 ? 'monthly' : 'yearly');

    try {
      final res = await ApiService.getTrackingKeuangan(period);

      if (mounted && res['success'] == true && res['data'] != null) {
        final pieData = res['data']['pie_chart'];
        final barData = res['data']['bar_chart'] ?? [];
        if (pieData != null) {
          // PENGAMAN: Gunakan max(0.0) agar tidak pernah ada nilai negatif yang merusak grafik
          double p = max(0.0, (pieData['pembayaran'] ?? 0).toDouble());
          double t = max(0.0, (pieData['top_up'] ?? 0).toDouble());
          double tr = max(0.0, (pieData['transfer_keluar'] ?? 0).toDouble());

          setState(() {
            _totalNominal = p + t + tr;
            _pembayaranTotal = p;
            _topUpTotal = t;
            _transferTotal = tr;
            _barChart = barData;
            dataPengeluaran = [
              ChartData(p, const Color(0xFF2C265C)),
              ChartData(t, const Color(0xFF4D55CC)),
              ChartData(tr, const Color(0xFFD2CFF0)),
            ];
          });
        }
      }
    } catch (e) {
      // Abaikan error agar UI tidak terganggu
    }
  }

  String get _periodeText {
    if (_selectedTab == 0) return "Minggu ini";
    if (_selectedTab == 1) return "Bulan ini";
    return "Tahun ini";
  }

  String _formatRupiahSingkat(double value) {
    if (value <= 0) return "Rp 0";
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _periodeText,
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _periodeText,
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
                    SizedBox(height: 160, child: _buildDynamicBarChart()),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
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
    String amountText = '';
    if (label == 'Pembayaran')
      amountText = _formatRupiahSingkat(_pembayaranTotal);
    if (label == 'Top up') amountText = _formatRupiahSingkat(_topUpTotal);
    if (label == 'Transfer') amountText = _formatRupiahSingkat(_transferTotal);

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
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4D55CC),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          if (amountText.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                amountText,
                style: const TextStyle(
                  color: Color(0xFF2C265C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicBarChart() {
    final items = _barChart.isEmpty ? [] : _barChart;

    // PENGAMAN: Hindari total menjadi negatif
    final maxValue = items.fold<double>(0, (maxVal, item) {
      final nominal = item['nominal'] ?? {};
      final total =
          max(0.0, (nominal['pembayaran'] ?? 0).toDouble()) +
          max(0.0, (nominal['top_up'] ?? 0).toDouble()) +
          max(0.0, (nominal['transfer_keluar'] ?? 0).toDouble());
      return total > maxVal ? total : maxVal;
    });

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data statistik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    List<Widget> barWidgets = [];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final nominal = item['nominal'] ?? {};

      // PENGAMAN: Pastikan 3 Variabel warna tidak ada yang negatif
      final pembayaran = max(0.0, (nominal['pembayaran'] ?? 0).toDouble());
      final topUp = max(0.0, (nominal['top_up'] ?? 0).toDouble());
      final transfer = max(0.0, (nominal['transfer_keluar'] ?? 0).toDouble());

      // PENGAMAN: Mencegah error pembagian dengan 0 (Infinity/NaN)
      final scale = (maxValue <= 0) ? 0.0 : (1 / maxValue);

      final key = GlobalKey();

      barWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: MouseRegion(
            onEnter: (e) =>
                _showHoverOverlay(key, item, pembayaran, topUp, transfer),
            onExit: (e) => _removeHoverOverlay(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) =>
                  _showTouchOverlay(key, item, pembayaran, topUp, transfer),
              onLongPressStart: (_) =>
                  _showTouchOverlay(key, item, pembayaran, topUp, transfer),
              onTapCancel: _scheduleTouchOverlayRemoval,
              child: Container(
                key: key,
                color: Colors.transparent,
                child: _buildStackedBar(
                  item['label'] ?? '-',
                  pembayaran * scale,
                  topUp * scale,
                  transfer * scale,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: barWidgets,
      ),
    );
  }

  void _showTouchOverlay(
    GlobalKey key,
    dynamic item,
    double pembayaran,
    double topUp,
    double transfer,
  ) {
    _showHoverOverlay(key, item, pembayaran, topUp, transfer);
    _scheduleTouchOverlayRemoval();
  }

  void _scheduleTouchOverlayRemoval() {
    _touchOverlayTimer?.cancel();
    _touchOverlayTimer = Timer(const Duration(seconds: 2), _removeHoverOverlay);
  }

  void _showHoverOverlay(
    GlobalKey key,
    dynamic item,
    double pembayaran,
    double topUp,
    double transfer,
  ) {
    _touchOverlayTimer?.cancel();
    _removeHoverOverlay();
    final ctx = key.currentContext;
    if (ctx == null) return;

    final RenderBox box = ctx.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);

    final overlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          // Sesuaikan 'left' dan 'top' agar kartu muncul tepat di tengah atas batang
          left: offset.dx - 75,
          top: offset.dy - 160,
          child: Material(
            color: Colors.transparent,
            child: _HoverCard(
              pembayaran: pembayaran,
              topUp: topUp,
              transfer: transfer,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlay);
    _hoverOverlay = overlay;
  }

  void _removeHoverOverlay() {
    _touchOverlayTimer?.cancel();
    try {
      _hoverOverlay?.remove();
    } catch (e) {}
    _hoverOverlay = null;
  }

  @override
  void dispose() {
    _touchOverlayTimer?.cancel();
    _removeHoverOverlay();
    super.dispose();
  }

  Widget _buildStackedBar(
    String label,
    double darkPct,
    double midPct,
    double lightPct,
  ) {
    const double maxBarHeight = 120.0;

    // Pastikan persentase absolut aman (antara 0.0 hingga 1.0)
    darkPct = darkPct.clamp(0.0, 1.0);
    midPct = midPct.clamp(0.0, 1.0);
    lightPct = lightPct.clamp(0.0, 1.0);

    double gapHeight = 0;
    if (lightPct > 0 && (midPct > 0 || darkPct > 0)) gapHeight += 4;
    if (midPct > 0 && darkPct > 0) gapHeight += 4;

    // PENGAMAN EKSTRA: Mencegah tinggi Container menjadi negatif
    double availableHeight = max(0.0, maxBarHeight - 12 - gapHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 48,
          height: maxBarHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (lightPct > 0)
                Container(
                  height: max(0.0, availableHeight * lightPct), // PENGAMAN
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2CFF0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              if (lightPct > 0 && (midPct > 0 || darkPct > 0))
                const SizedBox(height: 4),
              if (midPct > 0)
                Container(
                  height: max(0.0, availableHeight * midPct), // PENGAMAN
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D55CC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              if (midPct > 0 && darkPct > 0) const SizedBox(height: 4),
              if (darkPct > 0)
                Container(
                  height: max(0.0, availableHeight * darkPct), // PENGAMAN
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C265C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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

class _HoverCard extends StatelessWidget {
  final double pembayaran;
  final double topUp;
  final double transfer;

  const _HoverCard({
    required this.pembayaran,
    required this.topUp,
    required this.transfer,
  });

  String _format(double v) {
    if (v <= 0) return 'Rp 0';
    if (v >= 1000000)
      return 'Rp ${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)} jt';
    if (v >= 1000)
      return 'Rp ${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)} rb';
    return 'Rp ${v.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C265C),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _rowItem(const Color(0xFF2C265C), 'Pembayaran', _format(pembayaran)),
          const SizedBox(height: 8),
          _rowItem(const Color(0xFF4D55CC), 'Top up', _format(topUp)),
          const SizedBox(height: 8),
          _rowItem(const Color(0xFFD2CFF0), 'Transfer', _format(transfer)),
        ],
      ),
    );
  }

  Widget _rowItem(Color dotColor, String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2C265C),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF2C265C),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

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

    // PENGAMAN: Jika total 0, gambar lingkaran abu-abu kosong (tampilan tetap manis)
    if (total <= 0) {
      paint.color = Colors.grey.shade300;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0,
        2 * pi,
        false,
        paint,
      );
      return;
    }

    double startAngle = -pi / 2;
    const double gapAngle = 0.40;

    for (var item in dataList) {
      if (item.nominal <= 0) continue; // Jangan gambar arc jika nilainya 0

      double sweepAngle = (item.nominal / total) * 2 * pi;
      double actualSweep = sweepAngle - gapAngle;

      // PENGAMAN: Cegah arc menjadi nilai negatif atau terlalu kecil sehingga merusak UI
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
