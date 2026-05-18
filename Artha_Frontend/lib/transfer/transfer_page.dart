import 'package:flutter/material.dart';
import 'input_rekening_page.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  // State untuk melacak tab mana yang aktif
  bool isBankTabActive = true;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Latar belakang bawah bersih murni
      body: Column(
        children: [
          // --- KONTEN UTAMA (BIRU MELENGKUNG DI BAWAH) ---
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // --- HEADER (Back, Judul, History) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Kembali
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                        // Judul Tengah
                        const Text(
                          "Transfer",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        // Tombol Riwayat / History
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Menu Riwayat Transfer ditekan'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- KOLOM PENCARIAN (SEARCH BAR) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: TextFormField(
                        style: const TextStyle(
                          color: primaryColor,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Cari bank/nama akun tujuan",
                          hintStyle: TextStyle(
                            color: Color(0xFF9F9F9F),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- SWITCHER TAB DENGAN GARIS BAWAH PENUH ---
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Garis lurus putih tipis membentang full screen
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          _buildTabItem("Pilih Bank", isBankTabActive),
                          _buildTabItem("Rekening Favorit", !isBankTabActive),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- AREA LIST DATA ITEM (DI DALAM KOTAK BIRU) ---
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 45),
                    child: isBankTabActive 
                        ? _buildPilihBankContent() 
                        : _buildRekeningFavoritContent(),
                  ),
                ],
              ),
            ),
          ),
          
          // Area sisa di bawah dibiarkan kosong bersih sesuai gambar figma
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  // Pembuat Elemen Tab Saklar Dinamis
  Widget _buildTabItem(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isBankTabActive = label == "Pilih Bank";
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              // Benjolan melengkung di bawah teks tab yang aktif
              Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tampilan Konten Grid Utama: Pilih Bank (Sudah Terhubung ke Navigasi Klik)
  Widget _buildPilihBankContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildBankCard("Bank Mandiri", "mandiri"),
        const SizedBox(width: 20),
        _buildBankCard("Bank BNI", "BNI"),
        const SizedBox(width: 20),
        _buildBankCard("Bank Jago", "jago"),
      ],
    );
  }

  // Tampilan Konten Grid Utama: Rekening Favorit
  Widget _buildRekeningFavoritContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Favorit 1: User
        SizedBox(
          width: 85,
          child: Column(
            children: [
              Container(
                width: 75,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF4D55CC),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Muhammad Reza Raffi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Item Favorit 2: Tambah Baru
        SizedBox(
          width: 95,
          child: Column(
            children: [
              Container(
                width: 75,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Color(0xFF4D55CC),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tambah rekening favorit",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Komponen Pembuat Desain Kartu Bank (SUDAH DIBUNGKUS GESTURE DETECTOR)
  Widget _buildBankCard(String name, String logoType) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Pindah halaman sambil mengirim data bank yang dipilih
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InputRekeningPage(
              initialBankName: name,
              initialBankType: logoType,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 75,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: _renderBankLogo(logoType),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi Gambar Placeholder Logo
  Widget _renderBankLogo(String type) {
    if (type == "mandiri") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "mandiri",
            style: TextStyle(
              color: Color(0xFF1C3F94),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 1),
          Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFF7B819),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      );
    } else if (type == "BNI") {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("B", style: TextStyle(color: Color(0xFFF15A22), fontSize: 16, fontWeight: FontWeight.w900)),
          Text("NI", style: TextStyle(color: Color(0xFF005A6F), fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      );
    } else {
      // Bank Jago
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5A623),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          "jago",
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }
  }
}