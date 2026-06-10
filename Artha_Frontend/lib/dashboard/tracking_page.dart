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
  List<dynamic> _barChart = [];

  double _pemasukanTotal = 0.0;
  double _pengeluaranTotal = 0.0;
  double _topUpTotal = 0.0;
  double _transferMasukTotal = 0.0;
  double _pembayaranTotal = 0.0;
  double _transferKeluarTotal = 0.0;

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
          final topUp = _numberFrom(pieData, 'top_up');
          final transferMasuk = _numberFrom(pieData, 'transfer_masuk');
          final pembayaran = _paymentTotalFrom(pieData);
          final transferKeluar = _numberFrom(pieData, 'transfer_keluar');
          final pemasukanRaw = _numberFrom(pieData, 'pemasukan');
          final pengeluaranRaw = _numberFrom(pieData, 'pengeluaran');
          final pemasukan = pemasukanRaw > 0
              ? pemasukanRaw
              : topUp + transferMasuk;
          final pengeluaran = pengeluaranRaw > 0
              ? pengeluaranRaw
              : pembayaran + transferKeluar;

          setState(() {
            _pemasukanTotal = pemasukan;
            _pengeluaranTotal = pengeluaran;
            _topUpTotal = topUp;
            _transferMasukTotal = transferMasuk;
            _pembayaranTotal = pembayaran;
            _transferKeluarTotal = transferKeluar;
            _barChart = barData;
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

  double _numberFrom(dynamic source, String key) {
    if (source is! Map) return 0;
    final value = source[key];
    return value is num ? max(0.0, value.toDouble()) : 0;
  }

  double _paymentTotalFrom(dynamic source) {
    final direct = _numberFrom(source, 'pembayaran');
    if (direct > 0) return direct;
    return _numberFrom(source, 'pembayaran_pulsa') +
        _numberFrom(source, 'pembayaran_listrik');
  }

  double _incomeTotalFrom(dynamic source) {
    final direct = _numberFrom(source, 'pemasukan');
    if (direct > 0) return direct;
    return _numberFrom(source, 'top_up') +
        _numberFrom(source, 'transfer_masuk');
  }

  double _expenseTotalFrom(dynamic source) {
    final direct = _numberFrom(source, 'pengeluaran');
    if (direct > 0) return direct;
    return _paymentTotalFrom(source) + _numberFrom(source, 'transfer_keluar');
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

              _buildPieChartCarousel(),
              const SizedBox(height: 20),
              _buildBarChartCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartCarousel() {
    return SizedBox(
      height: 390,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildPieCard(
            title: 'Tracking Uang Masuk',
            period: 'Hari ini',
            total: _pemasukanTotal,
            data: [
              ChartData(_topUpTotal, const Color(0xFF2C265C)),
              ChartData(_transferMasukTotal, const Color(0xFF6756C5)),
            ],
            legends: const [
              _LegendData(Color(0xFF2C265C), 'Top up'),
              _LegendData(Color(0xFF6756C5), 'Transfer Masuk'),
            ],
          ),
          const SizedBox(width: 16),
          _buildPieCard(
            title: 'Tracking Uang Keluar',
            period: 'Hari ini',
            total: _pengeluaranTotal,
            data: [
              ChartData(_transferKeluarTotal, const Color(0xFF2C265C)),
              ChartData(_pembayaranTotal, const Color(0xFF6756C5)),
            ],
            legends: const [
              _LegendData(Color(0xFF2C265C), 'Transfer Keluar'),
              _LegendData(Color(0xFF6756C5), 'Pembayaran'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieCard({
    required String title,
    required String period,
    required double total,
    required List<ChartData> data,
    required List<_LegendData> legends,
  }) {
    const Color primaryColor = Color(0xFF4D55CC);
    final cardWidth = MediaQuery.of(context).size.width - 48;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              _buildPeriodBadge(period),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 162,
                      height: 162,
                      child: CustomPaint(
                        painter: DynamicDoughnutPainter(dataList: data),
                      ),
                    ),
                    Text(
                      _formatRupiahSingkat(total),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < legends.length; i++) ...[
                Expanded(child: _buildPillLegend(legends[i])),
                if (i != legends.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    const Color primaryColor = Color(0xFF4D55CC);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tracking Keuangan",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              _buildPeriodBadge(_periodeText),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildDynamicBarChart(),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _LegendPill(
                  color: Color(0xFFD2CFF0),
                  label: 'Pemasukan',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LegendPill(
                  color: Color(0xFF2C265C),
                  label: 'Pengeluaran',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodBadge(String label) {
    return Container(
      constraints: const BoxConstraints(minWidth: 122),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4D55CC),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildPillLegend(_LegendData data) {
    return _LegendPill(color: data.color, label: data.label);
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

  Widget _buildDynamicBarChart() {
    final items = _barChart.isEmpty ? [] : _barChart;

    final maxValue = items.fold<double>(0, (maxVal, item) {
      final nominal = item['nominal'] ?? {};
      final pemasukan = _incomeTotalFrom(nominal);
      final pengeluaran = _expenseTotalFrom(nominal);
      return max(maxVal, max(pemasukan, pengeluaran));
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

      final pemasukan = _incomeTotalFrom(nominal);
      final pengeluaran = _expenseTotalFrom(nominal);

      final scale = (maxValue <= 0) ? 0.0 : (1 / maxValue);

      final key = GlobalKey();

      barWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: MouseRegion(
            onEnter: (e) =>
                _showHoverOverlay(key, item, pemasukan, pengeluaran),
            onExit: (e) => _removeHoverOverlay(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) =>
                  _showTouchOverlay(key, item, pemasukan, pengeluaran),
              onLongPressStart: (_) =>
                  _showTouchOverlay(key, item, pemasukan, pengeluaran),
              onTapCancel: _scheduleTouchOverlayRemoval,
              child: Container(
                key: key,
                color: Colors.transparent,
                child: _buildGroupedBar(
                  item['label'] ?? '-',
                  pemasukan * scale,
                  pengeluaran * scale,
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
    double pemasukan,
    double pengeluaran,
  ) {
    _showHoverOverlay(key, item, pemasukan, pengeluaran);
    _scheduleTouchOverlayRemoval();
  }

  void _scheduleTouchOverlayRemoval() {
    _touchOverlayTimer?.cancel();
    _touchOverlayTimer = Timer(const Duration(seconds: 2), _removeHoverOverlay);
  }

  void _showHoverOverlay(
    GlobalKey key,
    dynamic item,
    double pemasukan,
    double pengeluaran,
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
            child: _HoverCard(pemasukan: pemasukan, pengeluaran: pengeluaran),
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
    } catch (_) {
      // Overlay may already be detached during fast route changes.
    }
    _hoverOverlay = null;
  }

  @override
  void dispose() {
    _touchOverlayTimer?.cancel();
    _removeHoverOverlay();
    super.dispose();
  }

  Widget _buildGroupedBar(
    String label,
    double pemasukanPct,
    double pengeluaranPct,
  ) {
    const double maxBarHeight = 120.0;

    pemasukanPct = pemasukanPct.clamp(0.0, 1.0);
    pengeluaranPct = pengeluaranPct.clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 58,
          height: maxBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSingleBar(
                max(10.0, maxBarHeight * pemasukanPct),
                const Color(0xFFD2CFF0),
              ),
              const SizedBox(width: 8),
              _buildSingleBar(
                max(10.0, maxBarHeight * pengeluaranPct),
                const Color(0xFF2C265C),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildSingleBar(double height, Color color) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _LegendData {
  final Color color;
  final String label;

  const _LegendData(this.color, this.label);
}

class _LegendPill extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendPill({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4D55CC),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverCard extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;

  const _HoverCard({required this.pemasukan, required this.pengeluaran});

  String _format(double v) {
    if (v <= 0) return 'Rp 0';
    if (v >= 1000000) {
      return 'Rp ${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)} jt';
    }
    if (v >= 1000) {
      return 'Rp ${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)} rb';
    }
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
            color: Colors.black.withValues(alpha: 0.15),
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
          _rowItem(const Color(0xFFD2CFF0), 'Pemasukan', _format(pemasukan)),
          const SizedBox(height: 8),
          _rowItem(
            const Color(0xFF2C265C),
            'Pengeluaran',
            _format(pengeluaran),
          ),
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
