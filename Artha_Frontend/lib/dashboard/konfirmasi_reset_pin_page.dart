import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KonfirmasiResetPinPage extends StatefulWidget {
  final String currentPassword;
  final String newPin;

  const KonfirmasiResetPinPage({super.key, required this.currentPassword, required this.newPin});

  @override
  State<KonfirmasiResetPinPage> createState() => _KonfirmasiResetPinPageState();
}

class _KonfirmasiResetPinPageState extends State<KonfirmasiResetPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF4D55CC);

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanPin() async {
    if (_pinController.text != widget.newPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi PIN tidak cocok!"), backgroundColor: Colors.red),
      );
      _pinController.clear();
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    // Memanggil endpoint API
    final res = await ApiService.changePin(
      widget.currentPassword,
      widget.newPin,
      _pinController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN Berhasil diubah!"), backgroundColor: Colors.green),
      );
      // Kembali hingga ke halaman Profile (halaman Dashboard)
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal mengubah PIN'), backgroundColor: Colors.red),
      );
      _pinController.clear();
      setState(() {});
    }
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
                    "Konfirmasi PIN baru",
                    style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // DESKRIPSI
              const Text(
                "Masukkan PIN baru Anda di bawah ini.",
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor, fontSize: 13, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 40),

              // KOTAK PIN INPUT
              SizedBox(
                height: 65,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        String char = _pinController.text.length > index ? _pinController.text[index] : "";
                        return Container(
                          width: 45,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor, width: 1.2),
                          ),
                          child: Center(
                            child: char.isEmpty
                                ? const Text("-", style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.w500))
                                : Text(char, style: const TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.w700)),
                          ),
                        );
                      }),
                    ),
                    Positioned.fill(
                      child: TextField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autofocus: true,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        style: const TextStyle(color: Colors.transparent, fontSize: 1),
                        decoration: const InputDecoration(border: InputBorder.none, counterText: "", contentPadding: EdgeInsets.zero),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_pinController.text.length == 6 && !_isLoading) ? _simpanPin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Simpan PIN", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}