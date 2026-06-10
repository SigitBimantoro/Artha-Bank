import 'dart:math';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/chart_helper.dart';
import 'pdf_downloader_stub.dart'
    if (dart.library.html) 'pdf_downloader_web.dart'
    if (dart.library.io) 'pdf_downloader_io.dart';

class DetailAnalisisPage extends StatefulWidget {
  final String period;

  const DetailAnalisisPage({super.key, this.period = 'weekly'});

  @override
  State<DetailAnalisisPage> createState() => _DetailAnalisisPageState();
}

class _DetailAnalisisPageState extends State<DetailAnalisisPage> {
  static const Color primaryColor = Color(0xFF4D55CC);
  static const Color darkPurple = Color(0xFF2C265C);
  static const Color lightPurple = Color(0xFFD2CFF0);

  late String _selectedPeriod;
  Map<String, dynamic>? _data;
  List<ChartData> _chartData = [ChartData(0, Colors.grey)];
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.period;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getTrackingKeuangan(_selectedPeriod);
      if (mounted && res['success'] == true && res['data'] != null) {
        final pie = res['data']['pie_chart'] ?? {};
        final topUp = _valueFromMap(pie, 'top_up');
        final transferMasuk = _valueFromMap(pie, 'transfer_masuk');
        final wishlistMasuk = _valueFromMap(pie, 'wishlist_masuk');
        final pembayaranPulsa = _valueFromMap(pie, 'pembayaran_pulsa') > 0
            ? _valueFromMap(pie, 'pembayaran_pulsa')
            : _valueFromMap(pie, 'pembayaran');
        final pembayaranListrik = _valueFromMap(pie, 'pembayaran_listrik');
        final transferKeluar = _valueFromMap(pie, 'transfer_keluar');
        final wishlistKeluar = _valueFromMap(pie, 'wishlist_keluar');
        final pemasukan = _valueFromMap(pie, 'pemasukan') > 0
            ? _valueFromMap(pie, 'pemasukan')
            : topUp + transferMasuk + wishlistMasuk;
        final pengeluaran = _valueFromMap(pie, 'pengeluaran') > 0
            ? _valueFromMap(pie, 'pengeluaran')
            : pembayaranPulsa +
                  pembayaranListrik +
                  transferKeluar +
                  wishlistKeluar;
        setState(() {
          _data = res['data'];
          _chartData = [
            ChartData(pemasukan, lightPurple),
            ChartData(pengeluaran, darkPurple),
          ];
        });
      }
    } catch (e) {
      debugPrint('Error load detail analisis: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPDF() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await ApiService.downloadPDFReport(_selectedPeriod);
      await savePdfFile(bytes, 'laporan_$_selectedPeriod.pdf');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal download PDF')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  double get _pemasukan {
    final direct = _pieValue('pemasukan');
    return direct > 0 ? direct : _topUp + _transferMasuk + _wishlistMasuk;
  }

  double get _pengeluaran {
    final direct = _pieValue('pengeluaran');
    return direct > 0
        ? direct
        : _pembayaranPulsa +
              _pembayaranListrik +
              _transferKeluar +
              _wishlistKeluar;
  }

  double get _total => _pemasukan + _pengeluaran;
  double get _topUp => _pieValue('top_up');
  double get _transferMasuk => _pieValue('transfer_masuk');
  double get _wishlistMasuk => _pieValue('wishlist_masuk');
  double get _pembayaranPulsa => _pieValue('pembayaran_pulsa') > 0
      ? _pieValue('pembayaran_pulsa')
      : _pieValue('pembayaran');
  double get _pembayaranListrik => _pieValue('pembayaran_listrik');
  double get _transferKeluar => _pieValue('transfer_keluar');
  double get _wishlistKeluar => _pieValue('wishlist_keluar');

  double _pieValue(String key) {
    final pie = _data?['pie_chart'];
    return _valueFromMap(pie, key);
  }

  double _valueFromMap(dynamic map, String key) {
    if (map is! Map) return 0;
    final value = map[key];
    return value is num ? max(0.0, value.toDouble()) : 0;
  }

  String get _periodText {
    if (_selectedPeriod == 'monthly') return 'Bulan ini';
    if (_selectedPeriod == 'yearly') return 'Tahun ini';
    return 'Minggu ini';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Text(
                          'Detail Analisis',
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: 'Poppins',
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildPeriodTabs(),
                    const SizedBox(height: 22),
                    _buildSummaryCard(),
                    const SizedBox(height: 18),
                    _buildDetailCard(),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading ? null : _exportPDF,
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.download, color: Colors.white),
                        label: Text(
                          _isDownloading ? 'Menyiapkan PDF' : 'Download PDF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _buildPeriodItem('Mingguan', 'weekly'),
          _buildPeriodItem('Bulanan', 'monthly'),
          _buildPeriodItem('Tahunan', 'yearly'),
        ],
      ),
    );
  }

  Widget _buildPeriodItem(String label, String value) {
    final selected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedPeriod == value) return;
          setState(() => _selectedPeriod = value);
          _loadData();
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? primaryColor : Colors.white,
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Summary Keuangan',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _periodText,
                  style: const TextStyle(
                    color: primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CustomPaint(
                      painter: DynamicDoughnutPainter(dataList: _chartData),
                    ),
                  ),
                  Text(
                    _formatRupiahSingkat(_total),
                    style: const TextStyle(
                      color: primaryColor,
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E5F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Summary',
            style: TextStyle(
              color: primaryColor,
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Pemasukan', _pemasukan, lightPurple),
          _buildSummaryRow('Top Up', _topUp, lightPurple, indent: true),
          _buildSummaryRow(
            'Transfer Masuk',
            _transferMasuk,
            lightPurple,
            indent: true,
          ),
          _buildSummaryRow(
            'Dari Wishlist',
            _wishlistMasuk,
            lightPurple,
            indent: true,
          ),
          const Divider(height: 26, color: Color(0xFFE5E5F8)),
          _buildSummaryRow('Pengeluaran', _pengeluaran, darkPurple),
          _buildSummaryRow(
            'Pulsa / Kuota',
            _pembayaranPulsa,
            darkPurple,
            indent: true,
          ),
          _buildSummaryRow(
            'Tagihan Listrik',
            _pembayaranListrik,
            darkPurple,
            indent: true,
          ),
          _buildSummaryRow(
            'Transfer Keluar',
            _transferKeluar,
            darkPurple,
            indent: true,
          ),
          _buildSummaryRow(
            'Saldo ke Wishlist',
            _wishlistKeluar,
            darkPurple,
            indent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    Color color, {
    bool indent = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: indent ? 24 : 0,
        top: indent ? 7 : 10,
        bottom: indent ? 7 : 10,
      ),
      child: Row(
        children: [
          Container(
            width: indent ? 10 : 14,
            height: indent ? 10 : 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: primaryColor,
                fontFamily: 'Poppins',
                fontSize: indent ? 13 : 15,
                fontWeight: indent ? FontWeight.w600 : FontWeight.w800,
              ),
            ),
          ),
          Text(
            'Rp ${_formatRupiah(value)}',
            style: TextStyle(
              color: primaryColor,
              fontFamily: 'Poppins',
              fontSize: indent ? 13 : 15,
              fontWeight: indent ? FontWeight.w700 : FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  String _formatRupiahSingkat(double value) {
    if (value <= 0) return 'Rp 0';
    if (value >= 1000000) {
      final result = value / 1000000;
      return 'Rp ${result == result.toInt() ? result.toInt() : result.toStringAsFixed(1)} jt';
    }
    if (value >= 1000) {
      final result = value / 1000;
      return 'Rp ${result == result.toInt() ? result.toInt() : result.toStringAsFixed(1)} rb';
    }
    return 'Rp ${value.toInt()}';
  }
}
