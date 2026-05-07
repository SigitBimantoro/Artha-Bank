import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_page.dart';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String otpCode = ""; 
  int _seconds = 59;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 59;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onKeyPress(String value) {
    if (otpCode.length < 6) setState(() => otpCode += value);
  }

  void _onDelete() {
    if (otpCode.isNotEmpty) setState(() => otpCode = otpCode.substring(0, otpCode.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4D55CC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const Text(
                    'Verifikasi Email',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4D55CC),
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Kode OTP telah dikirimkan ke email '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const TextSpan(text: '. Pastikan juga untuk memeriksa folder spam atau junk Anda.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '0:${_seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- KOTAK OTP RAMPING (SESUAI FIGMA) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        String char = otpCode.length > index ? otpCode[index] : "";
                        return Container(
                          width: 48,
                          height: 75, // Dibuat lebih tinggi agar ramping
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor, width: 1.5),
                          ),
                          child: Center(
                            child: char.isEmpty
                                ? Container(
                                    width: 18,
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : Text(
                                    char,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 60),

                    // --- TOMBOL VERIFIKASI ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (otpCode.length == 6 && !_isLoading) ? () {
                          // Simulasi sukses demo
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthPage(isLoginInitial: true)),
                            (route) => false,
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Verifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: _seconds == 0 ? _startTimer : null,
                      child: Text.rich(
                        TextSpan(
                          text: 'Belum menerima kode? ',
                          style: const TextStyle(color: Color(0xFF4D55CC), fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Kirim ulang',
                              style: TextStyle(
                                color: _seconds == 0 ? primaryColor : Colors.grey,
                                fontWeight: FontWeight.w900,
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

            // --- CUSTOM NUMPAD (SESUAI FIGMA) ---
            Container(
              color: const Color(0xFFF2F2F2),
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                children: [
                  _buildNumRow(['1', '2', '3']),
                  _buildNumRow(['4', '5', '6']),
                  _buildNumRow(['7', '8', '9']),
                  _buildNumRow(['* #', '0', 'delete']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumRow(List<String> values) {
    return Row(
      children: values.map((val) {
        if (val == 'delete') {
          return _numButton(const Icon(Icons.backspace_outlined, size: 24), _onDelete);
        }
        if (val == '* #') {
          return _numButton(const Text('* #', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)), () {});
        }
        return _numButton(
          Text(val, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400)),
          () => _onKeyPress(val),
        );
      }).toList(),
    );
  }

  Widget _numButton(Widget child, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 65,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: (child is Icon || (child is Text && child.data == '* #')) ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
} 