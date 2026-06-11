import 'package:flutter/material.dart';

import '../dashboard/main_page.dart';
import '../services/api_service.dart';

class ConfirmPinPage extends StatefulWidget {
  final String newPin;

  const ConfirmPinPage({super.key, required this.newPin});

  @override
  State<ConfirmPinPage> createState() => _ConfirmPinPageState();
}

class _ConfirmPinPageState extends State<ConfirmPinPage> {
  static const Color primaryColor = Color(0xFF4D55CC);

  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _confirmPinFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _confirmPinController.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanPin() async {
    if (_confirmPinController.text != widget.newPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi PIN tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      _confirmPinController.clear();
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.setPin(widget.newPin);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Keamanan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 0)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal menyimpan PIN'),
          backgroundColor: Colors.red,
        ),
      );
      _confirmPinController.clear();
      setState(() {});
    }
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
                              'Konfirmasi PIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Masukkan kembali 6 digit PIN yang baru saja Anda buat. Pastikan kombinasi angka yang dimasukkan sudah persis sama dengan sebelumnya.',
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
                                      String char = _confirmPinController.text.length > index
                                          ? _confirmPinController.text[index]
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
                                      controller: _confirmPinController,
                                      focusNode: _confirmPinFocusNode,
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

            // --- TOMBOL SIMPAN PIN DI AREA PUTIH BAWAH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (_confirmPinController.text.length == 6 && !_isLoading)
                          ? _simpanPin
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Simpan PIN',
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