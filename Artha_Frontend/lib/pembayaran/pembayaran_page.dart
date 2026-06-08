import 'package:flutter/material.dart';
import 'listrik_pln_page.dart';
import 'pulsa_data_page.dart';

class PembayaranPage extends StatelessWidget {
  const PembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
                  'Pembayaran',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 25),

                // --- Kartu Box Menu Pembayaran ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Pilih Menu Pembayaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Tombol 1: Pulsa dan Data
                          _buildMenuButton(
                            context: context,
                            icon: Icons.vibration,
                            label: 'Pulsa dan Data',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PulsaDataPage(),
                                ),
                              );
                            },
                          ),
                          // Tombol 2: Listrik PLN
                          _buildMenuButton(
                            context: context,
                            icon: Icons.flash_on,
                            label: 'Listrik PLN',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ListrikPlnPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const Color primaryColor = Color(0xFF4D55CC);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 75,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primaryColor, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
