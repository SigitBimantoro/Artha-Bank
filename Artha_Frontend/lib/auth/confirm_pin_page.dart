import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../dashboard/main_page.dart';

class ConfirmPinPage extends StatefulWidget {
  final String newPin;
  const ConfirmPinPage({super.key, required this.newPin});

  @override
  State<ConfirmPinPage> createState() => _ConfirmPinPageState();
}

class _ConfirmPinPageState extends State<ConfirmPinPage> {
  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _confirmPinFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _confirmPinController.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    if (_confirmPinController.text != widget.newPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi PIN tidak cocok!"), backgroundColor: Colors.red),
      );
      setState(() => _confirmPinController.clear());
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService.setPin(pin: _confirmPinController.text);
    
    if (mounted) setState(() => _isLoading = false);

    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN berhasil dibuat!"), backgroundColor: Colors.green),
      );
      if (!mounted) return;
      // Menghapus halaman Auth/PIN dari tumpukan dan masuk ke Dashboard utama
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BACKGROUND BIRU MELENGKUNG ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 50),
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
                    Positioned(
                      top: 0,
                      right: 0,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Image.asset(
                        'assets/BGSEC.jpg',
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.8),
                        errorBuilder: (context, error, stackTrace) => Container(),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                                fontSize: 13,
                                height: 1.5,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 40),

                            // --- 6 KOTAK PIN INPUT ---
                            SizedBox(
                              height: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
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
                                  
                                  Positioned.fill(
                                    child: TextField(
                                      controller: _confirmPinController,
                                      focusNode: _confirmPinFocusNode,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      autofocus: true, 
                                      showCursor: false, 
                                      enableInteractiveSelection: false, 
                                      style: const TextStyle(color: Colors.transparent, fontSize: 1),
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

            // --- TOMBOL SIMPAN PIN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_confirmPinController.text.length == 6 && !_isLoading) ? _submitPin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
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
            ),
          ],
        ),
      ),
    );
  }
}