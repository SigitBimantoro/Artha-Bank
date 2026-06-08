import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _meterController.dispose();
    super.dispose();
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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(34, 20, 34, 44),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 110),
                      _buildCustomerNumberCard(),
                      const SizedBox(height: 18),
                      _buildCustomerNameCard(),
                      const SizedBox(height: 34),
                      const Text(
                        'Pilih Jumlah Token',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildTokenGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(34, 56, 34, 46),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 66,
                child: ElevatedButton(
                  onPressed: isReady ? _goToPin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(
                      alpha: 0.55,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34),
                    ),
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 36,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 108,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.flash_on, color: primaryColor, size: 42),
            ),
            const SizedBox(height: 16),
            const Text(
              'Listrik PLN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerNumberCard() {
    return Container(
      width: double.infinity,
      height: 144,
      padding: const EdgeInsets.symmetric(horizontal: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextField(
                  controller: _meterController,
                  keyboardType: TextInputType.number,
                  cursorColor: primaryColor,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 25,
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
          const Icon(Icons.flash_on, color: primaryColor, size: 38),
        ],
      ),
    );
  }

  Widget _buildCustomerNameCard() {
    return Container(
      width: double.infinity,
      height: 106,
      padding: const EdgeInsets.symmetric(horizontal: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.centerLeft,
      child: const Text(
        'Nama Pelanggan : REZ***',
        style: TextStyle(
          color: primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildTokenGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tokenOptions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 96,
        mainAxisSpacing: 32,
        childAspectRatio: 2.08,
      ),
      itemBuilder: (context, index) {
        final amount = _tokenOptions[index];
        final isSelected = _selectedAmount == amount;

        return GestureDetector(
          onTap: () => setState(() => _selectedAmount = amount),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? const Color(0xFF2C265C) : Colors.white,
                width: isSelected ? 4 : 0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _formatTokenLabel(amount),
              style: const TextStyle(
                color: primaryColor,
                fontSize: 35,
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
