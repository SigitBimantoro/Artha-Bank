import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'input_pin_page.dart';

class ListrikPlnPage extends StatefulWidget {
  const ListrikPlnPage({super.key});

  @override
  State<ListrikPlnPage> createState() => _ListrikPlnPageState();
}

class _ListrikPlnPageState extends State<ListrikPlnPage> {
  static const Color primaryColor = Color(0xFF4D55CC);

  final TextEditingController _meterController = TextEditingController(
    text: '081234567891',
  );

  final List<int> _tokenOptions = [
    15000,
    20000,
    25000,
    30000,
    40000,
    50000,
    75000,
    100000,
    150000,
    200000,
    300000,
    500000,
  ];

  int? _selectedAmount;
  Timer? _lookupTimer;
  String _customerName = 'Memuat...';
  bool _isLookupLoading = false;

  @override
  void initState() {
    super.initState();
    _lookupCustomerName();
  }

  @override
  void dispose() {
    _lookupTimer?.cancel();
    _meterController.dispose();
    super.dispose();
  }

  void _scheduleCustomerLookup() {
    _lookupTimer?.cancel();
    _lookupTimer = Timer(
      const Duration(milliseconds: 500),
      _lookupCustomerName,
    );
  }

  Future<void> _lookupCustomerName() async {
    final phone = _meterController.text.trim();
    if (phone.length < 10) {
      if (mounted) {
        setState(() {
          _customerName = 'Nomor belum valid';
          _isLookupLoading = false;
        });
      }
      return;
    }

    setState(() => _isLookupLoading = true);
    final res = await ApiService.getUserByPhone(phone);
    if (!mounted || phone != _meterController.text.trim()) return;

    if (res['success'] == true && res['data']?['data'] != null) {
      final data = res['data']['data'];
      setState(() {
        _customerName = (data['nama'] ?? 'Pelanggan').toString();
        _isLookupLoading = false;
      });
    } else {
      final ownAccount = await _lookupOwnAccount(phone);
      if (!mounted || phone != _meterController.text.trim()) return;
      if (ownAccount != null) {
        setState(() {
          _customerName = ownAccount;
          _isLookupLoading = false;
        });
        return;
      }

      setState(() {
        _customerName = 'Pelanggan PLN';
        _isLookupLoading = false;
      });
    }
  }

  Future<String?> _lookupOwnAccount(String phone) async {
    final profile = await ApiService.getProfile();
    if (profile['success'] != true || profile['data']?['data'] == null) {
      return null;
    }

    final data = profile['data']['data'];
    final profilePhone = (data['phone_number'] ?? '').toString();
    if (!_isSamePhone(phone, profilePhone)) return null;
    return (data['nama'] ?? 'Pelanggan').toString();
  }

  bool _isSamePhone(String a, String b) {
    final variantsA = _phoneVariants(a);
    final variantsB = _phoneVariants(b);
    return variantsA.any(variantsB.contains);
  }

  Set<String> _phoneVariants(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final variants = <String>{digits};
    if (digits.startsWith('0') && digits.length > 1) {
      variants.add('62${digits.substring(1)}');
    }
    if (digits.startsWith('62') && digits.length > 2) {
      variants.add('0${digits.substring(2)}');
    }
    variants.remove('');
    return variants;
  }

  String _formatTokenLabel(int amount) {
    final ribu = amount ~/ 1000;
    return '$ribu rb';
  }

  void _goToPin() {
    final meterNumber = _meterController.text.trim();
    if (meterNumber.isEmpty || _selectedAmount == null) return;

    _showConfirmationSheet(meterNumber, _selectedAmount!);
  }

  String _formatCurrency(int amount) {
    final s = amount.toString();
    return 'Rp ${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  void _showConfirmationSheet(String meterNumber, int amount) {
    const fee = 2000;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(36)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Token Listrik',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meterNumber,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 2, color: primaryColor),
                const SizedBox(height: 14),
                const Text(
                  'Detail pembayaran',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nominal Pembayaran',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      _formatCurrency(amount),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Biaya Transaksi',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      _formatCurrency(fee),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InputPinPage(
                            amount: (amount + fee).toDouble(),
                            type: 'PLN',
                            target: meterNumber,
                            skipConfirmation: true,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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

  @override
  Widget build(BuildContext context) {
    final isReady =
        _meterController.text.trim().isNotEmpty && _selectedAmount != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          Expanded(
            child: Container(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildCustomerNumberCard(),
                          const SizedBox(height: 14),
                          _buildCustomerNameCard(),
                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 2,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Tagihan Listrik',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pilih Jumlah Token',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: _buildTokenGrid()),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(isReady),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool isReady) {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isReady ? _goToPin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              disabledBackgroundColor: const Color(0xFFC9C9C9),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Lanjutkan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
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
        ),
        const SizedBox(height: 5),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.flash_on, color: primaryColor, size: 30),
        ),
        const SizedBox(height: 10),
        const Text(
          'Listrik PLN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerNumberCard() {
    return Container(
      width: double.infinity,
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nomor Pelanggan',
                  style: TextStyle(
                    color: Color(0xFF8E90E7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextField(
                  controller: _meterController,
                  keyboardType: TextInputType.number,
                  cursorColor: primaryColor,
                  onChanged: (_) {
                    setState(() {});
                    _scheduleCustomerLookup();
                  },
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.flash_on, color: primaryColor, size: 32),
        ],
      ),
    );
  }

  Widget _buildCustomerNameCard() {
    return Container(
      width: double.infinity,
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        _isLookupLoading
            ? 'Nama Pelanggan : Memuat...'
            : 'Nama Pelanggan : $_customerName',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildTokenGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 40),
      itemCount: _tokenOptions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final amount = _tokenOptions[index];
        final isSelected = _selectedAmount == amount;

        return GestureDetector(
          onTap: () => setState(() => _selectedAmount = amount),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF2C265C) : Colors.white,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _formatTokenLabel(amount),
              style: const TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        );
      },
    );
  }
}
