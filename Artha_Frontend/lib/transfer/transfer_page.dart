import 'package:flutter/material.dart';
import '../pembayaran/input_nominal_page.dart';
import '../dashboard/riwayat_page.dart';
import '../services/api_service.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  static const Color primaryColor = Color(0xFF4D55CC);

  final TextEditingController _phoneController = TextEditingController();
  bool _isLoadingFavorites = true;
  List<dynamic> _favorites = [];
  bool _isLoadingRecent = true;
  List<dynamic> _recentTransfers = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_fetchFavorites(), _fetchRecentTransfers()]);
  }

  Future<void> _fetchFavorites() async {
    final res = await ApiService.getFavorites();
    if (!mounted) return;
    setState(() {
      if (res['success'] == true) _favorites = res['data']['data'] ?? [];
      _isLoadingFavorites = false;
    });
  }

  Future<void> _fetchRecentTransfers() async {
    final res = await ApiService.getRiwayatTransferKeluar();
    if (!mounted) return;
    setState(() {
      if (res['success'] == true) _recentTransfers = res['data']['recent_contacts'] ?? [];
      _isLoadingRecent = false;
    });
  }

  // --- FUNGSI POP-UP TAMBAH KONTAK FAVORIT ---
  void _showTambahKontakBottomSheet() {
    const Color primaryColor = Color(0xFF4D55CC);
    final TextEditingController namaController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tambah Kontak Favorit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Field Nama
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: namaController,
                        style: const TextStyle(color: primaryColor, fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          labelText: 'Nama Kontak',
                          labelStyle: TextStyle(color: primaryColor.withValues(alpha: 0.5), fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Field Nomor HP
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: primaryColor, fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          labelText: 'Nomor HP',
                          labelStyle: TextStyle(color: primaryColor.withValues(alpha: 0.5), fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (namaController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Nama dan nomor HP wajib diisi!"), duration: Duration(seconds: 1)),
                                  );
                                  return;
                                }
                                setModalState(() => isLoading = true);
                                final res = await ApiService.createFavorite(
                                  phoneController.text.trim(),
                                  namaController.text.trim(),
                                );
                                if (!mounted || !context.mounted) return;
                                Navigator.pop(context);
                                if (res['success'] == true) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(content: Text("Kontak berhasil ditambahkan!"), duration: Duration(seconds: 1)),
                                  );
                                  _fetchFavorites();
                                } else {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text(res['message'] ?? "Gagal menambahkan kontak")),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'Poppins', fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- FUNGSI POP-UP KONFIRMASI (INTEGRASI FINAL) ---
  void _showConfirmationDialog(Map<String, dynamic> recipient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Cek Detail Penerima", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4D55CC))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4D55CC)), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const CircleAvatar(backgroundColor: Color(0xFF4D55CC), child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(recipient['label'] ?? 'Nama Penerima', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Artha - ${recipient['recipient_phone']}", style: const TextStyle(color: Color(0xFF4D55CC))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Pastikan data penerima sudah benar.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => InputNominalPage(receiverName: recipient['label'], receiverPhone: recipient['recipient_phone'], transactionType: 'TRANSFER')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4D55CC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: const Text("Lanjutkan", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4D55CC), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Ubah Penerima", style: TextStyle(color: Color(0xFF4D55CC), fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.74,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(72),
                  bottomRight: Radius.circular(72),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(),
                      const SizedBox(height: 42),
                      _buildSearchBar(),
                      const SizedBox(height: 28),
                      const Text(
                        "Rekening Favorit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildFavoritesList(),
                      const SizedBox(height: 24),
                      const Text(
                        "Daftar Transfer terakhir",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(child: _buildRecentList()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomButton(primaryColor),
        ],
      ),
    );
  }

  Widget _buildAppBar() => Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: primaryColor, size: 24),
        ),
      ),
      const SizedBox(width: 20),
      const Expanded(
        child: Text(
          "Transfer",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RiwayatPage()),
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history, color: primaryColor, size: 24),
        ),
      ),
    ],
  );

  Widget _buildSearchBar() => Container(
    height: 64,
    padding: const EdgeInsets.only(left: 20, right: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Center(
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: "Cari nomor akun tujuan",
          hintStyle: const TextStyle(
            color: Color(0xFF9B9BE7),
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 6, bottom: 9),
          suffixIcon: const Icon(Icons.search, color: primaryColor, size: 30),
        ),
      ),
    ),
  );

  Widget _buildFavoritesList() {
    if (_isLoadingFavorites) {
      return const SizedBox(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _favorites.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) {
          if (i == _favorites.length) {
            return _buildTambahFavItem();
          }
          return _buildFavItem(
            _favorites[i]['label'] ?? 'User',
            Icons.person,
            () => _showConfirmationDialog(_favorites[i]),
          );
        },
      ),
    );
  }

  Widget _buildTambahFavItem() => SizedBox(
    width: 110,
    child: GestureDetector(
      onTap: () => _showTambahKontakBottomSheet(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.star_border_rounded, color: primaryColor, size: 24),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tambah rekening\nfavorit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    ),
  );

  Widget _buildFavItem(String label, IconData icon, VoidCallback onTap) => SizedBox(
    width: 110,
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  Widget _buildRecentList() {
    if (_isLoadingRecent) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _recentTransfers.length,
      itemBuilder: (ctx, i) {
        final item = _recentTransfers[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InputNominalPage(
                receiverName: item['nama'],
                receiverPhone: item['phone_number'],
                transactionType: 'TRANSFER',
              ),
            ),
          ),
          child: Container(
            height: 62,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: primaryColor, size: 30),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    item['nama'] ?? 'User',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                    fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(Color color) => Container(
        color: const Color(0xFFF9F9F9),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _phoneController.text.isNotEmpty
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InputNominalPage(
                          receiverName: "Nomor Baru",
                          receiverPhone: _phoneController.text.trim(),
                          transactionType: 'TRANSFER',
                        ),
                      ),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: const Color(0xFFC9C9C9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                "Lanjutkan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
