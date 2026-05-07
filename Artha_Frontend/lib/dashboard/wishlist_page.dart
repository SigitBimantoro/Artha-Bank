import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  // Fungsi cetakan untuk membuat baris Daftar Wishlist
  Widget _buildWishlistItem(String number, String itemName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Jarak antar item
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF4D55CC),
          width: 1.5,
        ), // Garis pinggir biru
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Lingkaran Angka Biru
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF4D55CC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 20), // Jarak antara angka dan teks
          // Nama Barang
          Expanded(
            child: Text(
              itemName,
              style: const TextStyle(
                color: Color(0xFF4D55CC),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        // Agar bisa di-scroll kalau daftarnya panjang
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Judul Halaman ---
              const Text(
                'Wishlist tabungan',
                style: TextStyle(
                  color: Color(0xFF4D55CC),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Catat barang idamanmu di sini. Ayo kumpulkan dananya sedikit demi sedikit untuk mewujudkannya.',
                style: TextStyle(
                  color: Color(0xFF4D55CC),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),

              // --- Ilustrasi Celengan Babi (Placeholder) ---
              // Nanti bisa diganti dengan Image.asset kalau sudah diexport dari Figma
              Center(
                child: Icon(
                  Icons.savings, // Ikon bawaan Flutter yang mirip celengan babi
                  size: 140,
                  color: const Color(0xFF4D55CC),
                ),
              ),
              const SizedBox(height: 30),

              // --- Kartu Total Tabungan ---
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D55CC),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    // Tombol Kiri (Total Tabungan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Total tabungan',
                        style: TextStyle(
                          color: Color(0xFF4D55CC),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Nominal Kanan
                    const Expanded(
                      child: Text(
                        'Rp500.000,00',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Judul Daftar ---
              const Text(
                'Daftar Wishlist',
                style: TextStyle(
                  color: Color(0xFF4D55CC),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 15),

              // --- Memanggil Daftar Wishlist ---
              // Lihat betapa rapinya kode kita karena pakai fungsi _buildWishlistItem
              _buildWishlistItem('1', 'Mobil'),
              _buildWishlistItem('2', 'Lensa telephoto'),
              _buildWishlistItem('3', 'Resident Evil 3'),

              const SizedBox(
                height: 80,
              ), // Jarak aman agar tidak tertutup Bottom Nav Bar
            ],
          ),
        ),
      ),
    );
  }
}
