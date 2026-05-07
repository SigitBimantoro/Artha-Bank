import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Fungsi cetakan untuk membuat baris info (Total Wishlist & Total Save Money)
  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF4D55CC),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF4D55CC),
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Judul Halaman ---
              const Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF4D55CC),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 30),

              // --- Kartu Profil Utama (Biru) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D55CC),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    // Kotak Foto Profil (Warna Putih)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Color(0xFF4D55CC), // Placeholder foto profil
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nama User
                    const Text(
                      'Reza Hafafi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Email User
                    const Text(
                      'Hafafi@gmail.com',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Tombol Edit Profile
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Aksi untuk edit profil
                        print("Edit Profile Diklik");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4D55CC),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Edit profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- Baris Info (Total Wishlist & Save Money) ---
              // Memanggil fungsi cetakan yang sudah dibuat di atas
              _buildInfoRow('Total Wishlist', '3'),
              _buildInfoRow('Total save money', 'Rp 302.183,00'),

              const SizedBox(
                height: 80,
              ), // Jarak aman dari Bottom Navigation Bar
            ],
          ),
        ),
      ),
    );
  }
}
