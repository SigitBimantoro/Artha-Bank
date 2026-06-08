import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KonfirmasiPinPage extends StatefulWidget {
  final String newPin;
  const KonfirmasiPinPage({super.key, required this.newPin});

  @override
  State<KonfirmasiPinPage> createState() => _KonfirmasiPinPageState();
}

class _KonfirmasiPinPageState extends State<KonfirmasiPinPage> {
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _confirmPinController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _simpanPin() async {
    if (_confirmPinController.text != widget.newPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konfirmasi PIN tidak cocok!"),
          backgroundColor: Colors.red,
        ),
      );
      _confirmPinController.clear();
      setState(() {});
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masukkan password akun Anda untuk konfirmasi."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.changePin(
      _passwordController.text,
      widget.newPin,
      _confirmPinController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PIN Berhasil diubah!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      final message =
          res['message'] ?? 'Gagal mengubah PIN. Silakan coba lagi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      _passwordController.clear();
      _confirmPinController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- HEADER ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Konfirmasi PIN baru",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 50),

              const Text(
                "Masukkan PIN baru Anda di bawah ini.",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 30),

              // --- 6 KOTAK PIN INPUT (TRIK TERTUMPUK) ---
              SizedBox(
                height: 60, // Tinggi area klik
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. KOTAK VISUAL (DI BAWAH)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        String char = _confirmPinController.text.length > index
                            ? _confirmPinController.text[index]
                            : "";
                        return Container(
                          width: 45,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor, width: 1.5),
                          ),
                          child: Center(
                            child: char.isEmpty
                                ? Container(
                                    width: 15,
                                    height: 2,
                                    color: primaryColor,
                                  )
                                : const Text(
                                    "●",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),

                    // 2. TEXTFIELD ASLI (DI ATAS, TRANSPARAN PENUH)
                    Positioned.fill(
                      child: TextField(
                        controller: _confirmPinController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autofocus: true,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 1,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Akun',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      !_isLoading && _confirmPinController.text.length == 6
                      ? _simpanPin
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan PIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
