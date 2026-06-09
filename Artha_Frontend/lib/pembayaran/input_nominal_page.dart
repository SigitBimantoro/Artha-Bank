import 'package:flutter/material.dart';
import 'input_pin_page.dart';

class InputNominalPage extends StatefulWidget {
  final String receiverName;
  final String receiverPhone;
  final String transactionType; // 'TRANSFER', 'TOPUP', 'PULSA', 'PLN'

  const InputNominalPage({
    super.key,
    required this.receiverName,
    required this.receiverPhone,
    required this.transactionType,
  });

  @override
  State<InputNominalPage> createState() => _InputNominalPageState();
}

class _InputNominalPageState extends State<InputNominalPage> {
  String _nominal = '';

  static const Color primaryColor = Color(0xFF4D55CC);

  String get _formattedNominal {
    if (_nominal.isEmpty) return 'Rp 0';
    final angka = int.tryParse(_nominal) ?? 0;
    final s = angka.toString();
    final formatted = s.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $formatted';
  }

  void _onKeyPressed(String val) {
    setState(() {
      if (val == '<') {
        if (_nominal.isNotEmpty) {
          _nominal = _nominal.substring(0, _nominal.length - 1);
        }
      } else if (val == '000') {
        if (_nominal.isNotEmpty) {
          _nominal += '000';
        }
      } else {
        if (_nominal.length < 10) {
          _nominal += val;
        }
      }
    });
  }

  void _lanjutkan() {
    final amount = double.tryParse(_nominal) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal yang valid'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InputPinPage(
          phoneNumber: widget.transactionType == 'TRANSFER' ? widget.receiverPhone : null,
          amount: amount,
          type: widget.transactionType,
          target: widget.receiverName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                  const SizedBox(width: 20),
                  Text(
                    widget.transactionType == 'TOPUP' ? 'Top Up' : 'Masukkan Nominal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- INFO PENERIMA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transactionType == 'TOPUP' ? 'Metode Top Up' : 'Tujuan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.receiverName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (widget.transactionType != 'TOPUP') ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.receiverPhone,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- TAMPILAN NOMINAL ---
            Text(
              _formattedNominal,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Masukkan nominal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(),

            // --- KEYPAD ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  _buildKeypadRow(['4', '5', '6']),
                  _buildKeypadRow(['7', '8', '9']),
                  _buildKeypadRow(['000', '0', '<']),
                ],
              ),
            ),

            // --- TOMBOL LANJUTKAN ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _lanjutkan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((val) => _buildKey(val)).toList(),
      ),
    );
  }

  Widget _buildKey(String val) {
    return GestureDetector(
      onTap: () => _onKeyPressed(val),
      child: Container(
        width: 85,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: val == '<'
              ? const Icon(
                  Icons.backspace_rounded,
                  color: Colors.white,
                  size: 26,
                )
              : Text(
                  val,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
      ),
    );
  }
} 