import 'package:flutter/material.dart';
import '../pembayaran/input_nominal_page.dart'; 
import '../services/api_service.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  // State untuk Favorit
  bool _isLoadingFavorites = true;
  List<dynamic> _favorites = [];

  // State untuk Riwayat Transfer Terakhir
  bool _isLoadingRecent = true;
  List<dynamic> _recentTransfers = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites(); 
    _fetchRecentTransfers(); // Panggil data riwayat kontak terakhir
  }

  // --- LOGIKA MENGAMBIL KONTAK FAVORIT ---
  Future<void> _fetchFavorites() async {
    try {
      final res = await ApiService.getFavorites(); 
      if (mounted) {
        setState(() {
          if (res['success'] == true && res['data'] != null) {
            _favorites = res['data']['data'] ?? [];
          }
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFavorites = false);
    }
  }

  // --- LOGIKA MENGAMBIL 3 KONTAK TRANSFER TERAKHIR ---
  Future<void> _fetchRecentTransfers() async {
    try {
      final res = await ApiService.getRiwayatTransferKeluar(); 
      if (mounted) {
        setState(() {
          if (res['success'] == true && res['data'] != null) {
            // Sesuai respon backend: "recent_contacts"
            _recentTransfers = res['data']['recent_contacts'] ?? [];
          }
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRecent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- KONTEN UTAMA (BIRU MELENGKUNG) ---
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER (Back, Judul, History) ---
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back, color: primaryColor, size: 20),
                            ),
                          ),
                          const Text(
                            "Transfer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Riwayat Transfer')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history, color: primaryColor, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- SEARCH BAR ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      child: const TextField(
                        style: TextStyle(
                          color: primaryColor,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: "Cari nomor akun tujuan",
                          hintStyle: TextStyle(
                            color: Color(0xFF9F9F9F),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search, color: primaryColor, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- REKENING FAVORIT ---
                    const Text(
                      "Rekening Favorit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 15),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Render data Favorit dari API
                          if (_isLoadingFavorites)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          else
                            ..._favorites.map((fav) {
                              String name = fav['nama'] ?? 'Tanpa Nama';
                              String phone = fav['phone_number'] ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: _buildFavoriteCard(name, phone),
                              );
                            }),

                          // Tombol Tetap: Tambah Favorit
                          _buildAddFavoriteCard(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- DAFTAR TRANSFER TERAKHIR (DINAMIS) ---
                    const Text(
                      "Daftar Transfer terakhir",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Render data Transfer Terakhir dari API
                    if (_isLoadingRecent)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else if (_recentTransfers.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "Belum ada riwayat transfer",
                            style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                          ),
                        ),
                      )
                    else
                      ..._recentTransfers.map((contact) {
                        String name = contact['nama'] ?? 'Tanpa Nama';
                        String phone = contact['phone_number'] ?? '';
                        return Column(
                          children: [ 
                            _buildRecentTransferItem(name, phone),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),

                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          ),
          
          // --- RUANG PUTIH DI BAWAH ---
          const Spacer(),
        ],
      ),

      // --- TOMBOL LANJUTKAN ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Silakan pilih rekening atau kontak di atas')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            child: const Text(
              "Lanjutkan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildFavoriteCard(String name, String phone) {
    return GestureDetector(
      onTap: () {
        // Otomatis melompat ke Input Nominal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InputNominalPage(receiverName: name, receiverPhone: phone),
          ),
        );
      },
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.person, color: Color(0xFF4D55CC), size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
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
    );
  }

  Widget _buildAddFavoriteCard() {
    return GestureDetector(
      onTap: () => _showAddFavoriteDialog(), // Aksi saat diklik
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.star_border, color: Color(0xFF4D55CC), size: 30),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tambah rekening\nfavorit",
              textAlign: TextAlign.center,
              maxLines: 2,
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
    );
  } 

  Widget _buildRecentTransferItem(String name, String phone) {
    const Color primaryColor = Color(0xFF4D55CC);
    return GestureDetector(
      onTap: () {
        // Otomatis melompat ke Input Nominal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InputNominalPage(receiverName: name, receiverPhone: phone),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: primaryColor, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showAddFavoriteDialog() {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Favorit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Nomor Telepon"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: "Label (contoh: Ibu)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.isNotEmpty && labelController.text.isNotEmpty) {
                // Memanggil API Create Favorite
                final res = await ApiService.createFavorite(phoneController.text, labelController.text);
                
                if (mounted) {
                  Navigator.pop(context);
                  if (res['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil tambah favorit!")));
                    _fetchFavorites(); // Refresh daftar favorit
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                  }
                }
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}