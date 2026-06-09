import 'package:flutter/material.dart';
import '../dashboard/main_page.dart';

class StrukPage extends StatelessWidget {
  final bool isSuccess;
  final String type; // 'TRANSFER', 'TOPUP', 'PULSA', 'PLN'
  final double amount;
  final String target;
  final String? errorMessage;
  final String idTransaksi;

  const StrukPage({
    super.key,
    required this.isSuccess,
    required this.type,
    required this.amount,
    required this.target,
    this.errorMessage,
    required this.idTransaksi,
  });

  String _formatCurrency(double amt) {
    final s = amt.toInt().toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  String _formatDateTime(DateTime dt) {
    List<String> months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year} | ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    
    // Logika Text Sukses / Gagal
    String title = isSuccess 
        ? "${type == 'TOPUP' ? 'Top Up' : type == 'TRANSFER' ? 'Transfer' : 'Transaksi'} berhasil!"
        : ((errorMessage?.toLowerCase().contains('saldo') == true) ? "Saldo Tidak Cukup!" : "Transaksi Gagal!");
        
    String subtitle = isSuccess
        ? "Transaksi kamu telah berhasil diproses.\nTerima kasih telah menggunakan Artha!"
        : (errorMessage ?? "Transaksimu gagal diproses karena suatu kesalahan. Yuk, coba lagi nanti.");

    // Detail Baris Struk (Sekarang 100% Dinamis)
    Map<String, String> details = {};
    if (type == 'TRANSFER') {
      details['Jenis Transaksi :'] = 'Transfer Uang';
      details['Tujuan Transfer :'] = target;
      details['Nominal Transfer :'] = _formatCurrency(amount);
      details['No Transaksi :'] = idTransaksi;
    } else if (type == 'PULSA' || type == 'PLN') {
      details['Jenis Transaksi :'] = type == 'PULSA' ? 'Beli Pulsa' : 'Token Listrik';
      details['Nomor Tujuan :'] = target;
      details['Nominal :'] = _formatCurrency(amount);
      details['No Transaksi :'] = idTransaksi;
    } else {
      // BAGIAN TOP UP: Target otomatis berisi 'Bank Jago', 'Alfamart', dll
      details['Metode Top Up :'] = target; 
      details['Top Up ke :'] = 'Saldo Artha';
      details['Nominal Top Up :'] = _formatCurrency(amount);
      details['No Top Up :'] = idTransaksi;
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    // Tombol Back di Struk selalu memulangkan user ke Home/MainPage
                    onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainPage()), (route) => false),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: primaryColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "Rincian ${type == 'TOPUP' ? 'Top Up' : 'Transaksi'}",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),

            // --- KARTU STRUK ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: ClipPath(
                  clipper: ReceiptClipper(), // Memotong ujung bawah seperti struk
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    // KUNCI PERBAIKAN: Dibungkus SingleChildScrollView agar tidak Overflow kuning-hitam
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isSuccess ? const Color(0xFF25D366) : const Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isSuccess ? Icons.check : Icons.close, color: Colors.white, size: 45),
                          ),
                          const SizedBox(height: 20),
                          
                          Text(
                            title,
                            style: const TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),
                          ),
                          const SizedBox(height: 10),
                          
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontFamily: 'Poppins', height: 1.5),
                          ),
                          const SizedBox(height: 25),

                          CustomPaint(
                            painter: DashedLinePainter(),
                            size: const Size(double.infinity, 2),
                          ),
                          const SizedBox(height: 25),

                          ...details.entries.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key, style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                                    Text(e.value, style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Poppins')),
                                  ],
                                ),
                              )).toList(),

                          const SizedBox(height: 20), // Pengganti Spacer() agar tidak bentrok dengan layout layar

                          const Text("Total:", style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Poppins')),
                          const SizedBox(height: 10),
                          Text(
                            _formatCurrency(amount),
                            style: const TextStyle(color: primaryColor, fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Tanggal & Waktu:\n${_formatDateTime(DateTime.now())}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11, fontFamily: 'Poppins', height: 1.4),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- TOMBOL BAGIKAN & UNDUH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 2)),
                            child: const Icon(Icons.ios_share, color: primaryColor, size: 20),
                          ),
                          const SizedBox(height: 8),
                          const Text("Bagikan Resi", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 11, fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 2)),
                            child: const Icon(Icons.download_rounded, color: primaryColor, size: 20),
                          ),
                          const SizedBox(height: 8),
                          const Text("Unduh Resi", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 11, fontFamily: 'Poppins')),
                        ],
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

// -----------------------------------------------------------------
// CLIPPER: MEMOTONG UJUNG BAWAH KARTU JADI SEPERTI STRUK (MELENGKUNG)
// -----------------------------------------------------------------
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
      path.quadraticBezierTo(i - (waveWidth / 2), size.height - 25, i - waveWidth, size.height);
    }
    
    path.lineTo(0, 20); 
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// -----------------------------------------------------------------
// PAINTER: MEMBUAT GARIS PUTUS-PUTUS
// -----------------------------------------------------------------
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