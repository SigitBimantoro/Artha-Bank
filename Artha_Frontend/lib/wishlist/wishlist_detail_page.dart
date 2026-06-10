import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WishlistDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onChanged;

  const WishlistDetailPage({super.key, required this.item, this.onChanged});

  @override
  State<WishlistDetailPage> createState() => _WishlistDetailPageState();
}

class _WishlistDetailPageState extends State<WishlistDetailPage> {
  static const Color primaryColor = Color(0xFF4D55CC);
  static const Color softCard = Color(0xFFE4E5F7);
  static const Color addCard = Color(0xFF7A7FE3);
  static const List<Map<String, String>> _periodeOptions = [
    {'label': 'Harian', 'value': 'DAILY'},
    {'label': 'Mingguan', 'value': 'WEEKLY'},
    {'label': 'Bulanan', 'value': 'MONTHLY'},
  ];

  late Map<String, dynamic> _item;
  bool _autoDebit = false;
  bool _isProcessing = false;
  late String _selectedPeriode;
  late TextEditingController _autoDebitNominalController;

  @override
  void initState() {
    super.initState();
    _item = Map<String, dynamic>.from(widget.item);
    final periode = (_item['auto_debit_periode'] ?? 'NONE').toString();
    _selectedPeriode = periode == 'NONE' ? 'MONTHLY' : periode;
    _autoDebit = periode != 'NONE';
    final nominal = (_item['auto_debit_nominal'] ?? 0).toDouble();
    _autoDebitNominalController = TextEditingController(
      text: nominal > 0 ? _formatRupiah(nominal) : '',
    );
  }

  @override
  void dispose() {
    _autoDebitNominalController.dispose();
    super.dispose();
  }

  double get _targetNominal => (_item['target_nominal'] ?? 0).toDouble();
  double get _saldoTerkumpul => (_item['saldo_terkumpul'] ?? 0).toDouble();
  double get _progress => _targetNominal > 0
      ? (_saldoTerkumpul / _targetNominal).clamp(0.0, 1.0)
      : 0.0;
  int get _percentage => (_progress * 100).round();

