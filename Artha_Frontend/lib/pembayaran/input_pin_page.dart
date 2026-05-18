import 'package:flutter/material.dart';

class InputPinPage extends StatefulWidget {
  const InputPinPage({super.key});

  @override
  State<InputPinPage> createState() => _InputPinPageState();
}

class _InputPinPageState extends State<InputPinPage> {
  String _pin = "";

  void _onKeypadTap(String value) {
    if (_pin.length < 6) {
      setState(() {
        _pin += value;
      });
    }

    if (_pin.length == 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Diterima. Memproses Transaksi...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
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
                    isFilled ? "●" : "*", // Pakai bulat atau bintang biasa sesuai ketikan
                    style: TextStyle(
                      color: isFilled ? Colors.white : Colors.white.withOpacity(0.4),
                      fontSize: isFilled ? 24 : 35, // Ukuran disesuaikan biar sejajar rapi
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),

            // Menggunakan Expanded kosong yang aman agar layout tidak menutupi area tombol keypad
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
                      const SizedBox(width: 95, height: 75), // Spacer penyeimbang angka 0
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

  // Widget Tombol Angka (Latar Putih, Text Biru)
  Widget _buildKeypadButton(String value) {
    const Color primaryColor = Color(0xFF4D55CC);
    return GestureDetector(
      onTap: () => _onKeypadTap(value),
      behavior: HitTestBehavior.opaque, // Memastikan seluruh area tombol merespon sentuhan
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

  // Widget Tombol Backspace
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