import 'package:flutter/material.dart';
import 'konfirmasi_pin_page.dart';

class UbahPinPage extends StatefulWidget {
  const UbahPinPage({super.key});

  @override
  State<UbahPinPage> createState() => _UbahPinPageState();
}

class _UbahPinPageState extends State<UbahPinPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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
                        "Atur Ulang PIN",
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
                height: 60, // Tinggi area yang bisa diklik
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. KOTAK VISUAL (DI BAWAH)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        String char = _pinController.text.length > index ? _pinController.text[index] : "";
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
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autofocus: true, // Keyboard otomatis muncul
                        showCursor: false, // Sembunyikan garis kedap-kedip
                        enableInteractiveSelection: false, // Cegah copy-paste (muncul pop-up biru)
                        style: const TextStyle(
                          color: Colors.transparent, // Sembunyikan teks angka
                          fontSize: 1, // Perkecil teks agar tidak mengganggu layout
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "", // Hilangkan indikator "0/6"
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // --- TOMBOL LANJUTKAN ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _pinController.text.length == 6
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KonfirmasiPinPage(newPin: _pinController.text),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Lanjutkan",
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