  String _formatRupiah(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  double _parseNominal(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  String _periodeLabel(String value) {
    switch (value) {
      case 'DAILY':
        return 'Harian';
      case 'WEEKLY':
        return 'Mingguan';
      case 'MONTHLY':
        return 'Bulanan';
      default:
        return 'Bulanan';
    }
  }

  Future<void> _showMoneySheet(bool isAdd) async {
    final amountController = TextEditingController();
    final title = isAdd ? 'Tambahkan Uang' : 'Pindahkan Uang';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: amountController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  cursorColor: primaryColor,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                  decoration: _sheetInputDecoration('Masukan Nominal'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = _parseNominal(amountController.text);
                      if (amount <= 0) return;

                      Navigator.pop(context);
                      await _submitTransaction(isAdd, amount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditWishlistSheet() async {
    final nameController = TextEditingController(
      text: _item['nama_target'] ?? '',
    );
    final targetController = TextEditingController(
      text: 'Rp${_formatRupiah(_targetNominal)}',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Wishlist',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 34),
                _buildEditField(
                  label: 'Nama Wishlist',
                  controller: nameController,
                  autofocus: true,
                ),
                const SizedBox(height: 14),
                _buildEditField(
                  label: 'Target Wishlist',
                  controller: targetController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final target = _parseNominal(targetController.text);
                      if (name.isEmpty || target <= 0) return;

                      Navigator.pop(context);
                      await _submitEditWishlist(name, target);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _sheetInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: primaryColor.withValues(alpha: 0.55),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: 'Poppins',
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(34),
        borderSide: const BorderSide(color: primaryColor, width: 2.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(34),
        borderSide: const BorderSide(color: primaryColor, width: 2.4),
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: autofocus,
          cursorColor: primaryColor,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitEditWishlist(String name, double target) async {
    setState(() => _isProcessing = true);
    final res = await ApiService.updateSaving(_item['saving_id'], name, target);

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _item['nama_target'] = name;
        _item['target_nominal'] = target;
      });
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wishlist berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal memperbarui wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _saveAutoDebit() async {
    final nominal = _parseNominal(_autoDebitNominalController.text);
    final periode = _autoDebit ? _selectedPeriode : 'NONE';

    if (_autoDebit && nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal auto-debit terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final res = await ApiService.updateSavingAutoDebit(
      id: _item['saving_id'],
      autoDebitNominal: _autoDebit ? nominal : 0,
      autoDebitPeriode: periode,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _item['auto_debit_nominal'] = _autoDebit ? nominal : 0;
        _item['auto_debit_periode'] = periode;
      });
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan auto-debit tersimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal menyimpan auto-debit'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _clearAutoDebit() async {
    setState(() => _isProcessing = true);
    final res = await ApiService.updateSavingAutoDebit(
      id: _item['saving_id'],
      autoDebitNominal: 0,
      autoDebitPeriode: 'NONE',
    );

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _item['auto_debit_nominal'] = 0;
        _item['auto_debit_periode'] = 'NONE';
      });
      widget.onChanged?.call();
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _submitTransaction(bool isAdd, double amount) async {
    setState(() => _isProcessing = true);
    final savingId = _item['saving_id'];
    final res = isAdd
        ? await ApiService.addSaldoTabungan(savingId, amount)
        : await ApiService.tarikSaldoTabungan(savingId, amount);

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        final current = _saldoTerkumpul;
        _item['saldo_terkumpul'] = isAdd
            ? (current + amount).clamp(0.0, _targetNominal)
            : (current - amount).clamp(0.0, _targetNominal);
      });
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Transaksi gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _confirmDeleteWishlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Hapus Wishlist?',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
            ),
          ),
          content: const Text(
            'Saldo yang sudah terkumpul akan dikembalikan ke dompet utama.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE92227),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteWishlist();
    }
  }

  Future<void> _deleteWishlist() async {
    setState(() => _isProcessing = true);
    final res = await ApiService.deleteSaving(_item['saving_id']);

    if (!mounted) return;

    if (res['success'] == true) {
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wishlist berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal menghapus wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 34),
      decoration: BoxDecoration(
        color: softCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 176,
            height: 138,
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: -26,
                  child: Image.asset(
                    'assets/celengan.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  right: 72,
                  bottom: 38,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _item['nama_target'] ?? 'Wishlist',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Rp${_formatRupiah(_targetNominal)}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const TextSpan(
                  text: ',00',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: _isProcessing ? null : _showEditWishlistSheet,
            child: const Text(
              'Ubah Wishlist',
              style: TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                decoration: TextDecoration.underline,
                decorationColor: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
      decoration: BoxDecoration(
        color: softCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Wishlist',
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 28),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Rp${_formatRupiah(_saldoTerkumpul)},00',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextSpan(
                  text: ' / Rp${_formatRupiah(_targetNominal)},00',
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 0.48),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 13,
              value: _progress,
              backgroundColor: const Color(0xFFC7CBF0),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: _isProcessing ? null : onTap,
        child: Container(
          height: 116,
          decoration: BoxDecoration(
            color: addCard,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoDebitToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 22, right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Auto-Debit',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Switch(
                value: _autoDebit,
                activeThumbColor: Colors.white,
                activeTrackColor: primaryColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFA6A6A6),
                onChanged: (value) {
                  setState(() => _autoDebit = value);
                  if (!value) {
                    _clearAutoDebit();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: _autoDebit
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF4D55CC),
              borderRadius: BorderRadius.circular(34),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Periode Auto debit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPeriode,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _periodeOptions
                      .map(
                        (opt) => DropdownMenuItem<String>(
                          value: opt['value'],
                          child: Text(
                            opt['label']!,
                            style: const TextStyle(
                              color: primaryColor,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedPeriode = value);
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Nominal Auto-Debit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _autoDebitNominalController,
                  keyboardType: TextInputType.number,
                  cursorColor: primaryColor,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Masukan Nominal',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9FA5E6),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _saveAutoDebit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      'Simpan Auto-Debit (${_periodeLabel(_selectedPeriode)})',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Rincian Wishlist',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 34),
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  _buildProgressCard(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        label: 'Tambah Uang',
                        onTap: () => _showMoneySheet(true),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        icon: Icons.arrow_upward,
                        label: 'Pindahkan Uang',
                        onTap: () => _showMoneySheet(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildAutoDebitToggle(),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: SizedBox(
                height: 62,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmDeleteWishlist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE92227),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hapus Wishlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.delete_outline, color: Colors.white, size: 25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
