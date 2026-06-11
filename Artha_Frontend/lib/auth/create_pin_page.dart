import 'package:flutter/material.dart';
import 'confirm_pin_page.dart';

class CreatePinPage extends StatefulWidget {
  const CreatePinPage({super.key});

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  static const Color primaryColor = Color(0xFF4D55CC);

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BACKGROUND BIRU MELENGKUNG ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 60), // Memberi ruang untuk kotak PIN
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                child: Stack(
                  children: [
                    // Elemen Gambar Latar BGSEC
                    Positioned(
                      top: 0,
                      right: 0,
                      width: width * 0.78,
                      height: 330,
                      child: Image.asset(
                        'assets/BGSEC.jpg',
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.8),
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Buat PIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Buat 6 digit PIN untuk mengamankan akun dan transaksi Anda. Pastikan untuk menggunakan kombinasi angka yang unik dan tidak mudah ditebak oleh orang lain.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 40),

                            // --- 6 KOTAK PIN INPUT (NATIVE KEYBOARD TRICK) ---
                            SizedBox(
                              height: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Kotak Visual (Putih)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (index) {
                                      String char = _pinController.text.length > index
                                          ? _pinController.text[index]
                                          : "";
                                      return Container(
                                        width: 45,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: char.isEmpty
                                              ? Container(
                                                  width: 16,
                                                  height: 2.5,
                                                  decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
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

                                  // TextField Asli (Transparan)
                                  Positioned.fill(
                                    child: TextField(
                                      controller: _pinController,
                                      focusNode: _pinFocusNode,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      autofocus: true,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      style: const TextStyle(
                                          color: Colors.transparent, fontSize: 1),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- TOMBOL LANJUTKAN DI AREA PUTIH BAWAH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _pinController.text.length == 6
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmPinPage(newPin: _pinController.text),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Lanjutkan",
                    style: TextStyle(
                      color: Colors.white,
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
}