import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'struk_page.dart';

class InputPinPage extends StatefulWidget {
  final String? phoneNumber;
  final double amount;
  final String? notes;
  final String? type; // 'TRANSFER', 'PULSA', 'PLN', 'TOPUP'
  final String? target;
  final bool skipConfirmation;

  const InputPinPage({
    super.key,
    this.phoneNumber,
    this.amount = 0,
    this.notes = "",
    this.type = 'TRANSFER',
    this.target,
    this.skipConfirmation = false,
  });

  @override
  State<InputPinPage> createState() => _InputPinPageState();
}

class _InputPinPageState extends State<InputPinPage> {
  bool _isLoading = false;
  String _typedPin = '';

  Future<void> _eksekusiTransaksi() async {
    setState(() => _isLoading = true);

    final fee = 0.0;
    final amountToSend = widget.amount;
    Map<String, dynamic> res;

    // Eksekusi API secara murni ke backend
    if (widget.type == 'TRANSFER') {
      res = await ApiService.transferUang(
        widget.phoneNumber!,
        amountToSend,
        widget.notes ?? '',
        _typedPin,
      );
    } else if (widget.type == 'PULSA') {
      res = await ApiService.beliPulsa(
        widget.target!,
        amountToSend + fee,
        _typedPin,
      );
    } else if (widget.type == 'PLN') {
      res = await ApiService.beliTokenListrik(
        widget.target!,
        amountToSend,
        _typedPin,
      );
    } else if (widget.type == 'TOPUP') {
      res = await ApiService.topUpInternal(
        amountToSend,
        widget.target ?? 'Bank',
      );
    } else {
      res = {'success': false, 'message': 'Tipe transaksi tidak dikenal'};
    }

    if (mounted) {
      setState(() => _isLoading = false);

      String targetName = widget.target ?? widget.phoneNumber ?? '-';
      final tokenListrik = widget.type == 'PLN' && res['data'] != null
          ? (res['data']['token_listrik'] ?? '').toString()
          : null;
      String txId =
          (res['data'] != null && res['data']['transaction_id'] != null)
          ? res['data']['transaction_id'].toString()
          : DateTime.now().millisecondsSinceEpoch.toString().substring(5);

      // Pindah langsung ke rincian resi struk final
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StrukPage(
            isSuccess: res['success'] == true,
            type: widget.type ?? 'TRANSFER',
            amount: amountToSend + (widget.type == 'PULSA' ? fee : 0),
            target: targetName,
            errorMessage: res['message'],
            idTransaksi: txId,
            tokenListrik: tokenListrik?.isNotEmpty == true
                ? tokenListrik
                : null,
          ),
        ),
      );
    }
  }

  void _onKeyPressed(String val) {
    if (_isLoading) return;
    setState(() {
      if (val == '<') {
        if (_typedPin.isNotEmpty) {
          _typedPin = _typedPin.substring(0, _typedPin.length - 1);
        }
      } else {
        if (_typedPin.length < 6) _typedPin += val;

        // Begitu menyentuh 6 digit, otomatis memproses transaksi langsung
        if (_typedPin.length == 6) {
          Future.microtask(() => _eksekusiTransaksi());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: primaryColor, // Full Biru Figma
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
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
              ),
            ),
            const SizedBox(height: 20),

            // --- JUDUL ---
            const Text(
              "Masukan PIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Gunakan PIN Artha anda.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 50),

            // --- INDIKATOR PIN BINTANG (*) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                bool isFilled = index < _typedPin.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    "*",
                    style: TextStyle(
                      color: isFilled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      fontSize: 45,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              }),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(color: Colors.white),
              ),

            const Spacer(),

            // --- KEYPAD KOTAK MELENGKUNG ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  _buildKeypadRow(['4', '5', '6']),
                  _buildKeypadRow(['7', '8', '9']),
                  _buildKeypadRow(['', '0', '<']),
                ],
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
    const Color primaryColor = Color(0xFF4D55CC);
    if (val.isEmpty) {
      return const SizedBox(width: 85, height: 80);
    }

    return GestureDetector(
      onTap: () => _onKeyPressed(val),
      child: Container(
        width: 85,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: val == '<'
              ? const Icon(
                  Icons.backspace_rounded,
                  color: primaryColor,
                  size: 28,
                )
              : Text(
                  val,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
      ),
    );
  }
}
