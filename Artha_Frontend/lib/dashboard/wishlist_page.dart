import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool _isLoading = true;
  List<dynamic> _savings = [];

  @override
  void initState() {
    super.initState();
    _loadSavingsData();
  }

  // --- MENGAMBIL DATA DARI BACKEND ---
  Future<void> _loadSavingsData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getSavings();
    
    if (mounted) {
      setState(() {
        if (res['success']) {
          _savings = res['data']['data'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  // Helper format rupiah
  String _formatRupiah(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), 
      (match) => '.'
    );
  }

  // --- POPUP: BUAT TABUNGAN BARU ---
  void _showCreateDialog() {
    if (_savings.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batas maksimal 3 tabungan tercapai!'), backgroundColor: Colors.red),
      );
      return;
    }

    final TextEditingController namaController = TextEditingController();
    final TextEditingController targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Buat Wishlist Baru", style: TextStyle(color: Color(0xFF4D55CC), fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama Barang/Target",
                  labelStyle: TextStyle(color: const Color(0xFF4D55CC).withOpacity(0.5), fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Target Nominal (Min 10.000)",
                  labelStyle: TextStyle(color: const Color(0xFF4D55CC).withOpacity(0.5), fontSize: 12),
                  prefixText: "Rp ",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (namaController.text.isEmpty || targetController.text.isEmpty) return;
                double target = double.parse(targetController.text);
                
                Navigator.pop(context); // Tutup dialog
                setState(() => _isLoading = true);

                final res = await ApiService.createSaving(
                  namaTarget: namaController.text, 
                  targetNominal: target,
                );

                if (res['success']) {
                  _loadSavingsData();
                } else {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4D55CC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- POPUP: TRANSAKSI NABUNG / TARIK ---
  void _showTransactionDialog(int savingId, String namaTarget, double saldoTerkumpul, double targetNominal, bool isAdd) {
    final TextEditingController amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isAdd ? "Isi Saldo Tabungan" : "Tarik Saldo", style: const TextStyle(color: Color(0xFF4D55CC), fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(namaTarget, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Saldo saat ini: Rp ${_formatRupiah(saldoTerkumpul)}"),
              if (isAdd) Text("Target: Rp ${_formatRupiah(targetNominal)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Nominal (Rp)",
                  labelStyle: TextStyle(color: const Color(0xFF4D55CC).withOpacity(0.5), fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isEmpty) return;
                double amount = double.parse(amountController.text);
                
                Navigator.pop(context); // Tutup dialog
                setState(() => _isLoading = true);

                Map<String, dynamic> res;
                if (isAdd) {
                  res = await ApiService.addSaldoTabungan(savingId, amount);
                } else {
                  res = await ApiService.tarikSaldoTabungan(savingId, amount);
                }

                if (res['success']) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transaksi berhasil!"), backgroundColor: Colors.green));
                  }
                  _loadSavingsData();
                } else {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4D55CC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- POPUP: DETAIL ITEM (PILIH NABUNG ATAU TARIK) ---
  void _showItemOptions(dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['nama_target'], style: const TextStyle(color: Color(0xFF4D55CC), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              const SizedBox(height: 5),
              Text("Terkumpul: Rp ${_formatRupiah((item['saldo_terkumpul'] ?? 0).toDouble())} / Rp ${_formatRupiah((item['target_nominal'] ?? 0).toDouble())}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showTransactionDialog(item['saving_id'], item['nama_target'], (item['saldo_terkumpul'] ?? 0).toDouble(), (item['target_nominal'] ?? 0).toDouble(), true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4D55CC), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text("Isi Saldo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showTransactionDialog(item['saving_id'], item['nama_target'], (item['saldo_terkumpul'] ?? 0).toDouble(), (item['target_nominal'] ?? 0).toDouble(), false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0xFF4D55CC), width: 2))),
                      child: const Text("Tarik Saldo", style: TextStyle(color: Color(0xFF4D55CC), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // --- VISUAL KARTU WISHLIST BARU ---
  Widget _buildWishlistCard(dynamic item) {
    const Color primaryColor = Color(0xFF4D55CC);
    const Color cardBgColor = Colors.white;
    const Color lightPurple = Color(0xFFB1B6ED); 

    double targetNominal = (item['target_nominal'] ?? 0).toDouble();
    double saldoTerkumpul = (item['saldo_terkumpul'] ?? 0).toDouble();
    
    double progress = targetNominal > 0 ? (saldoTerkumpul / targetNominal) : 0;
    progress = progress.clamp(0.0, 1.0); 
    int percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => _showItemOptions(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: double.infinity, // <-- PERBAIKAN: INI AGAR KARTU FULL MELEBAR
        height: 130, 
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // 1. SILUET CELENGAN BABI (DI KANAN)
              Positioned(
                right: -30,
                bottom: -25,
                child: Icon(
                  Icons.savings,
                  size: 140,
                  color: lightPurple.withOpacity(0.8),
                ),
              ),

              // 2. LINGKARAN PERSENTASE
              Positioned(
                right: 35,
                bottom: 30,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "$percentage%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. KONTEN TEKS & PROGRESS BAR (DI KIRI)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['nama_target'] ?? 'Barang Impian',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Rp${_formatRupiah(targetNominal)}",
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const TextSpan(
                            text: ".00",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),

                    // Progress Bar
                    Container(
                      width: 140,
                      height: 10,
                      decoration: BoxDecoration(
                        color: lightPurple.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(5),
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
      ),
    );
  }

  // --- VISUAL TOMBOL TAMBAH WISHLIST ---
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showCreateDialog,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF7A84E1), 
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF4D55CC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              "Buat Wishlist",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    const Color bgColor = Color(0xFFF9F9F9); 

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER TEXT ---
                const Text(
                  'Wishlist tabungan',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Yuk, cek pengeluaranmu hari ini biar rencana besarmu tetap terjaga.',
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 35),

                // --- DAFTAR WISHLIST TEXT ---
                const Text(
                  'Daftar Wishlist',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),

                // --- RENDER DAFTAR KARTU ---
                ...List.generate(_savings.length, (index) {
                  return _buildWishlistCard(_savings[index]);
                }),

                // --- TOMBOL TAMBAH (JIKA BELUM MENCAPAI LIMIT 3) ---
                if (_savings.length < 3) 
                  _buildAddButton(),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}