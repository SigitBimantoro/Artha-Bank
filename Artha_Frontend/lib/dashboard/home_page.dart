import 'package:flutter/material.dart';
import 'dart:math';
import '../pembayaran/pembayaran_page.dart'; 
import '../transfer/transfer_page.dart'; // 1. SUDAH DI-IMPORT DI SINI

// --- MODEL DATA UNTUK GRAFIK DINAMIS ---
class ChartData {
  final double nominal;
  final Color color;
  ChartData(this.nominal, this.color);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBalanceVisible = false;

  final List<ChartData> dataPengeluaran = [
    ChartData(600000, const Color(0xFF4D55CC)),
    ChartData(200000, const Color(0xFFD2CFF0)),
    ChartData(200000, const Color(0xFF2C265C)),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    double totalPengeluaran = dataPengeluaran.fold(
      0,
      (sum, item) => sum + item.nominal,
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sapaan ---
              const Text(
                'Hai, Reza',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yuk, cek pengeluaranmu hari ini biar rencana besarmu tetap terjaga.',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 30),

              // --- Kartu Saldo ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total saldo',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isBalanceVisible ? "Rp 67.676.767" : "********",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => setState(
                        () => _isBalanceVisible = !_isBalanceVisible,
                      ),
                      child: Icon(
                        _isBalanceVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- BAGIAN TRANSAKSI ---
              const Text(
                'Transaksi',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),

              // TOMBOL TOP UP
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu Top Up ditekan')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 26,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Top up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // TOMBOL PEMBAYARAN & TRANSFER
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.credit_card,
                      label: "Pembayaran",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PembayaranPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.payments_outlined,
                      label: "Transfer",
                      // 2. SEKARANG SUDAH DIARAHKAN KE TRANSFER PAGE KETIKA DIKLIK
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransferPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- TRANSAKSI TERAKHIR ---
              const Text(
                'Transaksi Terakhir',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              _buildTransactionItem(
                "Isi saldo",
                "Bank mandiri\n13 Mei 2026",
                "+Rp 500.000,00",
                const Color(0xFF16C45E),
                Icons.arrow_downward,
              ),
              _buildTransactionItem(
                "Pembayaran",
                "Nasi Goreng GT\n09 Mei 2026",
                "-Rp 20.000,00",
                const Color(0xFFFF4848),
                Icons.arrow_upward,
              ),
              _buildTransactionItem(
                "Kirim ke Bank",
                "Bank Jago\n03 Mei 2026",
                "-Rp 147.900,00",
                const Color(0xFF0090FF),
                Icons.call_made,
              ),

              const SizedBox(height: 25),

              // --- STATISTIK PENGELUARAN ---
              const Text(
                'Statistik Pengeluaran',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),

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
                              "Rp ${(totalPengeluaran / 1000000).toStringAsFixed(1)} jt",
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

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lihat Detail analisis",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: primaryColor,
                            size: 12,
                          ),
                        ],
                      ),
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

  // Helper Widget Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 3. DITAMBAHKAN AGAR KLIK LEBIH SENSITIF & RESPONSIV
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          color: const Color(0xFF4D55CC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String sub,
    String amount,
    Color iconBgColor,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4D55CC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
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