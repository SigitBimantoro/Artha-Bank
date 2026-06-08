import 'package:flutter/material.dart';
import '../dashboard/main_page.dart';
import '../services/api_service.dart';

class InputPinPage extends StatefulWidget {
  final String? phoneNumber; // Untuk Transfer
  final double amount; // Untuk Transfer
  final String? notes; // Untuk Transfer

  // Tambahkan variabel untuk Pulsa/Listrik jika perlu
  final String? type; // 'TRANSFER', 'PULSA', 'PLN', 'TOPUP'
  final String? target; // Nomor HP pulsa / Nomor meteran
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
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _confirmationShown = false;
  String _typedPin = '';

  Future<void> _eksekusiTransaksi() async {
    // wrapper: call implementation that can override amount
    await _eksekusiTransaksiWithAmount(null);
  }

  Future<void> _eksekusiTransaksiWithAmount(double? overrideAmount) async {
    setState(() => _isLoading = true);

    final fee = 0.0;
    final amountToSend = overrideAmount ?? widget.amount;

    Map<String, dynamic> res;

    if (widget.type == 'TRANSFER') {
      res = await ApiService.transferUang(
        widget.phoneNumber!,
        amountToSend,
        widget.notes ?? '',
        _pinController.text,
      );
    } else if (widget.type == 'PULSA') {
      // Include fee in the amount charged to match UI total
      res = await ApiService.beliPulsa(
        widget.target!,
        amountToSend + fee,
        _pinController.text,
      );
    } else if (widget.type == 'PLN') {
      res = await ApiService.beliTokenListrik(
        widget.target!,
        amountToSend,
        _pinController.text,
      );
    } else {
      res = {'success': false, 'message': 'Tipe transaksi tidak dikenal'};
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaksi Berhasil!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Transaksi gagal'),
            backgroundColor: Colors.red,
          ),
        );
        _pinController.clear();
      }
    }
  }

  String _formatCurrency(double amount) {
    final intVal = amount.toInt();
    final s = intVal.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp ${s.replaceAllMapped(reg, (m) => '.')}';
  }

  Future<void> _showPaymentConfirmation() async {
    final fee = 0.0;
    final total = widget.amount + fee;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Konfirmasi Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF0FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            color: Color(0xFF4D55CC),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.type == 'PULSA'
                                    ? 'Pulsa'
                                    : (widget.type ?? ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.target != null)
                                Text(
                                  widget.target!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 8),

                    const Text(
                      'Detail pembayaran',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nominal Pembayaran'),
                        Text(_formatCurrency(widget.amount)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Transaksi'),
                        Text(_formatCurrency(fee)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatCurrency(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D55CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Batal'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Reset flag when dialog closes
    setState(() => _confirmationShown = false);

    if (result == true) {
      // copy typed pin into controller so API header X-PIN is included
      _pinController.text = _typedPin;
      // Jalankan transaksi; for PULSA, include fee by passing overrideAmount = widget.amount
      if (widget.type == 'PULSA') {
        await _eksekusiTransaksiWithAmount(widget.amount);
      } else {
        await _eksekusiTransaksiWithAmount(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Masukkan PIN"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Masukkan 6 digit PIN untuk mengonfirmasi transaksi"),
            const SizedBox(height: 20),
            // PIN visual boxes
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final char = _typedPin.length > index ? '●' : '';
                  return Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        char,
                        style: const TextStyle(
                          fontSize: 20,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // Numeric keypad
            _buildKeypad(primaryColor),
            const SizedBox(height: 30),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (_typedPin.length == 6 && !_isLoading)
                  ? () async {
                      // copy typed pin to controller for API usage
                      _pinController.text = _typedPin;
                      await _eksekusiTransaksi();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Bayar Sekarang"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(Color primaryColor) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row.map((k) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(color: primaryColor.withOpacity(0.1)),
                      elevation: 0,
                    ),
                    onPressed: k == ''
                        ? null
                        : () {
                            setState(() {
                              if (k == '<') {
                                if (_typedPin.isNotEmpty) {
                                  _typedPin = _typedPin.substring(
                                    0,
                                    _typedPin.length - 1,
                                  );
                                }
                                if (_typedPin.isEmpty) {
                                  _confirmationShown = false;
                                }
                              } else {
                                if (_typedPin.length < 6) _typedPin += k;
                                if (_typedPin.length == 6 &&
                                    !_confirmationShown) {
                                  if (widget.skipConfirmation) {
                                    Future.microtask(
                                      () => _eksekusiTransaksi(),
                                    );
                                  } else {
                                    _confirmationShown = true;
                                    Future.microtask(
                                      () => _showPaymentConfirmation(),
                                    );
                                  }
                                }
                              }
                            });
                          },
                    child: k == '<'
                        ? Icon(Icons.backspace_outlined, color: primaryColor)
                        : Text(
                            k,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
