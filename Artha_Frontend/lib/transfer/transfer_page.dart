import 'package:flutter/material.dart';
import '../pembayaran/input_nominal_page.dart';
import '../services/api_service.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
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

  Future<void> _addRecentToFavorites(String name, String phone) async {
    final res = await ApiService.createFavorite(phone, name);
    if (!mounted) return;
    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan ke favorit!")));
      _fetchFavorites();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Gagal")));
    }
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => InputNominalPage(receiverName: recipient['label'], receiverPhone: recipient['recipient_phone'])));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4D55CC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: const Text("Lanjutkan", style: TextStyle(color: Colors.white)),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ubah Penerima", style: TextStyle(color: Color(0xFF4D55CC)))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      const Text("Rekening Favorit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildFavoritesList(),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Daftar Transfer terakhir", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                        const SizedBox(height: 15),
                        Expanded(child: _buildRecentList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(primaryColor),
    );
  }

  Widget _buildAppBar() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
      const Text("Transfer", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const Icon(Icons.history, color: Colors.white),
    ],
  );

  Widget _buildSearchBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(hintText: "Masukkan nomor HP tujuan", border: InputBorder.none, suffixIcon: Icon(Icons.search, color: Color(0xFF4D55CC))),
    ),
  );

  Widget _buildFavoritesList() => SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _favorites.length + 1,
      itemBuilder: (ctx, i) {
        if (i == _favorites.length) {
          return _buildFavItem("Tambah", Icons.add, () {}); 
        }
        // Panggil pop-up saat rekening ditekan
        return _buildFavItem(_favorites[i]['label'] ?? 'User', Icons.person, () => _showConfirmationDialog(_favorites[i]));
      },
    ),
  );

  Widget _buildFavItem(String label, IconData icon, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(right: 20),
    child: GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF4D55CC))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _buildRecentList() => ListView.builder(
    itemCount: _recentTransfers.length,
    itemBuilder: (ctx, i) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        leading: const Icon(Icons.person, color: Color(0xFF4D55CC)),
        title: Text(_recentTransfers[i]['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_recentTransfers[i]['phone_number']),
        trailing: IconButton(icon: const Icon(Icons.bookmark_border, color: Color(0xFF4D55CC)), onPressed: () => _addRecentToFavorites(_recentTransfers[i]['nama'], _recentTransfers[i]['phone_number'])),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InputNominalPage(receiverName: _recentTransfers[i]['nama'], receiverPhone: _recentTransfers[i]['phone_number']))),
      ),
    ),
  );

  Widget _buildBottomButton(Color color) => Padding(
    padding: const EdgeInsets.all(24),
    child: ElevatedButton(
      onPressed: () => _phoneController.text.isNotEmpty ? Navigator.push(context, MaterialPageRoute(builder: (_) => InputNominalPage(receiverName: "Nomor Baru", receiverPhone: _phoneController.text.trim()))) : null,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
      child: const Text("Lanjutkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

