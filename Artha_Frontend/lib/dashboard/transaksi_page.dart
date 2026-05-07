import 'package:flutter/material.dart';

class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key});

  // Fungsi cetakan untuk membuat Kotak Menu Transaksi
  Widget _buildMenuBox({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4D55CC),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
    // --- PERBAIKAN DI SINI: Tambahkan Scaffold ---
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAFAFA,
      ), // Samakan dengan warna background halaman lain
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Judul Halaman ---
                const Text(
                  'Transaksi',
                  style: TextStyle(
                    color: Color(0xFF4D55CC),
                    fontSize: 26,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Baris 1: Transfer & Pembayaran ---
                Row(
                  children: [
                    // Kotak Kiri (Transfer)
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _buildMenuBox(
                          icon: Icons.swap_horiz,
                          title: 'Transfer',
                          onTap: () {
                            print("Klik Transfer");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Kotak Kanan (Pembayaran)
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _buildMenuBox(
                          icon: Icons.credit_card,
                          title: 'Pembayaran',
                          onTap: () {
                            print("Klik Pembayaran");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Baris 2: Top Up (Lebar Penuh) ---
                SizedBox(
                  width: double.infinity,
                  height: 130,
                  child: _buildMenuBox(
                    icon: Icons.add_circle_outline,
                    title: 'Top up',
                    onTap: () {
                      print("Klik Top up");
                    },
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
