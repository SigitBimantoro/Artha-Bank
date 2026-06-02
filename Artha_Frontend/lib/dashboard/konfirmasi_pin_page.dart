import 'package:flutter/material.dart';

class KonfirmasiPinPage extends StatefulWidget {
  final String newPin;
  const KonfirmasiPinPage({super.key, required this.newPin});

  @override
  State<KonfirmasiPinPage> createState() => _KonfirmasiPinPageState();
}

class _KonfirmasiPinPageState extends State<KonfirmasiPinPage> {
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _confirmPinController.dispose();
    super.dispose();
  }

  void _simpanPin() {
    if (_confirmPinController.text == widget.newPin) {
      // TODO: Panggil API Backend (Ganti PIN) di sini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN Berhasil diubah!"), backgroundColor: Colors.green),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // Kembali ke Dashboard/Profil
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi PIN tidak cocok!"), backgroundColor: Colors.red),
      );
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
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                        String char = _confirmPinController.text.length > index ? _confirmPinController.text[index] : "";
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
              const SizedBox(height: 50),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _confirmPinController.text.length == 6 ? _simpanPin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text(
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