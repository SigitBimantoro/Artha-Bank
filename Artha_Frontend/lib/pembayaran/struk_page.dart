import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../dashboard/main_page.dart';
import 'receipt_downloader_stub.dart'
    if (dart.library.html) 'receipt_downloader_web.dart'
    if (dart.library.io) 'receipt_downloader_io.dart';

class StrukPage extends StatefulWidget {
  final bool isSuccess;
  final String type;
  final double amount;
  final String target;
  final String? errorMessage;
  final String idTransaksi;
  final String? tokenListrik;

  const StrukPage({
    super.key,
    required this.isSuccess,
    required this.type,
    required this.amount,
    required this.target,
    this.errorMessage,
    required this.idTransaksi,
    this.tokenListrik,
  });

  @override
  State<StrukPage> createState() => _StrukPageState();
}

class _StrukPageState extends State<StrukPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isProcessing = false;

  String _formatCurrency(double amt) {
    final s = amt.toInt().toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} | ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
  }

  String get _titleText {
    if (!widget.isSuccess) {
      return (widget.errorMessage?.toLowerCase().contains('saldo') == true)
          ? 'Saldo Tidak Cukup!'
          : 'Transaksi Gagal!';
    }
    switch (widget.type) {
      case 'TOPUP':
        return 'Top Up berhasil!';
      case 'TRANSFER':
        return 'Transfer berhasil!';
      case 'PULSA':
        return 'Pulsa berhasil!';
      case 'PLN':
        return 'Token Listrik berhasil!';
      case 'QRIS':
        return 'Pembayaran berhasil!';
      default:
        return 'Transaksi berhasil!';
    }
  }

  String get _subtitleText {
    if (!widget.isSuccess) {
      return widget.errorMessage ??
          'Transaksimu gagal diproses karena suatu kesalahan.';
    }
    return 'Transaksi kamu telah berhasil diproses.\nTerima kasih telah menggunakan Artha!';
  }

  String _typeLabel() {
    switch (widget.type) {
      case 'TRANSFER':
        return 'Transfer Uang';
      case 'PULSA':
        return 'Beli Pulsa / Kuota';
      case 'PLN':
        return 'Tagihan Listrik';
      case 'QRIS':
        return 'Pembayaran QRIS';
      default:
        return 'Top Up Saldo';
    }
  }

  Map<String, String> _details() {
    if (widget.type == 'TRANSFER') {
      return {
        'Jenis Transaksi :': 'Transfer Uang',
        'Tujuan Transfer :': widget.target,
        'Nominal Transfer :': _formatCurrency(widget.amount),
        'No Transaksi :': widget.idTransaksi,
      };
    }
    if (widget.type == 'PULSA') {
      return {
        'Jenis Transaksi :': 'Beli Pulsa / Kuota',
        'Nomor Tujuan :': widget.target,
        'Nominal :': _formatCurrency(widget.amount),
        'No Transaksi :': widget.idTransaksi,
      };
    }
    if (widget.type == 'PLN') {
      return {
        'Jenis Transaksi :': 'Tagihan Listrik',
        'Nomor Meter :': widget.tokenListrik ?? widget.target,
        'Nominal :': _formatCurrency(widget.amount),
        'No Transaksi :': widget.idTransaksi,
      };
    }
    if (widget.type == 'QRIS') {
      return {
        'Pembayaran ke :': widget.target,
        'Sumber Dana :': 'Saldo Artha',
        'Metode Pembayaran :': 'QRIS Artha',
        'Nominal Transaksi :': _formatCurrency(widget.amount),
        'No Transaksi :': widget.idTransaksi,
      };
    }
    return {
      'Metode Top Up :': widget.target,
      'Top Up ke :': 'Saldo Artha',
      'Nominal Top Up :': _formatCurrency(widget.amount),
      'No Top Up :': widget.idTransaksi,
    };
  }

  Future<Uint8List?> _captureReceipt() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _receiptKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _shareReceipt() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureReceipt();
      if (bytes == null) return;
      await Share.shareXFiles([
        XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: 'resi_${widget.type.toLowerCase()}_${widget.idTransaksi}.png',
        ),
      ], text: 'Resi ${_typeLabel()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _downloadReceipt() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureReceipt();
      if (bytes == null) return;
      await saveReceiptFile(
        bytes,
        'resi_${widget.type.toLowerCase()}_${widget.idTransaksi}.png',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengunduh resi')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    final details = _details();

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                      (route) => false,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Rincian ${widget.type == 'TOPUP' ? 'Top Up' : 'Transaksi'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 5,
                ),
                child: RepaintBoundary(
                  key: _receiptKey,
                  child: ClipPath(
                    clipper: ReceiptClipper(),
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: widget.isSuccess
                                    ? const Color(0xFF25D366)
                                    : const Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.isSuccess ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _titleText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _subtitleText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 25),
                            CustomPaint(
                              painter: DashedLinePainter(),
                              size: const Size(double.infinity, 2),
                            ),
                            const SizedBox(height: 25),
                            ...details.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.key,
                                        style: const TextStyle(
                                          color: primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      e.value,
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Total:',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatCurrency(widget.amount),
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Tanggal & Waktu:\n${_formatDateTime(DateTime.now())}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 11,
                                fontFamily: 'Poppins',
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _shareReceipt,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.ios_share,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Bagikan Resi',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: _downloadReceipt,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.download_rounded,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Unduh Resi',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);

    double waveWidth = size.width / 8;
    for (double i = size.width; i > 0; i -= waveWidth) {
      path.quadraticBezierTo(
        i - (waveWidth / 2),
        size.height - 25,
        i - waveWidth,
        size.height,
      );
    }

    path.lineTo(0, 20);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 8, dashSpace = 8, startX = 0;
    final paint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
