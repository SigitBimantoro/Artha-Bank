import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBalanceVisible =
      false; // Status apakah saldo disembunyikan (****) atau ditampilkan

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sapaan ---
            const Text(
              'Hai, Reza',
              style: TextStyle(
                color: Color(0xFF4D55CC),
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yuk, cek pengeluaranmu hari ini biar rencana besarmu tetap terjaga.',
              style: TextStyle(
                color: Color(0xFF4D55CC),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30),

            // --- Kartu Saldo (Warna Biru) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFF4D55CC),
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

                  // Nominal Saldo
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

                  // Tombol Mata (Lihat/Sembunyikan Saldo)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible =
                            !_isBalanceVisible; // Ubah status lihat/sembunyi
                      });
                    },
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
          ],
        ),
      ),
    );
  }
}
