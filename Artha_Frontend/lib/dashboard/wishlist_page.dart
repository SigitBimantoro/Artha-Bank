import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../wishlist/create_wishlist_page.dart';
import '../wishlist/wishlist_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  static const Color primaryColor = Color(0xFF4D55CC);
  static const Color bgColor = Color(0xFFF8F8FB);
  static const Color softPurple = Color(0xFFC1C5F2);
  static const Color borderPurple = Color(0xFF555DE2);

  bool _isLoading = true;
  List<dynamic> _savings = [];

  @override
  void initState() {
    super.initState();
    _loadSavingsData();
  }

  Future<void> _loadSavingsData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getSavings();

    if (!mounted) return;
    setState(() {
      if (res['success'] == true) {
        _savings = res['data']?['data'] ?? [];
      }
      _isLoading = false;
    });
  }

  String _formatRupiah(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  Future<void> _openCreateWishlistPage() async {
    if (_savings.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas maksimal 3 tabungan tercapai!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateWishlistPage()),
    );

    if (created == true && mounted) {
      _loadSavingsData();
    }
  }

  void _showItemOptions(dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WishlistDetailPage(
          item: Map<String, dynamic>.from(item),
          onChanged: _loadSavingsData,
        ),
      ),
    );
  }

  Widget _buildWishlistCard(dynamic item) {
    final double targetNominal = (item['target_nominal'] ?? 0).toDouble();
    final double saldoTerkumpul = (item['saldo_terkumpul'] ?? 0).toDouble();
    final double progress = targetNominal > 0
        ? (saldoTerkumpul / targetNominal).clamp(0.0, 1.0)
        : 0.0;
    final int percentage = (progress * 100).round();

    return GestureDetector(
      onTap: () => _showItemOptions(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 8,
              bottom: -17,
              child: Image.asset(
                'assets/celengan.png',
                width: 156,
                height: 156,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: 75,
              bottom: 40,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama_target'] ?? 'Barang Impian',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: borderPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rp${_formatRupiah(targetNominal)}',
                          style: const TextStyle(
                            color: borderPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const TextSpan(
                          text: ',00',
                          style: TextStyle(
                            color: borderPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 156,
                    height: 9,
                    decoration: BoxDecoration(
                      color: softPurple.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress == 0 ? 0.08 : progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: borderPurple,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderPurple, width: 2.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _openCreateWishlistPage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF7A7FE3),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 14),
            const Text(
              "Buat Wishlist",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
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
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : RefreshIndicator(
                color: primaryColor,
                onRefresh: _loadSavingsData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wishlist tabungan',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 28,
                            height: 1.05,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Yuk, mulai nabung hari ini biar wishlist impianmu cepat terwujud!',
                          style: TextStyle(
                            color: primaryColor.withValues(alpha: 0.88),
                            fontSize: 15,
                            height: 1.45,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Daftar Wishlist',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_savings.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            child: Text(
                              'Belum ada wishlist. Buat yang pertama sekarang.',
                              style: TextStyle(
                                color: primaryColor.withValues(alpha: 0.65),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        else
                          ...List.generate(
                            _savings.length,
                            (index) => _buildWishlistCard(_savings[index]),
                          ),
                        if (_savings.length < 3) _buildAddButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
