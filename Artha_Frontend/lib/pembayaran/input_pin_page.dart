import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InputPinPage extends StatefulWidget {
  final String phoneNumber;
  final double amount;

  // Constructor dimodifikasi untuk menerima data pembayaran
  const InputPinPage({
    super.key,
    required this.phoneNumber,
    required this.amount,
  });

  @override
  State<InputPinPage> createState() => _InputPinPageState();
}

class _InputPinPageState extends State<InputPinPage> {
  String _pin = "";
  bool _isLoading = false;

  void _onKeypadTap(String value) {
    if (_pin.length < 6 && !_isLoading) {
      setState(() {
        _pin += value;
      });
    }

    if (_pin.length == 6 && !_isLoading) {
      _prosesPembayaranAPI();
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty && !_isLoading) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  // Fungsi untuk memproses pembayaran ke Backend
  Future<void> _prosesPembayaranAPI() async {
    setState(() => _isLoading = true);
    
    // Tampilkan loading muter-muter tanpa merusak style ui belakang
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final res = await ApiService.beliPulsa(
      phoneNumber: widget.phoneNumber,
      amount: widget.amount,
      pin: _pin,
    );

    // Tutup loading muter-muter
    if (mounted) {
      Navigator.pop(context); 
    }
    
    setState(() => _isLoading = false);

    if (res['success']) {
      // Jika berhasil, tampilkan pesan sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['data']['message'] ?? 'Pembayaran Berhasil!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Kembali ke halaman Dashboard utama (menutup seluruh tumpukan page pembayaran)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      // Jika gagal (contoh PIN salah / Saldo kurang), tampilkan error dan reset input PIN
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _pin = ""; // Kosongkan PIN agar user bisa coba lagi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Tombol Back & Teks) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
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
                  const SizedBox(height: 40),
                  const Text(
                    "Masukan PIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Gunakan PIN Artha anda.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- INDIKATOR PIN BINTANG BIASA (DINAMIS & AMAN KLIK) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                bool isFilled = index < _pin.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    isFilled ? "●" : "*",
                    style: TextStyle(
                      color: isFilled ? Colors.white : Colors.white.withOpacity(0.4),
                      fontSize: isFilled ? 24 : 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),

            const Expanded(child: SizedBox()),

            // --- NUMERIC KEYPAD (Bisa Diklik & Lancar) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildKeypadButton("1"),
                      _buildKeypadButton("2"),
                      _buildKeypadButton("3"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildKeypadButton("4"),
                      _buildKeypadButton("5"),
                      _buildKeypadButton("6"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildKeypadButton("7"),
                      _buildKeypadButton("8"),
                      _buildKeypadButton("9"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 95, height: 75),
                      _buildKeypadButton("0"),
                      _buildBackspaceButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String value) {
    const Color primaryColor = Color(0xFF4D55CC);
    return GestureDetector(
      onTap: () => _onKeypadTap(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 95,
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    const Color primaryColor = Color(0xFF4D55CC);
    return GestureDetector(
      onTap: _onBackspace,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 95,
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: primaryColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}