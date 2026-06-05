import 'package:flutter/material.dart';
import 'dart:math';
import '../pembayaran/pembayaran_page.dart'; 
import '../transfer/transfer_page.dart';
import '../services/api_service.dart'; // <-- Import API Service

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
  bool _isLoading = true;

  // Variabel untuk menampung data dari Backend
  String _namaUser = "Memuat...";
  double _saldo = 0;
  List<dynamic> _recentTransactions = [];
  double _totalPengeluaran = 0;

  List<ChartData> dataPengeluaran = [
    ChartData(1, const Color(0xFFE0E0E0)), // Default Abu-abu agar tidak blank
  ];

  @override
  void initState() {
    super.initState();
    _loadHomeData(); // Panggil fungsi saat halaman dibuka
  }

  // --- LOGIKA MENGAMBIL DATA API ---
  Future<void> _loadHomeData() async {
    try {
      // 1. Ambil Nama & Saldo
      final profileRes = await ApiService.getProfile();
      if (profileRes['success'] && profileRes['data'] != null) {
        final userData = profileRes['data']['data'];
        setState(() {
          // Ambil kata pertama dari nama lengkap
          _namaUser = (userData['nama'] ?? 'User').split(' ')[0]; 
          _saldo = (userData['saldo'] ?? 0).toDouble(); // Pastikan backend sudah kirim 'saldo'
        });
      }

      // 2. Ambil 3 Riwayat Transaksi Terakhir (Asumsi di ApiService ada fungsi getHistory)
      // Jika error karena ApiService.getHistory belum dibuat, silakan buat di api_service.dart
      final historyRes = await ApiService.getHistory(limit: 3);
      if (historyRes['success'] && historyRes['data'] != null) {
        setState(() {
          _recentTransactions = historyRes['data']['data'] ?? [];
        });
      }

      // 3. Ambil Statistik Pengeluaran (Mingguan)
      final trackingRes = await ApiService.getTrackingKeuangan('weekly');
      if (trackingRes['success'] && trackingRes['data'] != null && trackingRes['data']['data'] != null) {
        final pieData = trackingRes['data']['data']['pie_chart'];
        if (pieData != null) {
          double p = (pieData['pembayaran'] ?? 0).toDouble();
          double t = (pieData['top_up'] ?? 0).toDouble();
          double tr = (pieData['transfer_keluar'] ?? 0).toDouble();
          
          setState(() {
            _totalPengeluaran = p + t + tr;
            if (_totalPengeluaran > 0) {
              dataPengeluaran = [
                ChartData(p, const Color(0xFF2C265C)), // Pembayaran
                ChartData(t, const Color(0xFF4D55CC)), // Top up
                ChartData(tr, const Color(0xFFD2CFF0)), // Transfer
              ];
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error load home: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper Format Rupiah (1.000.000)
  String _formatRupiah(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), 
      (match) => '.'
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return SafeArea(
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sapaan ---
              Text(
                'Hai, $_namaUser', // Dinamis dari API
                style: const TextStyle(
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
                      _isBalanceVisible ? "Rp ${_formatRupiah(_saldo)}" : "********", // Dinamis dari API
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
                  // TODO: Arahkan ke halaman InputNominal untuk Top Up
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

              // --- TRANSAKSI TERAKHIR (DINAMIS DARI API) ---
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terakhir',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Lihat semua',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Render Riwayat Transaksi
              if (_recentTransactions.isEmpty)
                 Center(
                   child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     child: Text(
                       "Belum ada transaksi",
                       style: TextStyle(color: primaryColor.withOpacity(0.5), fontFamily: 'Poppins'),
                     ),
                   ),
                 )
              else
                ..._recentTransactions.map((trx) {
                  return _renderTransactionItemDinamis(trx);
                }),

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
                              _totalPengeluaran >= 1000000 
                                  ? "Rp ${(_totalPengeluaran / 1000000).toStringAsFixed(1)} jt" 
                                  : "Rp ${_formatRupiah(_totalPengeluaran)}",
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
              const SizedBox(height: 50), // Ruang ekstra di bawah
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: PENGUBAH DATA API MENJADI UI LIST TRANSAKSI ---
  Widget _renderTransactionItemDinamis(dynamic trx) {
    String type = trx['transaction_type'] ?? '';
    String mutasi = trx['mutasi'] ?? '';
    double amount = (trx['amount'] ?? 0).toDouble();
    String notes = trx['notes'] ?? '';
    String date = trx['tanggal'] ?? '';

    // Default tampilan
    String title = "Transaksi";
    Color iconBgColor = const Color(0xFF0090FF);
    IconData icon = Icons.receipt_long;
    String amountText = "";

    if (mutasi == "MASUK") {
      amountText = "+Rp ${_formatRupiah(amount)}";
    } else {
      amountText = "-Rp ${_formatRupiah(amount)}";
    }

    // Logika Pemilihan Ikon & Warna sesuai API Backend-mu
    if (type == "TOPUP") {
      title = "Isi Saldo";
      iconBgColor = const Color(0xFF16C45E); // Hijau
      icon = Icons.arrow_downward;
    } else if (type == "TRANSFER") {
      if (mutasi == "KELUAR") {
        title = "Transfer Keluar";
        iconBgColor = const Color(0xFF0090FF); // Biru
        icon = Icons.call_made;
      } else {
        title = "Transfer Masuk";
        iconBgColor = const Color(0xFF16C45E); // Hijau
        icon = Icons.arrow_downward;
      }
    } else if (type == "PULSA" || type == "PLN") {
      title = "Pembayaran";
      iconBgColor = const Color(0xFFFF4848); // Merah
      icon = Icons.arrow_upward;
    } else if (type == "SAVING_IN" || type == "SAVING_OUT") {
      title = "Tabungan";
      iconBgColor = const Color(0xFFF5A623); // Oren
      icon = mutasi == "MASUK" ? Icons.arrow_downward : Icons.arrow_upward;
    }

    // Hindari notes kepanjangan yang bikin layout rusak
    String shortNotes = notes.length > 25 ? "${notes.substring(0, 25)}..." : notes;

    return _buildTransactionItem(
      title,
      "$shortNotes\n$date",
      amountText,
      iconBgColor,
      icon,
    );
  }

  // Helper Widget Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const Color primaryColor = Color(0xFF4D55CC);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: primaryColor,
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

  // Template Asli Card Riwayat Transaksi
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

// ============================================================================
// CUSTOM PAINTER (TIDAK DIUBAH SAMA SEKALI)
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