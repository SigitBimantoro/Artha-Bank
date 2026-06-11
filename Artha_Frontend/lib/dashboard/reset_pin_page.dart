import 'package:flutter/material.dart';
import 'konfirmasi_reset_pin_page.dart';

class ResetPinPage extends StatefulWidget {
  final String currentPassword;
  const ResetPinPage({super.key, required this.currentPassword});

  @override
  State<ResetPinPage> createState() => _ResetPinPageState();
}

class _ResetPinPageState extends State<ResetPinPage> {
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
                    "Atur Ulang PIN",
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

              // TOMBOL LANJUTKAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _pinController.text.length == 6
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KonfirmasiResetPinPage(
                                currentPassword: widget.currentPassword,
                                newPin: _pinController.text,
                              ),
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