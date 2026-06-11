import 'package:flutter/material.dart';
import 'reset_pin_page.dart';

class UbahPinPage extends StatefulWidget {
  const UbahPinPage({super.key});

  @override
  State<UbahPinPage> createState() => _UbahPinPageState();
}

class _UbahPinPageState extends State<UbahPinPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  static const Color primaryColor = Color(0xFF4D55CC);

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _lanjutkan() {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan kata sandi Anda"), backgroundColor: Colors.red),
      );
      return;
    }
    // Lanjut ke halaman masukkan PIN baru dengan membawa password
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPinPage(currentPassword: _passwordController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const Text(
                    "Verifikasi Sandi",
                    style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // DESKRIPSI
              const Text(
                "Masukkan kata sandi akun Anda untuk melanjutkan perubahan PIN.",
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor, fontSize: 13, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 40),

              // INPUT PASSWORD
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kata sandi saat ini",
                    style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: primaryColor),
                    decoration: InputDecoration(
                      hintText: "Masukkan kata sandi",
                      hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.5), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: primaryColor),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: primaryColor, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // TOMBOL LANJUTKAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _lanjutkan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text("Lanjutkan", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}