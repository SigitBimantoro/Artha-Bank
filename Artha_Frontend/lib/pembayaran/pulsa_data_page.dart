import 'package:flutter/material.dart';
import 'pilih_paket_page.dart';

class PulsaDataPage extends StatefulWidget {
  const PulsaDataPage({super.key}); 

  @override
  State<PulsaDataPage> createState() => _PulsaDataPageState();
}

class _PulsaDataPageState extends State<PulsaDataPage> {
  final TextEditingController _phoneController = TextEditingController(); // <-- Kosongkan di sini
// ...

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // --- HEADER UNGU MELENGKUNG ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 35,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: 70,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.vibration,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Pulsa dan Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- KARTU INPUT NOMOR HANDPHONE ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w900,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Nomor Handphone',
                              labelStyle: TextStyle(
                                color: primaryColor.withOpacity(0.5),
                                fontSize: 11,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.vibration,
                          color: primaryColor.withOpacity(0.6),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),

      // --- TOMBOL LANJUTKAN ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GestureDetector(
            onTap: () {
              // --- PERUBAHAN DI SINI: MENGIRIM DATA KE HALAMAN PILIH PAKET ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PilihPaketPage(
                    phoneNumber: _phoneController.text, 
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  'Lanjutkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}